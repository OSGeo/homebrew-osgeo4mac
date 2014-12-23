class SagaGis < Formula
  homepage "http://saga-gis.org"
  url "https://downloads.sourceforge.net/project/saga-gis/SAGA%20-%202.1/SAGA%202.1.2/saga_2.1.2.tar.gz"
  sha1 "9dddd3e03bd5f640fedd318ee8ff187785745e86"

  bottle do
    root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
    sha1 "2e1e3c6f665d603d9dbac2f63e8b6f393d8130fb" => :mavericks
  end

  head "svn://svn.code.sf.net/p/saga-gis/code-0/trunk/saga-gis"

  option "with-app", "Build SAGA.app Package"
  option "with-liblas", "Build with internal libLAS 1.2 support"

  depends_on :automake
  depends_on :autoconf
  depends_on :libtool
  depends_on "gdal"
  depends_on "jasper"
  depends_on "proj"
  depends_on "wxmac-mono"
  depends_on "unixodbc" => :recommended
  depends_on "libharu" => :recommended
  # Vigra support builds, but dylib in saga shows 'failed' when loaded
  # Also, using --with-python will trigger vigra to be built with it, which
  # triggers a source (re)build of boost --with-python
  depends_on "vigra" => :optional
  depends_on "postgresql" => :optional
  depends_on :python => :optional
  depends_on "libgeotiff" if build.with? "liblas"

  resource "app_icon" do
    url "http://web.fastermac.net/~MacPgmr/SAGA/saga_gui.icns"
    sha1 "1ff67c6d600dd161684d3e8b33a1d138c65b00f4"
  end

  resource "projects" do
    url "http://trac.osgeo.org/proj/export/2409/branches/4.8/proj/src/projects.h"
    sha1 "867367a8ef097d5ff772b7f50713830d2d4bc09c"
    version "4.8.0"
  end

  resource "liblas" do
    url "https://github.com/libLAS/libLAS/archive/1.2.1.tar.gz"
    sha1 "24a775484285d4e35eb8034bf298f740d7123569"
  end

  resource "liblas_patch" do
    # Fix for error of conflicting types for '_GTIFcalloc' between gdal 1.11 and libgeotiff
    # https://github.com/libLAS/libLAS/issues/33
    # This is an attempt to do it for old liblas 1.2.1
    url "https://gist.githubusercontent.com/dakcarto/f73717dac2777262d0f0/raw/a931380c41529767544a4c0dcc645b21f9b395e7/saga-gis_liblas.diff"
    sha1 "b76ac09e59099e3cc2365630c02efe0f335f3964"
  end

  def install
    (buildpath/"src/modules/projection/pj_proj4").install resource("projects")

    # Need to remove unsupported libraries from various Makefiles
    # http://sourceforge.net/p/saga-gis/wiki/Compiling%20SAGA%20on%20Mac%20OS%20X
    inreplace "src/saga_core/saga_gui/Makefile.am", "aui,base,", ""
    inreplace "src/saga_core/saga_gui/Makefile.am", "propgrid,", ""

    if build.with? "liblas"
      # Saga still only works with liblas 1.2.1 (5 years old). Vendor in libexec
      # see: http://sourceforge.net/p/saga-gis/discussion/354013/thread/823cbde1/
      mktemp do
        resource("liblas").stage do
          # patch liblas
          (Pathname.pwd).install resource("liblas_patch")
          safe_system "/usr/bin/patch", "-g", "0", "-f", "-d", Pathname.pwd, "-p1", "-i", "saga-gis_liblas.diff"

          args = %W[
            --prefix=#{libexec}
            --disable-dependency-tracking
            --with-gdal=#{Formula["gdal"].opt_bin}/gdal-config
            --with-geotiff=#{Formula["libgeotiff"].opt_prefix}
          ]
          system "autoreconf", "-i"
          system "./configure", *args
          system "make", "install"
        end
      end
      ENV.prepend "CPPFLAGS", "-I#{libexec}/include"
      ENV.prepend "LDFLAGS", "-L#{libexec}/lib"
      # Find c lib interface for liblas
      inreplace "configure.ac", "[las]", "[las_c]"
    end

    args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-openmp
    ]

    args << "--disable-odbc" if build.without? "unixodbc"
    args << "--with-postgresql" if build.with? "postgresql"
    args << "--with-python" if build.with? "python"

    system "autoreconf", "-i"
    system "./configure", *args
    system "make", "install"

    if build.with? "app"
      # Based on original script by Phil Hess
      # http://web.fastermac.net/~MacPgmr/

      (buildpath).install resource("app_icon")
      mkdir_p "#{buildpath}/SAGA.app/Contents/MacOS"
      mkdir_p "#{buildpath}/SAGA.app/Contents/Resources"

      (buildpath/"SAGA.app/Contents/PkgInfo").write "APPLSAGA"
      cp "#{buildpath}/saga_gui.icns", "#{buildpath}/SAGA.app/Contents/Resources/"
      ln_s "#{bin}/saga_gui", "#{buildpath}/SAGA.app/Contents/MacOS/saga_gui"

      config = <<-EOS.undent
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleDevelopmentRegion</key>
          <string>English</string>
          <key>CFBundleExecutable</key>
          <string>saga_gui</string>
          <key>CFBundleIconFile</key>
          <string>saga_gui.icns</string>
          <key>CFBundleInfoDictionaryVersion</key>
          <string>6.0</string>
          <key>CFBundleName</key>
          <string>SAGA</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
          <key>CFBundleSignature</key>
          <string>SAGA</string>
          <key>CFBundleVersion</key>
          <string>1.0</string>
          <key>CSResourcesFileMapped</key>
          <true/>
        </dict>
        </plist>
      EOS

      (buildpath/"SAGA.app/Contents/Info.plist").write config
      prefix.install "SAGA.app"

    end
  end

  def caveats
    if build.with? "app"
      <<-EOS.undent
      SAGA.app was installed in:
        #{prefix}

      Note that the SAGA GUI does not work very well yet.
      It has problems with creating a preferences file in the correct location and sometimes won't shut down (use Activity Monitor to force quit if necessary).
      EOS
    end
  end
end


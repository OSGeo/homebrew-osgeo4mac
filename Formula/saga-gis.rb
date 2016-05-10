class SagaGis < Formula
  homepage "http://saga-gis.org"
  url "https://downloads.sourceforge.net/project/saga-gis/SAGA%20-%202.2/SAGA%202.2.7/saga_2.2.7.tar.gz"
  sha256 "6be4b844226bc48da4f2deb39bc732767b939e72b76506abf03f8170c54cb671"

  bottle do
    # root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
    # sha1 "2e1e3c6f665d603d9dbac2f63e8b6f393d8130fb" => :mavericks
    # sha1 "5abac0d06395008e4028f35524b2c996a6a4026e" => :yosemite
  end

  head "svn://svn.code.sf.net/p/saga-gis/code-0/trunk/saga-gis"

  option "with-app", "Build SAGA.app Package"
  option "with-liblas", "Build with internal libLAS 1.2 support"

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "gdal-20"
  depends_on "jasper"
  depends_on "proj"
  depends_on "wxmac"
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
    url "http://qgis.dakotacarto.com/osgeo4mac/saga_gui.icns"
    sha256 "288e589d31158b8ffb9ef76fdaa8e62dd894cf4ca76feabbae24a8e7015e321f"
  end

  resource "liblas" do
    url "https://github.com/libLAS/libLAS/archive/1.2.1.tar.gz"
    sha256 "ad9fbc55d8a56cc3f5eec2a59dd1057ffbae02d8ec476e6fb9c94476c73b3440"
  end

  resource "liblas_patch" do
    # Fix for error of conflicting types for '_GTIFcalloc' between gdal 1.11 and libgeotiff
    # https://github.com/libLAS/libLAS/issues/33
    # This is an attempt to do it for old liblas 1.2.1
    url "https://gist.githubusercontent.com/dakcarto/f73717dac2777262d0f0/raw/a931380c41529767544a4c0dcc645b21f9b395e7/saga-gis_liblas.diff"
    sha256 "4c89c04e0b3c5f23fb7532f18c89ba9267e341b014ae4ec5c4e8e028f0f7cad7"
  end

  def install
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
          <key>NSHighResolutionCapable</key>
          <string>True</string>
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

  test do
    output = `#{bin}/saga_cmd --help`
    assert_match /The SAGA command line interpreter/, output
  end
end


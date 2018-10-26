class SagaGis < Formula
  desc "System for Automated Geoscientific Analyses - Long Term Support"
  homepage "http://saga-gis.org"
  url "https://downloads.sourceforge.net/project/saga-gis/SAGA%20-%207/SAGA%20-%207.0.0/saga-7.0.0.tar.gz"
  sha256 "b30418eb60c28324536011c0331a4da14f8f3881ddf2ac240e35944229fdc592"

  head "https://git.code.sf.net/p/saga-gis/code.git"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 1
    sha256 "888764bdbe82263f0f71ce3b52347aa2d787ff517b36cc62085c6ac8d3af5bbd" => :high_sierra
    sha256 "888764bdbe82263f0f71ce3b52347aa2d787ff517b36cc62085c6ac8d3af5bbd" => :sierra
  end

  keg_only "QGIS fails to load the correct SAGA version, if the latest version is in the path"

  option "with-app", "Build SAGA.app Package"

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "gdal2"
  depends_on "proj"
  depends_on "wxmac"
  depends_on "unixodbc" => :recommended
  depends_on "libharu" => :recommended
  depends_on "qhull" => :recommended # instead of looking for triangle
  # Vigra support builds, but dylib in saga shows 'failed' when loaded
  # Also, using --with-python will trigger vigra to be built with it, which
  # triggers a source (re)build of boost --with-python
  depends_on "brewsci/science/vigra" => :optional
  depends_on "postgresql" => :optional
  depends_on "python@2" => :optional
  depends_on "opencv" => :optional

  resource "app_icon" do
    url "https://osgeo4mac.s3.amazonaws.com/src/saga_gui.icns"
    sha256 "288e589d31158b8ffb9ef76fdaa8e62dd894cf4ca76feabbae24a8e7015e321f"
  end

  def install

    ENV.cxx11
    # SKIP liblas support until SAGA supports > 1.8.1, which should support GDAL 2;
    #      otherwise, SAGA binaries may lead to multiple GDAL versions being loaded
    # See: https://github.com/libLAS/libLAS/issues/106


    # fix homebrew-specific header location for qhull
    inreplace "src/tools/grid/grid_gridding/nn/delaunay.c", "qhull/", "libqhull/" if build.with? "qhull"

    # libfire and triangle are for non-commercial use only, skip them
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-openmp
      --disable-libfire
    ]

    args << "--disable-odbc" if build.without? "unixodbc"
    args << "--disable-triangle" if build.with? "qhull"
    args << "--with-postgresql=#{Formula["postgresql"].opt_bin}/pg_config" if build.with? "postgresql"
    args << "--with-python" if build.with? "python"

    system "autoreconf", "-i"
    system "./configure", *args
    system "make", "install"

    if build.with? "app"
      # Based on original script by Phil Hess
      # http://web.fastermac.net/~MacPgmr/

      buildpath.install resource("app_icon")
      mkdir_p "#{buildpath}/SAGA.app/Contents/MacOS"
      mkdir_p "#{buildpath}/SAGA.app/Contents/Resources"

      (buildpath/"SAGA.app/Contents/PkgInfo").write "APPLSAGA"
      cp "#{buildpath}/saga_gui.icns", "#{buildpath}/SAGA.app/Contents/Resources/"
      ln_s "#{bin}/saga_gui", "#{buildpath}/SAGA.app/Contents/MacOS/saga_gui"

      config = <<~EOS
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
      <<~EOS
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

class SagaGis < Formula
  desc "System for Automated Geoscientific Analyses - Long Term Support"
  homepage "http://saga-gis.org"
  url "https://downloads.sourceforge.net/project/saga-gis/SAGA%20-%207/SAGA%20-%207.0.0/saga-7.0.0.tar.gz"
  sha256 "b30418eb60c28324536011c0331a4da14f8f3881ddf2ac240e35944229fdc592"

  revision 1

  head "https://git.code.sf.net/p/saga-gis/code.git"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 1
    sha256 "ae9d4a0f03ac24f1c5e153789e8527ec1acc93b50f447f57cd08575532dc381e" => :mojave
    sha256 "ae9d4a0f03ac24f1c5e153789e8527ec1acc93b50f447f57cd08575532dc381e" => :high_sierra
    sha256 "ae9d4a0f03ac24f1c5e153789e8527ec1acc93b50f447f57cd08575532dc381e" => :sierra
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
  depends_on "geos"
  depends_on "laszip"
  depends_on "jasper"
  depends_on "fftw"
  depends_on "libtiff"
  depends_on "swig"
  depends_on "xz" # lzma
  depends_on "giflib"
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
  depends_on "liblas" => :optional
  depends_on "poppler" => :optional
  depends_on "osgeo/osgeo4mac/hdf4" => :optional
  depends_on "hdf5" => :optional
  depends_on "netcdf" => :optional
  depends_on "sqlite" => :optional

  resource "app_icon" do
    url "https://osgeo4mac.s3.amazonaws.com/src/saga_gui.icns"
    sha256 "288e589d31158b8ffb9ef76fdaa8e62dd894cf4ca76feabbae24a8e7015e321f"
  end

  def install
    ENV.cxx11

    # SKIP liblas support until SAGA supports > 1.8.1, which should support GDAL 2;
    #      otherwise, SAGA binaries may lead to multiple GDAL versions being loaded
    # See: https://github.com/libLAS/libLAS/issues/106

    # https://sourceforge.net/p/saga-gis/wiki/Compiling%20SAGA%20on%20Mac%20OS%20X/
    # configure FEATURES CXX="CXX" CPPFLAGS="DEFINES GDAL_H $PROJ_H" LDFLAGS="GDAL_SRCH PROJ_SRCH LINK_MISC"

    # cppflags : wx-config --version=3.0 --cppflags
    # defines : -D_FILE_OFFSET_BITS=64 -DWXUSINGDLL -D__WXMAC__ -D__WXOSX__ -D__WXOSX_COCOA__
    cppflags = "-I#{HOMEBREW_PREFIX}/lib/wx/include/osx_cocoa-unicode-3.0 -I#{HOMEBREW_PREFIX}/include/wx-3.0 -D_FILE_OFFSET_BITS=64 -DWXUSINGDLL -D__WXMAC__ -D__WXOSX__ -D__WXOSX_COCOA__"

    # libs : wx-config --version=3.0 --libs
    ldflags = "-L#{HOMEBREW_PREFIX}/lib -framework IOKit -framework Carbon -framework Cocoa -framework AudioToolbox -framework System -framework OpenGL -lwx_osx_cocoau_xrc-3.0 -lwx_osx_cocoau_webview-3.0 -lwx_osx_cocoau_html-3.0 -lwx_osx_cocoau_qa-3.0 -lwx_osx_cocoau_adv-3.0 -lwx_osx_cocoau_core-3.0 -lwx_baseu_xml-3.0 -lwx_baseu_net-3.0 -lwx_baseu-3.0"

    # xcode : xcrun --show-sdk-path
    link_misc = "-arch x86_64 -mmacosx-version-min=10.9 -isysroot #{MacOS::Xcode.prefix}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX#{MacOS.version}.sdk -lstdc++"

    ENV.append "CPPFLAGS", "-I#{Formula["proj"].opt_include} -I#{Formula["gdal2"].opt_include} #{cppflags}"
    ENV.append "LDFLAGS", "-L#{Formula["proj"].opt_lib}/libproj.dylib -L#{Formula["gdal2"].opt_lib}/libgdal.dylib #{link_misc} #{ldflags}"

    # Disable narrowing warnings when compiling in C++11 mode.
    ENV.append "CXXFLAGS", "-Wno-c++11-narrowing -std=c++11"

    # fix homebrew-specific header location for qhull
    inreplace "src/tools/grid/grid_gridding/nn/delaunay.c", "qhull/", "libqhull/" if build.with? "qhull"

    # libfire and triangle are for non-commercial use only, skip them
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-openmp
      --disable-libfire
      --enable-shared
      --enable-debug
      --enable-gui
    ]

    # --disable-gui
    # --enable-unicode

    args << "--disable-odbc" if build.without? "unixodbc"
    args << "--disable-triangle" if build.with? "qhull"
    args << "--with-postgresql=#{Formula["postgresql"].opt_bin}/pg_config" if build.with? "postgresql"
    args << "--with-python" if build.with? "python"

    (prefix/"SAGA.app/Contents/PkgInfo").write "APPLSAGA"
    (prefix/"SAGA.app/Contents/Resources").install resource("app_icon")

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

    (prefix/"SAGA.app/Contents/Info.plist").write config

    system "autoreconf", "-i"
    system "./configure", *args
    system "make", "install"

    chdir "#{prefix}/SAGA.app/Contents" do
      mkdir "MacOS" do
        ln_s "#{bin}/saga_gui", "saga_gui"
      end
    end
  end

  def caveats
    if build.with? "app"
      <<~EOS
      SAGA.app was installed in:
        #{prefix}

      You may also symlink QGIS.app into /Applications or ~/Applications:
        ln -Fs `find $(brew --prefix) -name "SAGA.app"` /Applications/SAGA.app

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

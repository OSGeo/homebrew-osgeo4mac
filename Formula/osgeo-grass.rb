class Grass < Formula
  include Language::Python::Virtualenv
  
  desc "GRASS GIS - free and open source Geographic Information System (GIS)"
  homepage "https://grass.osgeo.org"
  url "https://github.com/OSGeo/grass/archive/refs/tags/8.2.0.tar.gz"
  sha256 "621c3304a563be19c0220ae28f931a5e9ba74a53218c5556cd3f7fbfcca33a80"
  license "GPL-2.0-or-later"
  version "8.2.0"

  # option "without-gui", "Build without WxPython interface. Command line tools still available"
  option "with-app", "Build GRASS.app Package"
  # option "with-avce00", "Build with AVCE00 support: Make Arc/Info (binary) Vector Coverages appear as E00"
  # option "with-pg14", "Build with PostgreSQL 14 client"
  # option "with-mysql", "Build with MySQL client"
  # option "with-others", "Build with other optional dependencies"
  # Core dependencies

  # depends_on :x11 if build.without? "aqua" # needs to find at least X11/include/GL/gl.h
  depends_on :xcode
  # GCC is added as a build dependency to use it for libgomp
  depends_on "gcc" => :build
  depends_on "libomp"
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "zlib"
  depends_on "flex"
  depends_on "bison"
  depends_on "proj"
  depends_on "gdal"
  depends_on "python"
  depends_on "lbzip2"

  depends_on "mesa"
  depends_on "mesalib-glw"
  
  # Optional dependencies

  depends_on "pdal"
  depends_on "zstd"
  depends_on "fftw"
  depends_on "geos"
  depends_on "lapack"
  depends_on "netcdf"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "readline"
  depends_on "mysql" => :recommended
  depends_on "postgresql@14" => :recommended # we should use postgresql@14 instead of this
  depends_on "sqlite"
  depends_on "unixodbc"
  depends_on "r"
  depends_on "freetype"
  depends_on "wxpython"
  depends_on "wxwidgets"
  depends_on "numpy"
  # depends_on "liblas" # Error: liblas has been disabled because it is not supported upstream!
  depends_on "ffmpeg"
  depends_on "cairo"

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/4c/c4/13b4776ea2d76c115c1d1b84579f3764ee6d57204f6be27119f13a61d0a9/python-dateutil-2.8.2.tar.gz"
    sha256 "0123cacc1627ae19ddf3c27a5de5bd67ee4586fbdd6440d9748f8abb483d3e86"
  end

  resource "python-six" do
    url "https://files.pythonhosted.org/packages/71/39/171f1c67cd00715f190ba0b100d606d440a28c93c7714febeca8b79af85e/six-1.16.0.tar.gz"
    sha256 "1e61c37477a1626458e36f7b1d82aa5c9b094fa4802892072e49de9c60c4c926"
  end

  resource "python-matplotlib" do
    url "https://files.pythonhosted.org/packages/02/81/e8276ec6ca005b3b2bfaaad0ea47dbb3a0e389ec8ab87d08e3ccbe4b2742/matplotlib-3.5.3.tar.gz"
    sha256 "339cac48b80ddbc8bfd05daae0a3a73414651a8596904c2a881cfd1edb65f26c"
  end

  resource "python-ply" do
    url "https://files.pythonhosted.org/packages/e5/69/882ee5c9d017149285cab114ebeab373308ef0f874fcdac9beb90e0ac4da/ply-3.11.tar.gz"
    sha256 "00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3"
  end

  resource "python-termcolor" do
    url "https://files.pythonhosted.org/packages/b8/99/18ae745be732ad1cdb0cab8b63848fe6f3ba813e1324c6a689182e527083/termcolor2-0.0.3.tar.gz"
    sha256 "63ad2eaf1801c919cbeca60a62c099b330338740c8cc4422717b236f3c8f98a7"
  end

  resource "python-pillow" do
    url "https://files.pythonhosted.org/packages/8c/92/2975b464d9926dc667020ed1abfa6276e68c3571dcb77e43347e15ee9eed/Pillow-9.2.0.tar.gz"
    sha256 "75e636fd3e0fb872693f23ccb8a5ff2cd578801251f3a4f6854c6a5d437d3c04"
  end

  def majmin_ver
    ver_split = version.to_s.split(".")
    ver_split[0] + ver_split[1]
  end

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    # https://rubydoc.brew.sh/Formula.html#std_configure_args-instance_method
    flags = [
      "--with-cxx",
      "--enable-shared",
      "--enable-largefile",
      "--with-nls",
      "--with-includes=#{HOMEBREW_PREFIX}/include",
      "--with-libs=#{HOMEBREW_PREFIX}/LIB",
      # "--with-python=#{libexec}/vendor/bin/python-config",
      "--with-tcltk",
      "--with-netcdf=#{Formula["netcdf"].opt_bin}/nc-config",
      "--with-zstd",
      "--with-zstd-includes=#{Formula["zstd"].opt_include}",
      "--with-zstd-libs=#{Formula["zstd"].opt_lib}",
      "--with-readline",
      "--with-readline-includes=#{Formula["readline"].opt_include}",
      "--with-readline-libs=#{Formula["readline"].opt_lib}",
      "--with-blas",
      "--with-blas-includes=#{Formula["openblas"].opt_include}",
      "--with-blas-libs=#{Formula["openblas"].opt_lib}",
      "--with-lapack",
      "--with-lapack-includes=#{Formula["lapack"].opt_include}",
      "--with-lapack-libs=#{Formula["lapack"].opt_lib}",
      "--with-geos=#{Formula["geos"].opt_bin}/geos-config",
      "--with-geos-includes=#{Formula["geos"].opt_include}",
      "--with-geos-libs=#{Formula["geos"].opt_lib}",
      "--with-odbc",
      "--with-odbc-includes=#{Formula["unixodbc"].opt_include}",
      "--with-odbc-libs=#{Formula["unixodbc"].opt_lib}",
      "--with-gdal=#{Formula["gdal"].opt_bin}/gdal-config",
      "--with-zlib-includes=#{Formula["zlib"].opt_include}",
      "--with-zlib-libs=#{Formula["zlib"].opt_lib}",
      "--with-bzlib",
      "--with-bzlib-includes=#{Formula["bzip2"].opt_include}",
      "--with-bzlib-libs=#{Formula["bzip2"].opt_lib}",
      "--with-cairo",
      "--with-cairo-includes=#{Formula["cairo"].opt_include}/cairo",
      "--with-cairo-libs=#{Formula["cairo"].opt_lib}",
      "--with-cairo-ldflags=-lfontconfig",
      "--with-freetype",
      "--with-freetype-includes=#{Formula["freetype"].opt_include}/freetype2",
      "--with-freetype-libs=#{Formula["freetype"].opt_lib}",
      "--with-proj-includes=#{Formula["proj"].opt_include}",
      "--with-proj-libs=#{Formula["proj"].opt_lib}",
      "--with-proj-share=#{Formula["proj"].opt_share}/proj",
      "--with-tiff",
      "--with-pdal=#{Formula["pdal"].opt_bin}/pdal-config",
      "--with-tiff-includes=#{Formula["libtiff"].opt_include}",
      "--with-tiff-libs=#{Formula["libtiff"].opt_lib}",
      "--with-png",
      "--with-png-includes=#{Formula["libpng"].opt_include}",
      "--with-png-libs=#{Formula["libpng"].opt_lib}",
      "--with-regex",
      # "--with-regex-includes=#{Formula["regex-opt"].opt_lib}",
      # "--with-regex-libs=#{Formula["regex-opt"].opt_lib}",
      "--with-fftw",
      "--with-fftw-includes=#{Formula["fftw"].opt_include}",
      "--with-fftw-libs=#{Formula["fftw"].opt_lib}",
      "--with-sqlite",
      "--with-sqlite-includes=#{Formula["sqlite"].opt_include}",
      "--with-sqlite-libs=#{Formula["sqlite"].opt_lib}",
      "--with-mysql",
      "--with-mysql-includes=#{Formula["mysql"].opt_include}/mysql",
      "--with-mysql-libs=#{Formula["mysql"].opt_lib}",
      "--with-postgres",
      "--with-postgres-includes=#{Formula["postgresql"].opt_include}",
      "--with-postgres-libs=#{Formula["postgresql"].opt_lib}",
      # Error: liblas has been disabled because it is not supported upstream!
      # "--with-liblas",
      # "--with-liblas-includes=#{Formula["liblas"].opt_include}",
      # "--with-liblas-libs=#{Formula["liblas"].opt_lib}",
      "--with-opengl=macosx",
      "--with-opencl",
      "--with-openmp",
      "--with-openmp-includes=#{Formula["libomp"].opt_include}",
      "--with-openmp-libs=#{Formula["gcc"].opt_lib}/gcc/current",
      "--enable-macosx-app",
    ]

    flags << "--with-pthread"
    flags << "--with-pthread-includes=#{Formula["boost"].opt_include}/boost/thread"
    flags << "--with-pthread-libs=#{Formula["boost"].opt_lib}"


    flags << "--with-macosx-sdk=#{MacOS.sdk_path}"
    flags << "--with-opengl-includes=#{MacOS.sdk_path}/System/Library/Frameworks/OpenGL.framework/Headers"
    flags << "--with-opengl-framework=#{MacOS.sdk_path}/System/Library/Frameworks/OpenGL.framework"
    flags << "--with-opencl-includes=#{MacOS.sdk_path}/System/Library/Frameworks/OpenCL.framework/Versions/Current/Headers"
    flags << "--with-opencl-libs=#{MacOS.sdk_path}/System/Library/Frameworks/OpenCL.framework/Versions/Current/Headers"

    
    # ENV["LC_ALL"] = "C" is this what we want?
    # ENV["CFLAGS"] = "-L/Library/Developer/CommandLineTools/SDKs/MacOSX12.sdk/System/Library/Frameworks/OpenGL.framework/Headers"g

    resource("python-six").stage { system "python", *Language::Python.setup_install_args(libexec/"vendor") }
    
    system "./configure", "--prefix=#{prefix}", *flags
    # system "./configure", "--prefix=#{env['HOME']}/Applications", *flags

    system "sed", "-ibak", "s|/Library|~/Library|g", "macosx/Makefile"
    
    system "make", "-j", Hardware::CPU.cores
    system "make", "-j", Hardware::CPU.cores, "install"

    post_install
  end

  def post_install
    # ensure python3 is used
    # for some reason, in this build (v7.6.1_1), the script is not created.
    # bin.env_script_all_files("#{libexec}/bin", :GRASS_PYTHON => "python3")
    # for this reason we move the binary and create another that will call
    # this with the requirements mentioned above.
    # mkdir "#{libexec}/bin"
    # # mv "#{bin}/grass/#{majmin_ver}/GRASS-#{majmin_ver}.app/Contents/MacOS/GRASS", "#{libexec}/bin/grass#{majmin_ver}"
    # grass_macos_app = Dir["#{bin}/grass/#{majmin_ver}/GRASS*.app"]
    grass_macos_app = Dir["#{prefix}/GRASS*.app"][0]
    # cp "#{grass_macos_app}/Contents/MacOS/GRASS", "#{libexec}/bin/grass#{majmin_ver}"
    
    # # And fix "ValueError: unknown locale: UTF-8"
    # # if exist: rm "#{bin}/grass#{majmin_ver}"
    File.open("#{grass_macos_app}/Contents/MacOS/grass.sh", "w") { |file|
      file << '#!/bin/bash'
      file << "\n"
      file << "export LANG=en_US.UTF-8\n"
      file << "export LC_CTYPE=en_US.UTF-8\n"
      file << "export LC_ALL=en_US.UTF-8\n"
      
      file << "app_dir=\"$(cd \"$(dirname \"$0\")/../..\"; pwd -P)\"\n"
      
      file << "trap \"echo 'User break!' ; exit\" 2 3 9 15\n"
      file << "export GISBASE=$app_dir/Contents/MacOS\n"
      file << "grass_ver=$(cut -d . -f 1-2 \"$GISBASE/etc/VERSIONNUMBER\")\n"
      file << "export GISBASE_USER=\"$HOME/Library/GRASS/$grass_ver\"\n"
      file << "export GISBASE_SYSTEM=\"/Library/GRASS/$grass_ver\"\n"
      
      file << "mkdir -p \"$GISBASE_USER/Addons/bin\"\n"
      file << "mkdir -p \"$GISBASE_USER/Addons/scripts\"\n"

      file << "if [ ! \"$GRASS_ADDON_BASE\" ] ; then\n"
      file << "GRASS_ADDON_BASE=\"$GISBASE_USER/Addons\"\n"
      file << "fi\n"

      file << "export GRASS_ADDON_BASE\n"

      file << "mkdir -p \"$GISBASE_USER/Addons/etc\"\n"
      file << "addpath=\"$GISBASE_USER/Addons/etc:$GISBASE_SYSTEM/Addons/etc\"\n"

      file << "if [ \"$GRASS_ADDON_ETC\" ] ; then\n"
      file << "GRASS_ADDON_ETC=\"$GRASS_ADDON_ETC:$addpath\"\n"
      file << "else\n"
      file << "GRASS_ADDON_ETC=\"$addpath\"\n"
      file << "fi\n"
      file << "export GRASS_ADDON_ETC\n"

      file << "mkdir -p \"$GISBASE_USER/Addons/lib\"\n"

      file << "mkdir -p \"$GISBASE_USER/Addons/lib\"\n"
      file << "mkdir -p \"$GISBASE_USER/Addons/docs/html\"\n"

      file << "\"$app_dir/Contents/MacOS/etc/build_html_user_index.sh\" \"$GISBASE\"\n"
      file << "\"$app_dir/Contents/MacOS/etc/build_gui_user_menu.sh\"\n"

      file << "if [ ! \"$GRASS_FONT_CAP\" ] ; then\n"
      file << "GRASS_FONT_CAP=\"$GISBASE_USER/Addons/etc/fontcap\"\n"
      file << "fi\n"
      file << "export GRASS_FONT_CAP\n"

      file << "export GDAL_DATA=\"$GISBASE/share/gdal\"\n"

      # set Python
      file << "export GRASS_PYTHON=\"python3\"\n"

      # Add the GRASS start command
      file << "export cmd=\"$GRASS_PYTHON $GISBASE/grass --gui $@\"\n"

      # Use AppleScript to open a new terminal window and open GRASS
      file << "osascript -  \"$cmd\"  <<EOF\n"
      file << "on run argv -- argv is a list of strings\n"
      file << "tell application \"Terminal\"\n"
      file << "if not (exists window 1) then reopen\n"
      file << "activate\n"
      file << "do script (item 1 of argv) in window 1\n"
      file << "end tell\n"
      file << "end run\n"
      file << "EOF\n"
    }

    chmod("+x", "#{grass_macos_app}/Contents/MacOS/grass.sh")

    config = <<~EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
          <dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>grass.sh</string>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © 1999–2022 GRASS Development Team</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleName</key>
	<string>GRASS-#{version}</string>
	<key>CFBundleDisplayName</key>
    	<string>GRASS-#{version}</string>
	<key>CFBundleIdentifier</key>
	<string>org.osgeo.grass</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>#{version}</string>
	<key>CFBundleVersion</key>
	<string>#{version}</string>
	<key>CFBundleDocumentTypes</key>
	<array>
              <dict>
	    <key>CFBundleTypeName</key>
	    <string>GRASS Workspace File</string>
	    <key>CFBundleTypeExtensions</key>
	    <array>
	      <string>gxw</string>
	    </array>
	    <key>CFBundleTypeIconFile</key>
	    <string>GRASSDocument_gxw</string>
	  </dict>
	</array>
	<key>LSMinimumSystemVersion</key>
	<string>12.3</string>
	<key>LSHasLocalizedDisplayName</key>
	<true/>
          </dict>
        </plist>
    EOS

    File.open("#{grass_macos_app}/Contents/Info.plist", "w") do
      |file|
      file.write(config)
    end
  end

  test do
    system bin/"grass#{majmin_ver}", "--version"
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test grass`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
  end

  def caveats
    s = <<~EOS

      If it is the case that you can change the shebang at the beginning of
      the script to enforce Python 3 usage.

        \e[32m#!/usr/bin/env python\e[0m

      Should be changed into

        \e[32m#!/usr/bin/env python3\e[0m

    EOS

    if head_only?
      s += <<~EOS

      This build of GRASS has been compiled without the WxPython GUI.

      The command line tools remain fully functional.

      EOS
    end

    s += <<~EOS

    You may also symlink \e[32mGRASS.app\e[0m into \e[32m/Applications\e[0m or \e[32m~/Applications\e[0m:

    \e[32mln -Fs `find $(brew --prefix) -name "GRASS*.app"` /Applications/GRASS.app\e[0m

    EOS
    end
    s
  end
end


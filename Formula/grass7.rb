require File.expand_path("../../Requirements/grass_requirements",
                         Pathname.new(__FILE__).realpath)

class Grass7 < Formula
  include Language::Python::Virtualenv

  desc "Geographic Resources Analysis Support System"
  homepage "https://grass.osgeo.org/"

  # revision 1

  head "https://svn.osgeo.org/grass/grass/trunk"

  stable do
    url "https://grass.osgeo.org/grass74/source/grass-7.4.4.tar.gz"
    sha256 "96a39e273103f7375a670eba94fa3e5dad2819c5c5664c9aee8f145882a94e8c"

    # Patches to keep files from being installed outside of the prefix.
    # Remove lines from Makefile that try to install to /Library/Documentation.
    # no_symbolic_links
    patch :DATA

    # fix for python3: TypeError and others
    patch do
      url "https://gist.githubusercontent.com/fjperini/9480ad46cc4188ac7a72f4918e0d501b/raw/c738ee3b24b30bf439b97f4342a584829df0362b/grass7-python3.patch"
      sha256 "4c450ef3292ae347ab8d491973870bfd914aad1bf748eb83156f059bda9bc76d"
    end
  end

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    rebuild 1
    sha256 "192639b2b5c313cf61c2a8944b3cd009abd23bcb93124a0a6adbc5d35430e26d" => :mojave
    sha256 "192639b2b5c313cf61c2a8944b3cd009abd23bcb93124a0a6adbc5d35430e26d" => :high_sierra
    sha256 "192639b2b5c313cf61c2a8944b3cd009abd23bcb93124a0a6adbc5d35430e26d" => :sierra
  end

  option "without-gui", "Build without WxPython interface. Command line tools still available."
  option "with-liblas", "Build with LibLAS-with-GDAL2 support"
  option "with-aqua", "Build with experimental Aqua GUI backend."
  option "with-app", "Build GRASS.app Package"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "bison"
  depends_on "cairo"
  depends_on "flex"
  depends_on "freetype"
  depends_on "gdal2" # used: gdal2-grass7
  depends_on "gettext"
  depends_on "ghostscript" # for cartographic composer previews
  depends_on "lapack" # for GMATH library
  depends_on "lbzip2"
  depends_on "liblas-gdal2" if build.with? "liblas"
  depends_on "libtiff"
  depends_on "numpy"
  depends_on "python@2"
  depends_on "readline"
  depends_on "unixodbc"
  depends_on UnlinkedGRASS7
  depends_on "wxpython"
  depends_on "openjpeg" # for Pillow
  depends_on :x11 if build.without? "aqua" # needs to find at least X11/include/GL/gl.h
  depends_on "fftw" => :recommended
  depends_on "tcl-tk" => :recommended
  depends_on "ffmpeg" => :optional
  depends_on "mysql" => :optional
  depends_on "netcdf" => :optional
  depends_on "openblas" => :optional
  depends_on "postgresql" => :optional

  # other dependencies
  depends_on "desktop-file-utils" => :optional
  depends_on "fontconfig" => :optional
  depends_on "geos" => :optional
  depends_on "lesstif" => :optional
  depends_on "libomp" => :optional
  depends_on "libpng" => :optional
  depends_on "libpq" => :optional
  depends_on "brewsci/bio/matplotlib" => :optional
  depends_on "openssl" => :optional
  depends_on "proj" => :optional # proj-epsg/proj-nad
  depends_on "regex-opt" => :optional
  depends_on "sqlite" => :optional
  depends_on "zlib" => :optional
  depends_on "pdal" => :optional
  depends_on "gdbm" => :optional
  depends_on "ncurses" => :optional
  depends_on "swig" => :optional
  depends_on "libjpeg-turbo" => :optional
  depends_on "cfitsio" => :optional
  depends_on "mesalib-glw" => :optional
  depends_on "imagemagick" => :optional
  depends_on "xz" => :optional # lzma
  depends_on "gd" => :optional
  depends_on "libiconv" => :optional
  depends_on "veclibfort" => :optional
  depends_on "r" => :optional

  # depends_on "mariadb-connector-c"
  # depends_on "mariadb"

  def headless?
    # The GRASS GUI is based on WxPython.
    build.without? "gui"
  end

  def majmin_ver
    ver_split = version.to_s.split(".")
    ver_split[0] + ver_split[1]
  end

  # pillow and imaging
  resource "Pillow" do
    url "https://files.pythonhosted.org/packages/1b/e1/1118d60e9946e4e77872b69c58bc2f28448ec02c99a2ce456cd1a272c5fd/Pillow-5.3.0.tar.gz"
    sha256 "2ea3517cd5779843de8a759c2349a3cd8d3893e03ab47053b66d5ec6f8bc4f93"
  end

  resource "argparse" do
    url "https://files.pythonhosted.org/packages/18/dd/e617cfc3f6210ae183374cd9f6a26b20514bbb5a792af97949c5aacddf0f/argparse-1.4.0.tar.gz"
    sha256 "62b089a55be1d8949cd2bc7e0df0bddb9e028faefc8c32038cc84862aefdd6e4"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/0e/01/68747933e8d12263d41ce08119620d9a7e5eb72c876a3442257f74490da0/python-dateutil-2.7.5.tar.gz"
    sha256 "88f9287c0174266bb0d8cedd395cfba9c58e87e5ad86b2ce58859bc11be3cf02"
  end

  def install
    # ENV.append "MYSQLD_CONFIG=#{bin}/mysql_config
    # ENV.append "LDFLAGS", "-lintl -liconv -lsgemm -ldgemm -lblas -framework vecLib -framework OpenCL"

    # install python modules
    venv = virtualenv_create(libexec/'vendor', "python2")
    venv.pip_install resources

    readline = Formula["readline"]
    gettext = Formula["gettext"]

    # noinspection RubyLiteralArrayInspection
    args = [
      "--disable-debug",
      "--disable-dependency-tracking",
      "--enable-largefile",
      "--enable-shared",
      "--with-pthread",
      "--with-threads",
      "--with-cxx",
      "--with-python=#{libexec}/vendor/bin/python-config",
      "--with-blas",
      "--with-lapack",
      "--with-lapack-libs=#{Formula["lapack"].opt_lib}",
      "--with-lapack-includes=#{Formula["lapack"].opt_include}",
      "--with-sqlite",
      "--with-sqlite-includes=#{Formula["sqlite"].opt_include}",
      "--with-sqlite-libs=#{Formula["sqlite"].opt_lib}",
      "--with-odbc",
      "--with-bzlib",
      "--with-bzlib-includes=#{Formula["zlib"].opt_include}",
      "--with-bzlib-libs=#{Formula["zlib"].opt_lib}",
      "--with-geos=#{Formula["geos"].opt_bin}/geos-config",
      "--with-geos-includes=#{Formula["geos"].opt_include}",
      "--with-geos-libs=#{Formula["geos"].opt_lib}",
      "--with-proj",
      "--with-proj-includes=#{Formula["proj"].opt_include}",
      "--with-proj-libs=#{Formula["proj"].opt_lib}",
      "--with-proj-share=#{Formula["proj"].opt_share}/proj",
      "--with-png",
      "--with-png-includes=#{Formula["libpng"].opt_include}",
      "--with-png-libs=#{Formula["libpng"].opt_lib}",
      "--with-readline-includes=#{readline.opt_include}",
      "--with-readline-libs=#{readline.opt_lib}",
      "--with-readline",
      "--with-nls-includes=#{gettext.opt_include}",
      "--with-nls-libs=#{gettext.opt_lib}",
      "--with-nls",
      "--with-freetype",
      "--with-freetype-includes=#{Formula["freetype"].opt_include}/freetype2",
      "--with-freetype-libs=#{Formula["freetype"].opt_lib}",
      "--with-includes=#{gettext.opt_include}",
      "--with-tiff",
      "--with-tiff-includes=#{Formula["libtiff"].opt_include}",
      "--with-tiff-libs=#{Formula["libtiff"].opt_lib}",
      "--with-fftw",
      "--with-fftw-includes=#{Formula["fftw"].opt_include}",
      "--with-fftw-libs=#{Formula["fftw"].opt_lib}",
      "--with-motif",
      "--with-motif-libs=%{_libdir}",
      "--with-motif-includes=%{_includedir}",
      "--with-regex",
      "--with-glw",
      "--with-htmldocs",
      "--with-dbm-includes=#{Formula["gdbm"].opt_include}/gdbm",
      "--with-curses"
      # "--with-opendwg"
      # "--with-pdal=#{Formula["pdal"].opt_bin}/pdal-config"
      # "--with-openmp"
      # "--with-opencl"
      # "--with-gdal=#{Formula["gdal2"].opt_bin}/geos-config"
    ]

    # Disable some dependencies that don't build correctly on older version of MacOS
    args << "--without-fftw" if build.without? "fftw"
    args << "--with-tcltk" if build.with? "tcl-tk"

    # Enable Aqua GUI, instead of X11
    if build.with? "aqua"
      args.concat [
        "--with-opengl=aqua", # osx
        "--without-glw",
        "--without-motif"
        # "--enable-macosx-app"
      ]
    end

    unless MacOS::CLT.installed?
      # On Xcode-only systems (without the CLT), we have to help:
      args << "--with-macosx-sdk=#{MacOS.sdk_path}"
      args << "--with-opengl-includes=#{MacOS.sdk_path}/System/Library/Frameworks/OpenGL.framework/Headers"
      # args << "--with-opengl-libs=libdir"
      # args << "--with-macosx-archs=#{Hardware::CPU.universal_archs}"
    end

    if headless?
      args << "--without-wxwidgets"
    else
      wx_paths = formula_site_packages "wxpython"
      ENV.prepend("PYTHONPATH", wx_paths, File::PATH_SEPARATOR) if wx_paths
      args << "--with-wxwidgets=#{Formula["wxmac"].opt_bin}/wx-config"
    end

    # args << "--enable-64bit" if MacOS.prefer_64_bit? # NoMethodError: undefined method `prefer_64_bit?' for OS::Mac:Module
    args << "--with-macos-archs=#{MacOS.preferred_arch}"

    cairo = Formula["cairo"]
    args << "--with-cairo-includes=#{cairo.opt_include}/cairo"
    args << "--with-cairo-libs=#{cairo.opt_lib}"
    args << "--with-cairo"
    args << "--with-cairo-ldflags=-lfontconfig"

    # Database support
    if build.with? "postgresql"
      postgres = Formula["postgres"]
      args << "--with-postgres"
      args << "--with-postgres-includes=#{postgres.opt_include}"
      args << "--with-postgres-libs=#{postgres.opt_lib}"
    end

    if build.with? "mysql"
      mysql = Formula["mysql"]
      args << "--with-mysql-includes=#{mysql.opt_include}/mysql"
      args << "--with-mysql-libs=#{mysql.opt_lib}"
      args << "--with-mysql"
    end

    # other optional support
    if build.with? "openblas" # otherwise, Apple's will be found
      openblas = Formula["openblas"]
      args << "--with-blas-includes=#{openblas.opt_include}"
      args << "--with-blas-libs=#{openblas.opt_lib}"
    end

    if build.with? "liblas"
      args << "--with-liblas=#{Formula["liblas-gdal2"].opt_bin}/liblas-config"
      # args << "--with-liblas-libs=#{Formula["liblas-gdal2"].opt_lib}"
      # args << "--with-liblas-includes=#{Formula["liblas-gdal2"].opt_include}"
      # args << "--with-liblas-config=#{Formula["liblas-gdal2"].opt_bin}/liblas-config"
    end

    args << "--with-netcdf=#{Formula["netcdf"].opt_bin}/nc-config" if build.with? "netcdf"

    if build.with? "ffmpeg"
      ffmpeg = Formula["ffmpeg"]
      args << "--with-ffmpeg-includes=#{(Dir["#{ffmpeg.opt_include}/*"]).join(" ")}"
      args << "--with-ffmpeg-libs=#{ffmpeg.opt_lib}"
      args << "--with-ffmpeg"
    end

    if MacOS.version >= :el_capitan
      # handle stripping of DYLD_* env vars by SIP when passed to utilities;
      # HOME env var is .brew_home during build, so it is still checked for lib
      ln_sf "#{buildpath}/dist.x86_64-apple-darwin#{`uname -r`.strip}/lib", ".brew_home/lib"
    end

    # Patch grass.py to remove bad tab at line 1693 (and insert 12 spaces)
    # Needs to be pushed upstream.
    # inreplace "lib/init/grass.py", "\t\t\t", "            "
    # or applying the patch
    # https://github.com/OSGeo/homebrew-osgeo4mac/pull/549#issuecomment-445507239

    system "./configure", "--prefix=#{prefix}", *args
    system "make", "-j", Hardware::CPU.cores, "GDAL_DYNAMIC=" # make and make install must be separate steps.
    system "make", "-j", Hardware::CPU.cores, "GDAL_DYNAMIC=", "install" # GDAL_DYNAMIC set to blank for r.external compatability

    # ensure QGIS's Processing plugin recognizes install
    # 2.14.8+ and other newer QGIS versions may reference just grass.sh
    bin_grass = "../bin/grass#{majmin_ver}"
    ln_sf bin_grass, prefix/"grass-#{version}/grass#{majmin_ver}.sh"
    ln_sf bin_grass, prefix/"grass-#{version}/grass.sh"
    # link so settings in external apps don't need updated on grass version bump
    # in QGIS Processing options, GRASS folder = HOMEBREW_PREFIX/opt/grass7/grass-base
    ln_sf "grass-#{version}", prefix/"grass-base"
    # ensure python2 is used
    bin.env_script_all_files(libexec/"bin", :GRASS_PYTHON => "python2")

    # fix "ValueError: unknown locale: UTF-8"
    rm "#{bin}/grass#{majmin_ver}"
    File.open("#{bin}/grass#{majmin_ver}", "w") { |file|
      file << '#!/bin/bash'
      file << "\n"
      file << "export LANG=en_US.UTF-8"
      file << "\n"
      file << "export LC_CTYPE=en_US.UTF-8"
      file << "\n"
      file << "export LC_ALL=en_US.UTF-8"
      file << "\n"
      file << "GRASS_PYTHON=python2 exec #{libexec}/bin/grass#{majmin_ver} $@"
    }

    if build.with? "app"
      # This is established, until the creation of GRASS.app is reviewed
      # and corrected using: --enable-macosx-app
      mkdir "#{prefix}/GRASS.app/Contents" do
        cp "#{buildpath}/macosx/app/Info.plist.in", "Info.plist"
        cp "#{buildpath}/macosx/app/PkgInfo", "PkgInfo" # APPLGRASS
        mkdir "Resources" do
          cp "#{buildpath}/macosx/app/app.icns", "app.icns"
        end
        mkdir "MacOS" do
          ln_s "#{bin}/grass#{majmin_ver}", "grass#{majmin_ver}"
        end
      end
    end
  end

  def formula_site_packages(f)
    `python2 -c "import os, sys, site; sp1 = list(sys.path); site.addsitedir('#{Formula[f].opt_lib}/python2.7/site-packages'); print(os.pathsep.join([x for x in sys.path if x not in sp1]))"`.strip
  end

  def caveats
    s = <<~EOS
      If that is tha case you can change the shebang a the beginning of
      the script to enforce Python 2 usage.

      #!/usr/bin/env python

      Should be changed into

      #!/usr/bin/env python2

    EOS

    if headless?
      s += <<~EOS

        This build of GRASS has been compiled without the WxPython GUI.

        The command line tools remain fully functional.

      EOS
    end

    if build.with? "app"
      s += <<~EOS

        You may also symlink GRASS.app into /Applications:

        ln -Fs `find $(brew --prefix) -name "GRASS.app"` /Applications/GRASS.app

      EOS
    end
    s
  end

  test do
    system bin/"grass#{majmin_ver}", "--version"
  end
end

__END__

--- a/include/Make/Install.make
+++ b/include/Make/Install.make
@@ -114,11 +114,6 @@ real-install: | $(INST_DIR) $(UNIX_BIN)
 	-$(INSTALL) config.status $(INST_DIR)/config.status
 	-$(CHMOD) -R a+rX $(INST_DIR) 2>/dev/null

-ifneq ($(findstring darwin,$(ARCH)),)
-	@# enable OSX Help Viewer
-	@/bin/ln -sfh "$(INST_DIR)/docs/html" /Library/Documentation/Help/GRASS-$(GRASS_VERSION_MAJOR).$(GRASS_VERSION_MINOR)
-endif
-
 $(INST_DIR) $(UNIX_BIN):
 	$(MAKE_DIR_CMD) $@

--- a/macosx/app/build_html_user_index.sh
+++ b/macosx/app/build_html_user_index.sh
@@ -140,7 +140,6 @@ else
 #      echo "<tr><td valign=\"top\"><a href=\"$HTMLDIRG/$i\">$BASENAME</a></td> <td>$SHORTDESC</td></tr>" >> $FULLINDEX
       # make them local to user to simplify page links
       echo "<tr><td valign=\"top\"><a href=\"global_$i\">$BASENAME</a></td> <td>$SHORTDESC</td></tr>" >> $FULLINDEX
-      ln -sf "$HTMLDIRG/$i" global_$i
     done
   done
 fi
@@ -183,8 +182,3 @@ echo "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">
 </html>" > $i.html
 done

-# add Help Viewer links in user docs folder
-
-mkdir -p $HOME/Library/Documentation/Help/
-ln -sfh ../../GRASS/$GRASS_MMVER/Modules/docs/html $HOME/Library/Documentation/Help/GRASS-$GRASS_MMVER-addon
-ln -sfh $GISBASE/docs/html $HOME/Library/Documentation/Help/GRASS-$GRASS_MMVER

class JavaJDK < Requirement
  fatal true

  def self.home
    [
      `/usr/libexec/java_home`.chomp!,
      ENV["JAVA_HOME"],
    ].find do |dir|
      dir && File.exist?("#{dir}/bin/javac") && (File.exist?("#{dir}/include") || File.exist?("#{dir}/bundle"))
    end
  end

  satisfy :build_env => false do
    self.class.home
  end

  def message; <<~EOS
    Could not find a JDK (i.e. not a JRE)

    Do one of the following:
    - install a JDK that is detected with /usr/libexec/java_home
    - set the JAVA_HOME environment variable
    - specify --without-java

  EOS
  end
end

class Mapserver6 < Formula
  desc "Publish spatial data and interactive mapping apps to the web"
  homepage "http://mapserver.org/"
  url "http://download.osgeo.org/mapserver/mapserver-6.4.5.tar.gz"
  sha256 "b62c5c0cce2ea7da1d70553197926c14ef46bfb030a736e588367fc881b01a9a"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    rebuild 2
    sha256 "d49321a497cc7b0826ff2febf8147dfd9428a991a45cdb1e3f2f81e0e1634d44" => :high_sierra
    sha256 "d49321a497cc7b0826ff2febf8147dfd9428a991a45cdb1e3f2f81e0e1634d44" => :sierra
  end

  # Backport patch to support compiling with gif_lib >= 5.1: https://github.com/mapserver/mapserver/pull/5144
  # Also applies a patch to build on versions of PHP5 > 5.6.25: https://github.com/mapserver/mapserver/pull/5318
  patch :DATA

  conflicts_with "mapserver", :because => "Homebrew core includes newer version of mapserver"

  option "without-php", "Build PHP MapScript module"
  option "with-rpath", "Don't embed rpath to installed libmapserver in modules"
  option "without-geos", "Build without GEOS spatial operations support"
  option "without-postgresql", "Build without PostgreSQL data source support"
  option "without-xml-mapfile", "Build with native XML mapfile support"
  option "with-java", "Build Java MapScript module"
  option "with-librsvg", "Build with SVG symbology support"
  option "with-docs", "Download and generate HTML documentation"
  option "with-unit-tests", "Download and install full unit test suite"

  depends_on "cmake" => :build
  depends_on "freetype"
  depends_on "libpng"
  depends_on "python@2"
  depends_on "swig" => :build
  depends_on :java => :optional
  depends_on "giflib"
  depends_on "osgeo-proj"
  depends_on "geos" => :recommended
  depends_on "gdal"
  depends_on "osgeo-postgresql" => :recommended
  depends_on "mysql" => :optional
  depends_on "fcgi" => :recommended
  depends_on "cairo" => :recommended
  depends_on "libxml2" if build.with?("xml-mapfile") || MacOS.version < :mountain_lion
  depends_on "libxslt" if build.with? "xml-mapfile"
  depends_on "librsvg" => :optional
  depends_on "fribidi"
  depends_on "python@2" => %w[sphinx] if build.with? "docs"
  depends_on "php@5.6" if build.with? "php"
  depends_on "perl"

  resource "sphinx" do
    url "https://files.pythonhosted.org/packages/source/S/Sphinx/Sphinx-1.2.2.tar.gz"
    sha256 "2d3415f5b3e6b7535877f4c84fe228bdb802a8993c239b2d02c23169d67349bd"
  end

  resource "docs" do
    # NOTE: seems to be no tagged releases for `docs`, just active branches
    url "https://github.com/mapserver/docs.git", :branch => "branch-6-4"
    version "6.4"
  end

  resource "unittests" do
    url "https://github.com/mapserver/msautotest.git",
        :revision => "b0ba5ccbfb6b0395820f492eb5a190cf643b5ed8"
    version "6.4"
  end

  def png_prefix
    png = Formula["libpng"]
    (png.installed? || MacOS.version >= :mountain_lion) ? png.opt_prefix : MacOS::X11.prefix
  end

  def freetype_prefix
    ft = Formula["freetype"]
    (ft.installed? || MacOS.version >= :mountain_lion) ? ft.opt_prefix : MacOS::X11.prefix
  end

  def install
    # install unit tests
    (prefix/"msautotest").install resource("unittests") if build.with? "unit-tests"

    ENV.prepend_path "CMAKE_PREFIX_PATH", freetype_prefix
    ENV.prepend_path "CMAKE_PREFIX_PATH", png_prefix

    args = std_cmake_args
    if MacOS.prefer_64_bit?
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch_64_bit}"
    else
      args << "-DCMAKE_OSX_ARCHITECTURES=i386"
    end

    # defaults different than CMakeLists.txt (they don't incur extra dependencies)
    args.concat %w[
      -DWITH_KML=ON
      -DWITH_CURL=ON
      -DWITH_CLIENT_WMS=ON
      -DWITH_CLIENT_WFS=ON
      -DWITH_SOS=ON
    ]

    args << "-DWITH_XMLMAPFILE=ON" if build.with? "xml-mapfile"
    args << "-DWITH_MYSQL=ON" if build.with? "mysql"
    args << "-DWITH_RSVG=ON" if build.with? "librsvg"

    glib = Formula["glib"]
    fribidi = Formula["fribidi"]
    args << "-DFRIBIDI_INCLUDE_DIR=#{glib.opt_include}/glib-2.0;#{glib.opt_lib}/glib-2.0/include;#{fribidi.opt_include}"

    mapscr_dir = prefix/"mapscript"
    mapscr_dir.mkpath
    rpath = %Q(-Wl,-rpath,"#{opt_prefix/"lib"}")
    use_rpath = build.with? "rpath"
    cd "mapscript" do
      args << "-DWITH_PYTHON=ON"
      inreplace "python/CMakeLists.txt" do |s|
        s.gsub! "${PYTHON_SITE_PACKAGES}", lib/"python2.7/site-packages"
        s.gsub! "${PYTHON_LIBRARIES}", "-Wl,-undefined,dynamic_lookup"
        s.sub! "${MAPSERVER_LIBMAPSERVER}",
               "#{rpath} ${MAPSERVER_LIBMAPSERVER}" if use_rpath
      end

      # override language extension install locations, e.g. install to prefix/"mapscript/lang"
      args << "-DWITH_RUBY=ON"
      (mapscr_dir/"ruby").mkpath
      inreplace "ruby/CMakeLists.txt" do |s|
        s.gsub! "${RUBY_SITEARCHDIR}", %Q("#{mapscr_dir}/ruby")
        s.sub! "${MAPSERVER_LIBMAPSERVER}",
               "#{rpath} ${MAPSERVER_LIBMAPSERVER}" if use_rpath
      end

      if build.with? "php"
        args << "-DWITH_PHP=ON"
        (mapscr_dir/"php").mkpath
        inreplace "php/CMakeLists.txt" do |s|
          s.gsub! "${PHP5_EXTENSION_DIR}", %Q("#{mapscr_dir}/php")
          s.sub! "${MAPSERVER_LIBMAPSERVER}",
                 "#{rpath} ${MAPSERVER_LIBMAPSERVER}" if use_rpath
        end
      end

      args << "-DWITH_PERL=ON"
      (mapscr_dir/"perl").mkpath
      args << "-DCUSTOM_PERL_SITE_ARCH_DIR=#{mapscr_dir}/perl"
      inreplace "perl/CMakeLists.txt", "${MAPSERVER_LIBMAPSERVER}",
                "#{rpath} ${MAPSERVER_LIBMAPSERVER}" if use_rpath

      if build.with? "java"
        args << "-DWITH_JAVA=ON"
        ENV["JAVA_HOME"] = JavaJDK.home
        (mapscr_dir/"java").mkpath
        inreplace "java/CMakeLists.txt" do |s|
          s.gsub!  "DESTINATION ${CMAKE_INSTALL_LIBDIR}",
                  %Q(${CMAKE_CURRENT_BINARY_DIR}/mapscript.jar DESTINATION "#{mapscr_dir}/java")
          s.sub! "${MAPSERVER_LIBMAPSERVER}",
                 "#{rpath} ${MAPSERVER_LIBMAPSERVER}" if use_rpath
        end
      end
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end

#    MachO::Tools.change_install_name(lib/"python2.7/site-packages/_mapscript.so",
#                                     "@rpath/libmapserver.1.dylib", opt_lib/"libmapserver.1.dylib")

#    system "install_name_tool", "-change",
#           "@rpath/libmapserver.1.dylib", opt_lib/"libmapserver.1.dylib",
#           lib/"python2.7/site-packages/_mapscript.so"

    # install devel headers
    (include/"mapserver").install Dir["*.h"]

    prefix.install "tests"
    (mapscr_dir/"python").install "mapscript/python/tests"
    cd "mapscript" do
      %w[python ruby perl].each { |x| (mapscr_dir/x.to_s).install "#{x}/examples" }
      (mapscr_dir/"php").install "php/examples" if build.with? "php"
      (mapscr_dir/"java").install "java/examples" if build.with? "java"
    end

    # write install instructions for modules
    s = ""
    mapscr_opt_dir = opt_prefix/"mapscript"
    if build.with? "php"
      s += <<~EOS
        Using the built PHP module:
          * Add the following line to php.ini:
            extension="#{mapscr_opt_dir}/php/php_mapscript.so"
          * Execute "php -m"
          * You should see MapScript in the module list

      EOS
    end
    %w[ruby perl java].each do |m|
      next if build.without?(m)

      cmd = []
      case m
      when "ruby"
        ruby_site = `ruby -r rbconfig -e 'puts RbConfig::CONFIG["sitearchdir"]'`.chomp
        cmd << "sudo cp -f mapscript.bundle #{ruby_site}/"
      when "perl"
        perl_site = `perl -MConfig -e 'print $Config{"sitearch"};'`.chomp
        cmd << "sudo cp -f mapscript.pm #{perl_site}/"
        cmd << "sudo cp -fR auto/mapscript #{perl_site}/auto/"
      else
        cmd << "sudo cp -f libjavamapscript.jnilib mapscript.jar /Library/Java/Extensions/"
      end
      s += <<~EOS
        Install the built #{m.upcase} module with:
          cd #{mapscr_opt_dir}/#{m}
          #{cmd[0]}
          #{cmd[1] + "\n" if cmd[1]}
      EOS
    end
    (mapscr_dir/"Install_Modules.txt").write s

    if build.with? "docs"
      unless which("sphinx-build")
        # vendor a local sphinx install
        sphinx_site = libexec/"lib/python2.7/site-packages"
        ENV.prepend_create_path "PYTHONPATH", sphinx_site
        resource("sphinx").stage { quiet_system "python2.7", "setup.py", "install", "--prefix=#{libexec}" }
        ENV.prepend_path "PATH", libexec/"bin"
      end
      resource("docs").stage do
        # just build the en docs
        inreplace "Makefile", "$(TRANSLATIONS_I18N) $(TRANSLATIONS_STATIC)", ""
        system "make", "html"
        doc.install "build/html" => "html"
      end
    end
  end

  def caveats; <<~EOS
    The Mapserver CGI executable is #{opt_prefix}/bin/mapserv

    Instructions for installing any built, but uninstalled, mapscript modules:
      #{opt_prefix}/mapscript/Install_Modules.txt

    EOS
  end

  test do
    mapscr_opt_dir = opt_prefix/"mapscript"
    system "#{bin}/mapserv", "-v"
    system "python2.7", "-c", '"import mapscript"'
    system "ruby", "-e", "\"require '#{mapscr_opt_dir}/ruby/mapscript'\""
    system "perl", "-I#{mapscr_opt_dir}/perl", "-e", '"use mapscript;"'

    cd "#{mapscr_opt_dir}/java/examples" do
      system "#{JavaJDK.home}/bin/javac",
             "-classpath", "../", "-Djava.ext.dirs=../", "RFC24.java"
      system "#{JavaJDK.home}/bin/java",
             "-classpath", "../", "-Djava.library.path=../", "-Djava.ext.dirs=../",
             "RFC24", "../../../tests/test.map"
    end if build.with? "java"
  end

end
__END__
diff --git a/mapimageio.c b/mapimageio.c
index 35d134f..eb63aa3 100644
--- a/mapimageio.c
+++ b/mapimageio.c
@@ -1307,6 +1307,12 @@ int readGIF(char *path, rasterBufferObj *rb)

   } while (recordType != TERMINATE_RECORD_TYPE);

+#if defined GIFLIB_MAJOR && GIFLIB_MINOR && ((GIFLIB_MAJOR == 5 && GIFLIB_MINOR >= 1) || (GIFLIB_MAJOR > 5))
+  if (DGifCloseFile(image, &errcode) == GIF_ERROR) {
+    msSetError(MS_MISCERR,"failed to close gif after loading: %s","readGIF()", gif_error_msg(errcode));
+    return MS_FAILURE;
+  }
+#else
   if (DGifCloseFile(image) == GIF_ERROR) {
 #if defined GIFLIB_MAJOR && GIFLIB_MAJOR >= 5
     msSetError(MS_MISCERR,"failed to close gif after loading: %s","readGIF()", gif_error_msg(image->Error));
@@ -1315,6 +1321,7 @@ int readGIF(char *path, rasterBufferObj *rb)
 #endif
     return MS_FAILURE;
   }
+#endif

   return MS_SUCCESS;
 }
diff --git a/mapscript/php/error.c b/mapscript/php/error.c
index a13de647f..2e96eea27 100644
--- a/mapscript/php/error.c
+++ b/mapscript/php/error.c
@@ -31,6 +31,17 @@
 
 #include "php_mapscript.h"
 
+#if PHP_VERSION_ID >= 50625
+#undef ZVAL_STRING
+#define ZVAL_STRING(z, s, duplicate) do {       \
+    const char *__s=(s);                            \
+    zval *__z = (z);                                        \
+    Z_STRLEN_P(__z) = strlen(__s);          \
+    Z_STRVAL_P(__z) = (duplicate?estrndup(__s, Z_STRLEN_P(__z)):(char*)__s);\
+    Z_TYPE_P(__z) = IS_STRING;                      \
+} while (0)
+#endif
+
 zend_class_entry *mapscript_ce_error;
 
 ZEND_BEGIN_ARG_INFO_EX(error___get_args, 0, 0, 1)

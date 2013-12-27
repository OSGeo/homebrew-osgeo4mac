require 'formula'

class Mapserver64 < Formula
  homepage 'http://mapserver.org/'
  url 'http://download.osgeo.org/mapserver/mapserver-6.4.0.tar.gz'
  sha1 '8af4883610091de7ba374ced2564ed90ca2faa5b'

  head do
    url 'https://github.com/mapserver/mapserver.git', :branch => 'master'
    depends_on 'harfbuzz'
    depends_on 'v8' => :optional
  end

  conflicts_with 'mapserver', :because => 'mapserver is in main tap'

  option 'with-php', 'Build PHP MapScript module'
  option 'with-java', 'Build Java MapScript module'
  option 'without-rpath', "Don't embed rpath to installed libmapserver in modules"
  option 'with-gd', 'Build with GD support (deprecated)' unless build.head?
  option 'with-librsvg', 'Build with SVG symbology support'
  option 'without-geos', 'Build without GEOS spatial operations support'
  option 'without-postgresql', 'Build without PostgreSQL data source support'
  option 'with-docs', 'Download and generate HTML documentation'

  depends_on 'cmake' => :build
  depends_on :freetype
  depends_on :fontconfig
  depends_on :libpng
  depends_on :python
  depends_on 'swig' => :build
  depends_on 'giflib'
  depends_on 'gd' => [:optional, 'with-freetype'] unless build.head?
  depends_on 'proj'
  depends_on 'geos' => :recommended
  depends_on 'gdal'
  depends_on :postgresql => :recommended
  depends_on :mysql => :optional
  depends_on 'fcgi' => :recommended
  depends_on 'cairo' => :recommended
  depends_on 'libxml2' unless MacOS.version >= :mountain_lion
  depends_on 'librsvg' => :optional
  depends_on 'fribidi'
  depends_on :python => %w[sphinx] if build.with? 'docs'

  resource 'docs' do
    # NOTE: seems to be no tagged releases for `docs`, just active branches
    url 'https://github.com/mapserver/docs.git', :branch => 'branch-6-4'
    version '6.4'
  end

  # fix ruby module's output suffix and cmake modules
  # see: https://github.com/mapserver/mapserver/pull/4826
  #      https://github.com/mapserver/mapserver/pull/4833
  def patches
    DATA
  end

  def png_prefix
    png = Formula.factory('libpng')
    (png.installed? or MacOS.version >= :mountain_lion) ? png.opt_prefix : MacOS::X11.prefix
  end

  def freetype_prefix
    ft = Formula.factory('freetype')
    (ft.installed? or MacOS.version >= :mountain_lion) ? ft.opt_prefix : MacOS::X11.prefix
  end

  def fontconfig_prefix
    fc = Formula.factory('fontconfig')
    (fc.installed? or MacOS.version >= :mountain_lion) ? fc.opt_prefix : MacOS::X11.prefix
  end

  def install
    ENV.prepend_path 'CMAKE_PREFIX_PATH', freetype_prefix
    ENV.prepend_path 'CMAKE_PREFIX_PATH', fontconfig_prefix
    ENV.prepend_path 'CMAKE_PREFIX_PATH', png_prefix

    args = std_cmake_args
    if MacOS.prefer_64_bit?
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch_64_bit}"
    else
      args << '-DCMAKE_OSX_ARCHITECTURES=i386'
    end

    # defaults different than CMakeLists.txt (they don't incur extra dependencies)
    args.concat %W[
      -DWITH_KML=ON
      -DWITH_CURL=ON
      -DWITH_CLIENT_WMS=ON
      -DWITH_CLIENT_WFS=ON
      -DWITH_SOS=ON
    ]

    args << '-DWITH_MYSQL=ON' if build.with? 'mysql'
    args << '-DWITH_GD=ON' if build.with? 'gd' && !build.head?
    args << '-DWITH_RSVG=ON' if build.with? 'librsvg'

    mapscr_dir = prefix/'mapscript'
    mapscr_dir.mkpath
    rpath = %Q{-Wl,-rpath,"#{opt_prefix/'lib'}"}
    use_rpath = build.with? 'rpath' && HOMEBREW_PREFIX != '/usr/local'
    cd 'mapscript' do
      args << '-DWITH_PYTHON=ON'
      inreplace 'python/CMakeLists.txt' do |s|
        s.gsub! '${PYTHON_SITE_PACKAGES}', %Q{"#{lib/python.xy/'site-packages'}"}
        s.sub! '${MAPSERVER_LIBMAPSERVER}',
               "#{rpath} ${MAPSERVER_LIBMAPSERVER}" if use_rpath
      end

      # override language extension install locations, e.g. install to prefix/'mapscript/lang'
      args << '-DWITH_RUBY=ON'
      (mapscr_dir/'ruby').mkpath
      # TODO: remove this conditional on next release
      site_arch = (build.head?) ? '${RUBY_SITEARCHDIR}' : '${RUBY_ARCHDIR}'
      inreplace 'ruby/CMakeLists.txt' do |s|
        s.gsub! site_arch, %Q{"#{mapscr_dir}/ruby"}
        s.sub! '${MAPSERVER_LIBMAPSERVER}',
               "#{rpath} ${MAPSERVER_LIBMAPSERVER}" if use_rpath
      end

      if build.with? 'php'
        args << '-DWITH_PHP=ON'
        (mapscr_dir/'php').mkpath
        inreplace 'php/CMakeLists.txt' do |s|
          s.gsub! '${PHP5_EXTENSION_DIR}', %Q{"#{mapscr_dir}/php"}
          s.sub! '${MAPSERVER_LIBMAPSERVER}',
                 "#{rpath} ${MAPSERVER_LIBMAPSERVER}" if use_rpath
        end
      end

      args << '-DWITH_PERL=ON'
      (mapscr_dir/'perl').mkpath
      args << "-DCUSTOM_PERL_SITE_ARCH_DIR=#{mapscr_dir}/perl"
      inreplace 'perl/CMakeLists.txt', '${MAPSERVER_LIBMAPSERVER}',
                "#{rpath} ${MAPSERVER_LIBMAPSERVER}" if use_rpath

      if build.with? 'java'
        args << '-DWITH_JAVA=ON'
        # TODO: this is NOT adequate to set up Java paths
        ENV['JAVA_HOME'] = `/usr/libexec/java_home`.chomp!
        (mapscr_dir/'java').mkpath
        # TODO: remove this conditional on next release
        lib_dir = (build.head?) ? '${CMAKE_INSTALL_LIBDIR}' : 'lib'
        inreplace 'java/CMakeLists.txt' do |s|
          s.gsub! "DESTINATION #{lib_dir}", %Q{DESTINATION "#{mapscr_dir}/java"}
          s.sub! '${MAPSERVER_LIBMAPSERVER}',
                 "#{rpath} ${MAPSERVER_LIBMAPSERVER}" if use_rpath
        end
      end
    end

    mkdir 'build' do
      #python do
        system 'cmake', '..', *args
        system 'bbedit', 'CMakeCache.txt'
        raise
        system 'make install'
      #end
    end

    # install devel headers
    # TODO: not quite sure which of these headers are unnecessary to copy
    (include/'mapserver').install Dir['*.h']

    # write install instructions for modules
    s = ''
    mapscr_dir = opt_prefix/'mapscript'
    if build.with? 'php'
      s += <<-EOS.undent
        Using the built PHP module:
          * Add the following line to php.ini:
            extension="#{mapscr_dir}/php/php_mapscript.so"
          * Execute "php -m"
          * You should see MapScript in the module list

      EOS
    end
    %w[ruby perl java].each do |m|
      if build.with? m
        cmd = []
        case m
          when 'ruby'
            ruby_site = %x[ruby -r rbconfig -e 'puts RbConfig::CONFIG["sitearchdir"]'].chomp
            cmd << "sudo cp -f mapscript.bundle #{ruby_site}/"
          when 'perl'
            perl_site = %x[perl -MConfig -e 'print $Config{"sitearch"};'].chomp
            cmd << "sudo cp -f mapscript.pm #{perl_site}/"
            cmd << "sudo cp -fR auto/mapscript #{perl_site}/auto/"
          when 'java'
            cmd << 'sudo cp -f libjavamapscript.jnilib /Library/Java/Extensions/'
        end
        s += <<-EOS.undent
          Install the built #{m.upcase} module with:
            cd #{mapscr_dir}/#{m}
            #{cmd[0]}
            #{cmd[1] + "\n" if cmd[1]}
        EOS
      end
    end
    (prefix/'Install_Modules.txt').write s unless s.empty?

    if build.with? 'docs'
      resource('docs').stage do
        inreplace 'Makefile', 'sphinx-build', "#{HOMEBREW_PREFIX}/bin/sphinx-build"
        system 'make', 'html'
        doc.install 'build/html' => 'html'
      end
    end
  end

  def caveats; <<-EOS.undent
      The Mapserver CGI executable is #{opt_prefix}/bin/mapserv

      Notes on installing any built mapscript modules are listed in:
        #{opt_prefix}/Install_Modules.txt

    EOS
  end

  def test
    system "#{bin}/mapserv", '-v'
    system 'python', '-c', '"import mapscript"'
    system 'ruby', '-e', "\"require '#{opt_prefix}/mapscript/ruby/mapscript'\"" if build.with? 'ruby'
    system 'perl', "-I#{opt_prefix}/mapscript/perl", '-e', '"use mapscript;"' if build.with? 'perl'
  end
end

__END__
diff --git a/mapscript/ruby/CMakeLists.txt b/mapscript/ruby/CMakeLists.txt
index 95f5982..2dc084a 100644
--- a/mapscript/ruby/CMakeLists.txt
+++ b/mapscript/ruby/CMakeLists.txt
@@ -11,6 +11,9 @@ SWIG_LINK_LIBRARIES(rubymapscript ${RUBY_LIBRARY} ${MAPSERVER_LIBMAPSERVER})

 set_target_properties(${SWIG_MODULE_rubymapscript_REAL_NAME} PROPERTIES PREFIX "")
 set_target_properties(${SWIG_MODULE_rubymapscript_REAL_NAME} PROPERTIES OUTPUT_NAME mapscript)
+if(APPLE)
+  set_target_properties(${SWIG_MODULE_rubymapscript_REAL_NAME} PROPERTIES SUFFIX ".bundle")
+endif(APPLE)

 get_target_property(LOC_MAPSCRIPT_LIB ${SWIG_MODULE_rubymapscript_REAL_NAME} LOCATION)
 execute_process(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "puts RbConfig::CONFIG['archdir']" OUTPUT_VARIABLE RUBY_ARCHDIR OUTPUT_STRIP_TRAILING_WHITESPACE)
diff --git a/cmake/FindFreetype.cmake b/cmake/FindFreetype.cmake
index edb142d..73dd42f 100644
--- a/cmake/FindFreetype.cmake
+++ b/cmake/FindFreetype.cmake
@@ -44,7 +44,7 @@
 FIND_PATH(FREETYPE_INCLUDE_DIR_ft2build ft2build.h 
   HINTS
   $ENV{FREETYPE_DIR}
-  PATH_SUFFIXES include
+  PATH_SUFFIXES include include/freetype2
   PATHS
   /usr/local/X11R6/include
   /usr/local/X11/include
@@ -54,7 +54,7 @@ FIND_PATH(FREETYPE_INCLUDE_DIR_ft2build ft2build.h
   /usr/freeware/include
 )

-FIND_PATH(FREETYPE_INCLUDE_DIR_freetype2 freetype/config/ftheader.h 
+FIND_PATH(FREETYPE_INCLUDE_DIR_freetype2 config/ftheader.h
   HINTS
   $ENV{FREETYPE_DIR}/include/freetype2
   PATHS
@@ -64,7 +64,7 @@ FIND_PATH(FREETYPE_INCLUDE_DIR_freetype2 freetype/config/ftheader.h
   /sw/include
   /opt/local/include
   /usr/freeware/include
-  PATH_SUFFIXES freetype2
+  PATH_SUFFIXES freetype freetype2
 )

 set(FREETYPE_NAMES ${FREETYPE_NAMES} freetype libfreetype freetype219 freetype239 freetype241MT_D freetype2411)
diff --git a/cmake/FindMySQL.cmake b/cmake/FindMySQL.cmake
index 1b5de7e..3bbf824 100644
--- a/cmake/FindMySQL.cmake
+++ b/cmake/FindMySQL.cmake
@@ -13,9 +13,10 @@ ENDIF (MYSQL_INCLUDE_DIR)
 FIND_PATH(MYSQL_INCLUDE_DIR mysql.h
   /usr/local/include/mysql
   /usr/include/mysql
+  PATH_SUFFIXES mysql
 )

-SET(MYSQL_NAMES mysqlclient mysqlclient_r)
+SET(MYSQL_NAMES mysqlclient mysqlclient_r libmysqlclient)
 FIND_LIBRARY(MYSQL_LIBRARY
   NAMES ${MYSQL_NAMES}
   PATHS /usr/lib /usr/local/lib

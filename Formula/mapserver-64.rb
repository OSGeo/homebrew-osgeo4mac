require 'formula'

class JavaJDK < Requirement
  fatal true

  def self.home
    [
        `/usr/libexec/java_home`.chomp!,
        ENV['JAVA_HOME']
    ].find { |dir| dir && File.exist?("#{dir}/bin/javac") &&
        (File.exist?("#{dir}/include" || File.exist?("#{dir}/bundle"))) }
  end

  satisfy :build_env => false do
    self.class.home
  end

  def message; <<-EOS.undent
    Could not find a JDK (i.e. not a JRE)

    Do one of the following:
    - install a JDK that is detected with /usr/libexec/java_home
    - set the JAVA_HOME environment variable
    - specify --without-java

  EOS
  end
end

class Mapserver64 < Formula
  homepage 'http://mapserver.org/'
  url 'http://download.osgeo.org/mapserver/mapserver-6.4.1.tar.gz'
  sha1 'f7d2e7f44cd9a4ff5d9483d21bb71c1cc28e09ab'

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
  option 'with-xml-mapfile', 'Build with native XML mapfile support'
  option 'with-docs', 'Download and generate HTML documentation'

  depends_on 'cmake' => :build
  depends_on :freetype
  depends_on :fontconfig
  depends_on :libpng
  depends_on :python
  depends_on 'swig' => :build
  depends_on JavaJDK if build.with? 'java'
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
  depends_on 'libxslt' if build.with? 'xml-mapfile' and Formula.factory('libxml2').installed?
  depends_on 'librsvg' => :optional
  depends_on 'fribidi'
  depends_on :python => %w[sphinx] if build.with? 'docs'

  resource 'docs' do
    # NOTE: seems to be no tagged releases for `docs`, just active branches
    url 'https://github.com/mapserver/docs.git', :branch => 'branch-6-4'
    version '6.4'
  end

  resource 'findjni' do
    # replacement FindJNI.cmake module to optionally work with non-Apple Java installs
    # see also: http://public.kitware.com/Bug/view.php?id=14508
    url 'https://gist.github.com/dakcarto/8201389/raw/05ddab644981ab2e86580ff1be377ef8456ab426/FindJNI.cmake'
    sha1 '14b1681d01cb08e11faa8deadf827b2ddbaabab1'
    version '2.8.12.1'
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

    args << '-DWITH_XMLMAPFILE=ON' if build.with? 'xml-mapfile'
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
      inreplace 'ruby/CMakeLists.txt' do |s|
        s.gsub! '${RUBY_SITEARCHDIR}', %Q{"#{mapscr_dir}/ruby"}
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
        (buildpath/'cmake').install resource('findjni') # override cmake's
        ENV['JAVA_HOME'] = JavaJDK.home
        (mapscr_dir/'java').mkpath
        inreplace 'java/CMakeLists.txt' do |s|
          s.gsub! 'DESTINATION ${CMAKE_INSTALL_LIBDIR}',
                  %Q|${CMAKE_CURRENT_BINARY_DIR}/mapscript.jar DESTINATION "#{mapscr_dir}/java"|
          s.sub! '${MAPSERVER_LIBMAPSERVER}',
                 "#{rpath} ${MAPSERVER_LIBMAPSERVER}" if use_rpath
        end
      end
    end

    mkdir 'build' do
      system 'cmake', '..', *args
      system 'make', 'install'
    end

    # install devel headers
    # TODO: not quite sure which of these headers are unnecessary to copy
    (include/'mapserver').install Dir['*.h']

    prefix.install 'tests'
    cd 'mapscript' do
      %w[python ruby perl].each {|x|(mapscr_dir/"#{x}").install "#{x}/examples"}
      (mapscr_dir/'php').install 'php/examples' if build.with? 'php'
      (mapscr_dir/'java').install 'java/examples' if build.with? 'java'
    end

    # write install instructions for modules
    s = ''
    mapscr_opt_dir = opt_prefix/'mapscript'
    if build.with? 'php'
      s += <<-EOS.undent
        Using the built PHP module:
          * Add the following line to php.ini:
            extension="#{mapscr_opt_dir}/php/php_mapscript.so"
          * Execute "php -m"
          * You should see MapScript in the module list

      EOS
    end
    %w[ruby perl java].each do |m|
      if m != 'java' or build.with? m
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
          cmd << 'sudo cp -f libjavamapscript.jnilib mapscript.jar /Library/Java/Extensions/'
        else
        end
        s += <<-EOS.undent
          Install the built #{m.upcase} module with:
            cd #{mapscr_opt_dir}/#{m}
            #{cmd[0]}
            #{cmd[1] + "\n" if cmd[1]}
        EOS
      end
    end
    (mapscr_dir/'Install_Modules.txt').write s

    if build.with? 'docs'
      resource('docs').stage do
        inreplace 'Makefile', 'sphinx-build', "#{HOMEBREW_PREFIX}/bin/sphinx-build"
        system 'make', 'html'
        doc.install 'build/html' => 'html'
      end
    end
  end

  def caveats
    s = <<-EOS.undent
      The Mapserver CGI executable is #{opt_prefix}/bin/mapserv

      Instructions for installing any built, but uninstalled, mapscript modules:
        #{opt_prefix}/mapscript/Install_Modules.txt

    EOS
    s += python.standard_caveats if python
    s
  end

  test do
    mapscr_opt_dir = opt_prefix/'mapscript'
    system "#{bin}/mapserv", '-v'
    system 'python', '-c', '"import mapscript"'
    system 'ruby', '-e', "\"require '#{mapscr_opt_dir}/ruby/mapscript'\""
    system 'perl', "-I#{mapscr_opt_dir}/perl", '-e', '"use mapscript;"'
    cd "#{mapscr_opt_dir}/java/examples" do
      system "#{JavaJDK.home}/bin/javac",
             '-classpath', '../', '-Djava.ext.dirs=../', 'RFC24.java'
      system "#{JavaJDK.home}/bin/java",
             '-classpath', '../', '-Djava.ext.dirs=../',
             'RFC24', '../../../tests/test.map'
    end if build.with? 'java'
  end
end

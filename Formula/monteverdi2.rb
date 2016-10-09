class Monteverdi2 < Formula
  ORFEO = "orfeo-54"
  OREFO_F = Formula[ORFEO]
  ORFEO_OPTS = Tab.for_formula(OREFO_F).used_options
  ITK_VER = "4.6"

  homepage "http://orfeo-toolbox.org/otb/monteverdi.html"
  url "https://downloads.sourceforge.net/project/orfeo-toolbox/Monteverdi2/Monteverdi2-0.8/Monteverdi2-0.8.0.tgz"
  sha1 "c68c5ad95ca99621c79fcfa794333e8ae42a1a49"

  bottle do
    root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
    sha1 "ee50c769b7abc085fc3cc98094e666a561efc45d" => :mavericks
  end

  option "without-app", "Don't bundle into application"

  depends_on "cmake" => :build
  depends_on ORFEO
  depends_on "qt"
  depends_on "orfeo-ice"
  depends_on "glew"

  resource "qwt5" do
    # http://qwt.sourceforge.net/
    url "http://sourceforge.net/projects/qwt/files/qwt/5.2.3/qwt-5.2.3.tar.bz2"
    sha1 "ff81595a1641a8b431f98d6091bb134bc94e0003"
  end

  resource "bundle" do
    # substitute CMake bundling that doesn't bundle dependencies
    url "https://gist.githubusercontent.com/dakcarto/517e4dcf0e7fc5f2711d/raw/7bc6d4d83c4df22de03690b2197c5b4b741fc60a/CMakeLists-osgeo4mac.txt"
    sha1 "f283c7887319248cb14f85da86da49789776ee13"
    version "0.8.0"
  end

  stable do
    # patch to fix older on_MyAction_activated deprecated signal (now is _triggered)
    patch do
      url "https://gist.githubusercontent.com/dakcarto/c64599469d0019f2ff86/raw/f9a256e1ba51712fbeda1ea863a3584ca7319377/monteverdi2-activated.diff"
      sha1 "0582bc3c81f41f50e94a91aefb2c297253c3d016"
    end
  end

  def install
    # locally vendor older qwt 5.2.3
    qwt5 = libexec/"qwt5"
    qwt5.mkpath
    resource("qwt5").stage do
      inreplace "qwtconfig.pri" do |s|
        s.sub! "/usr/local/qwt-$$VERSION", qwt5
        s.sub! /(doc.path)/, "#\\1"
        s.sub! /\+(=\s*QwtDesigner)/, "-\\1"
      end
      system "qmake", "-config", "release"
      system "make", "install"
      system "install_name_tool", "-id",
             "#{qwt5}/lib/libqwt.5.dylib",
             "#{qwt5}/lib/libqwt.5.dylib"
    end

    args = std_cmake_args + %W[
      -DCMAKE_PREFIX_PATH=#{qwt5}
    ]

    if build.with? "app"
      args << "-DMonteverdi2_USE_CPACK=ON"
      # substitute bundling script with a Homebrew-relative one,
      # generating a barebones .app structure
      macos_dir = buildpath/"Packaging/MacOS"
      macos_dir.install resource("bundle")
      File.rename macos_dir/"CMakeLists.txt", macos_dir/"CMakeLists-orig.txt"
      File.rename macos_dir/"CMakeLists-osgeo4mac.txt", macos_dir/"CMakeLists.txt"
      # fix up env vars in StartupCommand command so they point to Homebrew install
      inreplace "#{macos_dir}/StartupCommand", "=$RESOURCES", "=#{HOMEBREW_PREFIX}"
      # Qt plugins will not be bundled
      inreplace "#{macos_dir}/qt.conf", "Plugins=../../lib/qt4/plugins", ""
    end

    if ORFEO_OPTS.include? "with-external-itk"
      itk_f = Formula["insighttoolkit"]
      args << "-DITK_DIR=" + itk_f.opt_lib/"cmake/ITK-#{ITK_VER}"
      ENV.append "CXXFLAGS", "-I#{itk_f.opt_include}/ITK-#{ITK_VER}"
    else
      # Custom '-orfeo' suffix to avoid interfering with insighttoolkit formula
      args << "-DITK_DIR=" + OREFO_F.opt_lib/"cmake/ITK-#{ITK_VER}-orfeo"
      # FIXME: why is this needed for orfeo 4.2, but not 4.0?
      ENV.append "CXXFLAGS", "-I#{OREFO_F.opt_include}/otb/Utilities/ITK"
    end

    mkdir "build" do
      system "cmake", "..", *args
      # system "/usr/local/bin/bbedit", "CMakeCache.txt"
      # raise
      system "make"
      system "make", "install"
      if build.with? "app"
        system "make", "package"
        # move pre-DMG'd .app from package temp dir over to prefix
        Dir.glob("#{Dir.pwd}/_CPack_Packages/Darwin/Bundle/Monteverdi2-*/Monteverdi2-*.app") do |app|
          rmtree "#{app}/Contents/Resources/lib" # not needed in bundle
          mv app, prefix
        end
      end
    end

    # make command line utility launcher script
    envars = {
        :GDAL_DATA => "#{HOMEBREW_PREFIX}/share/gdal",
        :ITK_AUTOLOAD_PATH => "#{HOMEBREW_PREFIX}/lib/otb/applications"
    }
    # FIXME: the About... and Preferences... dialogs do not show up. Why?
    bin.env_script_all_files(libexec/"bin", envars)
  end

  def caveats; <<-EOS.undent
      The default geoid to use in elevation calculations is available in the
      associated `orfeo` package install location:

        #{OREFO_F.opt_libexec}/default_geoid/egm96.grd

      The command line launch script launches the GUI, but some dialogs do not
      work correctly, e.g. About.. and Prefrences...; use the application bundle
      instead, e.g. Monteverdi2-x.x.app.

    EOS
  end

end

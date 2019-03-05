class Qscintilla2Qt4 < Formula
  desc "Port to Qt of the Scintilla editing component"
  homepage "https://www.riverbankcomputing.com/software/qscintilla/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/QScintilla/QScintilla_gpl-2.11.1.tar.gz"
  sha256 "dae54d19e43dba5a3f98ac084fc0bcfa6fb713fa851f1783a01404397fd722f5"

  revision 1

  option "without-plugin", "Skip building the Qt Designer plugin"
  option "without-python@2", "Skip building the Python bindings"

  depends_on "python@2" => :recommended
  depends_on "sip-qt4"
  depends_on "qt@4"
  depends_on "pyqt-qt4"

  # Fix build with Xcode 8 "error: implicit instantiation of undefined template"
  # Originally reported 7 Oct 2016 https://www.riverbankcomputing.com/pipermail/qscintilla/2016-October/001160.html
  # Patch below posted 13 Oct 2016 https://www.riverbankcomputing.com/pipermail/qscintilla/2016-October/001167.html
  # Same as Alan Garny's OpenCOR commit https://github.com/opencor/opencor/commit/70f3944e36b8b95b3ad92106aeae2f511b3f0e90
  # if DevelopmentTools.clang_build_version >= 800
  #   patch do
  #     url "https://raw.githubusercontent.com/Homebrew/formula-patches/a651d71/qscintilla2/xcode-8.patch"
  #     sha256 "1a88309fdfd421f4458550b710a562c622d72d6e6fdd697107e4a43161d69bc9"
  #   end
  # end

  def install
    ENV.cxx11

    ENV.append "CXXFLAGS", "-std=c++11"

    # On Mavericks we want to target libc++, this requires an
    # unsupported/macx-clang-libc++ flag.
    if ENV.compiler == :clang && MacOS.version >= :mavericks
      spec = "unsupported/macx-clang-libc++"
    else
      spec = "macx-g++"
    end

    cd "Qt4Qt5" do
      inreplace "qscintilla.pro" do |s|
        s.gsub! "$$[QT_INSTALL_LIBS]", libexec/"lib"
        s.gsub! "$$[QT_INSTALL_HEADERS]", libexec/"include"
        s.gsub! "$$[QT_INSTALL_TRANSLATIONS]", prefix/"trans"
        s.gsub! "$$[QT_INSTALL_DATA]", prefix/"data"
        s.gsub! "$$[QT_HOST_DATA]", prefix/"data"
      end

      inreplace "features/qscintilla2.prf" do |s|
        s.gsub! "$$[QT_INSTALL_LIBS]", libexec/"lib"
        s.gsub! "$$[QT_INSTALL_HEADERS]", libexec/"include"
      end

      system "#{Formula["qt@4"].bin}/qmake", "qscintilla.pro", *args
      system "make"
      system "make", "install"
    end

    # Add qscintilla2 features search path, since it is not installed in Qt keg's mkspecs/features/
    ENV["QMAKEFEATURES"] = prefix/"data/mkspecs/features"

    if build.with?("python@2")
      sip_f = Formula["sip-qt4"]
      ENV.prepend_path "PATH", "#{sip_f.opt_libexec}/bin"
      sip_dir = sip_f.name
      cd "Python" do
        Language::Python.each_python(build) do |python, version|
          lib.mkpath
          (share/sip_dir).mkpath
          ENV["PYTHONPATH"] = "#{HOMEBREW_PREFIX}/lib/qt4/python#{version}/site-packages"
          system python, "configure.py", "-o", libexec/"lib", "-n", libexec/"include",
                           "--apidir=#{prefix}/qsci",
                           "--destdir=#{lib}/qt4/python#{version}/site-packages/PyQt4",
                           "--stubsdir=#{lib}/qt4/python#{version}/site-packages/PyQt4",
                           "--sip-incdir=#{sip_f.opt_libexec}/include",
                           "--qsci-sipdir=#{share}/#{sip_dir}",
                           "--pyqt-sipdir=#{Formula["pyqt-qt4"].opt_share}/#{sip_dir}",
                           "--spec=#{spec}"
          system "make"
          system "make", "install"
          system "make", "clean"
        end
      end
    end

    if build.with? "plugin"
      mkpath prefix/"plugins/designer"
      cd "designer-Qt4Qt5" do
        inreplace "designer.pro" do |s|
          s.sub! "$$[QT_INSTALL_PLUGINS]", "#{lib}/qt4/plugins"
          s.sub! "$$[QT_INSTALL_LIBS]", libexec/"lib"
        end
        system "#{Formula["qt@4"].bin}/qmake", "designer.pro", *args
        system "make"
        system "make", "install"
      end
    end
  end

  def caveats
    s = "Libraries installed in #{opt_libexec}/lib\n\n"
    s += "Headers installed in #{opt_libexec}/include\n\n"
    s += "Python modules installed in:\n"
    Language::Python.each_python(build) do |_python, version|
      s += "  #{HOMEBREW_PREFIX}/lib/qt4/python#{version}/site-packages/PyQt4"
    end
    s
  end

  test do
    Language::Python.each_python(build) do |python, version|
      ENV["PYTHONPATH"] = "#{HOMEBREW_PREFIX}/lib/qt4/python#{version}/site-packages"
      Pathname("test.py").write <<~EOS
      import PyQt4.Qsci
      assert("QsciLexer" in dir(PyQt4.Qsci))
      EOS
      system python, "test.py"
    end
  end
end

class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_qscintilla2_linked }

  def core_qscintilla2_linked
    Formula["qscintilla2"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink qscintilla2\e[0m or remove with brew \e[32muninstall --ignore-dependencies qscintilla2\e[0m\n\n" if core_qscintilla2_linked
    s
  end
end

class OsgeoQscintilla2 < Formula
  desc "Port to Qt of the Scintilla editing component"
  homepage "https://www.riverbankcomputing.com/software/qscintilla/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/QScintilla/2.11.4/QScintilla-2.11.4.tar.gz"
  sha256 "723f8f1d1686d9fc8f204cd855347e984322dd5cd727891d324d0d7d187bee20"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "106160e70896743c54ccc0ffeb5fd3bbbe986092588e0a5a7f5e500eaf895ff9" => :catalina
    sha256 "106160e70896743c54ccc0ffeb5fd3bbbe986092588e0a5a7f5e500eaf895ff9" => :mojave
    sha256 "106160e70896743c54ccc0ffeb5fd3bbbe986092588e0a5a7f5e500eaf895ff9" => :high_sierra
  end

  revision 5

  # keg_only "qscintilla2 is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "python"
  depends_on "qt"
  depends_on "osgeo-sip"
  depends_on "osgeo-pyqt"

  def install
    spec = (ENV.compiler == :clang && MacOS.version >= :mavericks) ? "macx-clang" : "macx-g++"
    args = %W[-config release -spec #{spec}]

    cd "Qt4Qt5" do
      inreplace "qscintilla.pro" do |s|
        s.gsub! "$$[QT_INSTALL_LIBS]", lib
        s.gsub! "$$[QT_INSTALL_HEADERS]", include
        s.gsub! "$$[QT_INSTALL_TRANSLATIONS]", prefix/"trans"
        s.gsub! "$$[QT_INSTALL_DATA]", prefix/"data"
        s.gsub! "$$[QT_HOST_DATA]", prefix/"data"
      end

      inreplace "features/qscintilla2.prf" do |s|
        s.gsub! "$$[QT_INSTALL_LIBS]", lib
        s.gsub! "$$[QT_INSTALL_HEADERS]", include
      end

      system "#{Formula["qt"].bin}/qmake", "qscintilla.pro", *args
      system "make"
      system "make", "install"
    end

    # Add qscintilla2 features search path, since it is not installed in Qt keg's mkspecs/features/
    ENV["QMAKEFEATURES"] = prefix/"data/mkspecs/features"

    cd "Python" do
      (share/"sip/PyQt5/Qsci").mkpath
      version = Language::Python.major_minor_version "python3"
      ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"

      system "python3", "configure.py", "-o", lib, "-n", include,
                     "--apidir=#{prefix}/qsci",
                     "--destdir=#{lib}/python#{version}/site-packages/PyQt5",
                     "--stubsdir=#{lib}/python#{version}/site-packages/PyQt5",
                     "--qsci-sipdir=#{share}/sip/PyQt5",
                     "--qsci-incdir=#{include}",
                     "--qsci-libdir=#{lib}",
                     "--pyqt=PyQt5",
                     "--pyqt-sipdir=#{Formula["osgeo-pyqt"].opt_share}/sip/PyQt5",
                     "--sip-incdir=#{Formula["osgeo-sip"].opt_include}",
                     "--spec=#{spec}",
                     "--no-dist-info",
                     "--verbose"
      system "make"
      system "make", "install"
      system "make", "clean"
    end
      (share/"sip/PyQt5/Qsci").install Dir["sip/*.sip"]
  end

  test do
    (testpath/"test.py").write <<~EOS
      import PyQt5.Qsci
      assert("QsciLexer" in dir(PyQt5.Qsci))
    EOS

    version = Language::Python.major_minor_version "python3"
    ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
    system "python3", "test.py"
  end
end

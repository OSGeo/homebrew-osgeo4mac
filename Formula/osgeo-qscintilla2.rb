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
  url "https://www.riverbankcomputing.com/static/Downloads/QScintilla/2.11.2/QScintilla_gpl-2.11.2.tar.gz"
  sha256 "029bdc476a069fda2cea3cd937ba19cc7fa614fb90578caef98ed703b658f4a1"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "25e8bba0ed4bc354843af08f7f18a61612f5c3fbcf33c01c98a57450d54c0e3f" => :mojave
    sha256 "25e8bba0ed4bc354843af08f7f18a61612f5c3fbcf33c01c98a57450d54c0e3f" => :high_sierra
    sha256 "39c911a385265585c938a87ec6b376b645f1fac8f0861fb3ec680b9619239cf5" => :sierra
  end

  revision 1

  # keg_only "qscintilla2" is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "python"
  depends_on "python@2"
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
      ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python3"].opt_bin}/python3"].each do |python|
        version = Language::Python.major_minor_version python
        system python, "configure.py", "-o", lib, "-n", include,
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
  end

  test do
    (testpath/"test.py").write <<~EOS
      import PyQt5.Qsci
      assert("QsciLexer" in dir(PyQt5.Qsci))
    EOS

    ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python"].opt_bin}/python3"].each do |python|
      version = Language::Python.major_minor_version python
      ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
      system python, "test.py"
    end
  end
end

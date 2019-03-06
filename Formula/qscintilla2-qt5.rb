class Qscintilla2Qt5 < Formula
  desc "Port to Qt of the Scintilla editing component"
  homepage "https://www.riverbankcomputing.com/software/qscintilla/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/QScintilla/QScintilla_gpl-2.11.1.tar.gz"
  sha256 "dae54d19e43dba5a3f98ac084fc0bcfa6fb713fa851f1783a01404397fd722f5"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "75ec91b6d960882cda9355ec94c35e2f2b2468b4ea389ff75e3cc0554794a0f5" => :mojave
    sha256 "75ec91b6d960882cda9355ec94c35e2f2b2468b4ea389ff75e3cc0554794a0f5" => :high_sierra
    sha256 "75ec91b6d960882cda9355ec94c35e2f2b2468b4ea389ff75e3cc0554794a0f5" => :sierra
  end

  # revision 1

  # patch :DATA

  depends_on "python" => :recommended
  depends_on "sip-qt5"
  depends_on "qt"
  depends_on "pyqt-qt5"

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

        system "#{Formula["python"].opt_bin}/python3", "configure.py", "-o", lib, "-n", include,
                          "--apidir=#{prefix}/qsci",
                          "--destdir=#{lib}/python#{py_ver}/site-packages/PyQt5",
                          "--stubsdir=#{lib}/python#{py_ver}/site-packages/PyQt5",
                          "--qsci-sipdir=#{share}/sip/PyQt5",
                          "--qsci-incdir=#{include}",
                          "--qsci-libdir=#{lib}",
                          "--pyqt=PyQt5",
                          "--pyqt-sipdir=#{Formula["pyqt-qt5"].opt_share}/sip/PyQt5",
                          "--sip-incdir=#{Formula["sip-qt5"].opt_include}",
                          "--spec=#{spec}",
                          "--no-dist-info",
                          "--verbose"
        system "make"
        system "make", "install"
        system "make", "clean"

        (share/"sip/PyQt5/Qsci").install Dir["sip/*.sip"]
    end
  end

  test do
    (testpath/"test.py").write <<~EOS
      import PyQt5.Qsci
      assert("QsciLexer" in dir(PyQt5.Qsci))
    EOS
    system "#{Formula["python"].opt_bin}/python3", "test.py"
  end

  private

  def py_ver
    `#{Formula["python"].opt_bin}/python3 -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`.strip
  end
end

__END__

--- a/Python/configure.py
+++ b/Python/configure.py
@@ -276,7 +276,7 @@
         the target configuration.
         """

-        return 'sip/qscimod5.sip' if target_configuration.pyqt_package == 'PyQt5' else 'sip/qscimod4.sip'
+        return 'sip/PyQt5/Qsci/qscimod5.sip' if target_configuration.pyqt_package == 'PyQt5' else 'sip/qscimod4.sip'

     @staticmethod
     def get_sip_installs(target_configuration):

class QwtQt4AT52 < Formula
  desc "Qt Widgets for Technical Applications"
  homepage "https://qwt.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/qwt/qwt/5.2.3/qwt-5.2.3.tar.bz2"
  sha256 "37feaf306753230b0d8538b4ff9b255c6fddaa3d6609ec5a5cc39a5a4d020ab7"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    sha256 "735c1d81cdf7b4192967e3923e15c07fbb1c06200c63cadd232b573fa022a2f2" => :sierra
  end

  keg_only "to avoid conflicts with newer versions"

  depends_on "qt-4"

  def install
    # redefine install prefix to Cellar
    inreplace "qwtconfig.pri", /^(\s*)INSTALLBASE\s*=(.*)$/, "\\1INSTALLBASE=#{prefix}"

    args = ["-config", "release", "-spec"]
    # On Mavericks we want to target libc++, this requires a unsupported/macx-clang-libc++ flag
    if ENV.compiler == :clang && MacOS.version >= :mavericks
      args << "unsupported/macx-clang-libc++"
    else
      args << "macx-g++"
    end

    system "qmake", *args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <qwt_plot_curve.h>
      int main() {
        QwtPlotCurve *curve1 = new QwtPlotCurve("Curve 1");
        return (curve1 == NULL);
      }
    EOS
    system ENV.cxx, "test.cpp", "-o", "out",
      "-framework", "QtCore", "-F#{Formula["qt-4"].opt_lib}",
      "-L#{lib}", "-lqwt",
      "-I#{include}",
      "-I#{Formula["qt-4"].opt_lib}/QtCore.framework/Headers",
      "-I#{Formula["qt-4"].opt_lib}/QtGui.framework/Headers"
    system "./out"
  end
end

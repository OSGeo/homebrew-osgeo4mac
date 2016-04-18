class QtIfwQt5 < Formula
  desc "Static build of version 5 of Qt for use in Qt Installer Framework"
  homepage "http://qt-project.org"
  url "https://download.qt.io/official_releases/qt/5.6/5.6.0/single/qt-everywhere-opensource-src-5.6.0.tar.xz"
  mirror "https://www.mirrorservice.org/sites/download.qt-project.org/official_releases/qt/5.6/5.6.0/single/qt-everywhere-opensource-src-5.6.0.tar.xz"
  sha256 "76a95cf6c1503290f75a641aa25079cd0c5a8fcd7cff07ddebff80a955b07de7"

  keg_only "Qt 5 conflicts Qt 4 (which is currently much more widely used)."

  # OS X 10.7 Lion is still supported in Qt 5.5, but is no longer a reference
  # configuration and thus untested in practice. Builds on OS X 10.7 have been
  # reported to fail: <https://github.com/Homebrew/homebrew/issues/45284>.
  depends_on :macos => :mountain_lion
  depends_on "pkg-config" => :build
  depends_on :xcode => :build

  def install
    args = ["-prefix", prefix, "-release", "-static", "-accessibility",
            "-qt-zlib", "-qt-libpng", "-qt-libjpeg", "-qt-freetype", "-qt-pcre",
            "-no-cups", "-no-sql-sqlite", "-no-qml-debug",
            "-nomake", "examples", "-nomake", "tests",
            "-skip", "qt3d", "-skip", "qtactiveqt", "-skip", "qtcanvas3d",
            "-skip", "qtenginio", "-skip", "qtlocation", "-skip", "qtmultimedia",
            "-skip", "qtserialbus", "-skip", "qtserialport",
            "-skip", "qtquickcontrols", "-skip", "qtquickcontrols2",
            "-skip", "qtscript", "-skip", "qtsensors",
            "-skip", "qtwebview", "-skip", "qtwebsockets", "-skip", "qtxmlpatterns",
            "-confirm-license", "-opensource"]

    system "./configure", *args
    system "make"
    ENV.j1
    system "make", "install"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    # configure saved PKG_CONFIG_LIBDIR set up by superenv; remove it
    # see: https://github.com/Homebrew/homebrew/issues/27184
    inreplace prefix/"mkspecs/qconfig.pri",
              /\n# pkgconfig\n(PKG_CONFIG_(SYSROOT_DIR|LIBDIR) = .*\n){2}\n/,
              "\n"

    # Move `*.app` bundles into `libexec` to expose them to `brew linkapps` and
    # because we don't like having them in `bin`. Also add a `-qt5` suffix to
    # avoid conflict with the `*.app` bundles provided by the `qt` formula.
    # (Note: This move/rename breaks invocation of Assistant via the Help menu
    # of both Designer and Linguist as that relies on Assistant being in `bin`.)
    libexec.mkpath
    Pathname.glob("#{bin}/*.app") do |app|
      mv app, libexec/"#{app.basename(".app")}-qt5.app"
    end
  end

  def caveats; <<-EOS.undent
      We agreed to the Qt5 opensource license for you.
      If this is unacceptable you should uninstall.
    EOS
  end

  test do
    (testpath/"hello.pro").write <<-EOS.undent
      QT       += core
      QT       -= gui
      TARGET = hello
      CONFIG   += console
      CONFIG   -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    EOS

    (testpath/"main.cpp").write <<-EOS.undent
      #include <QCoreApplication>
      #include <QDebug>

      int main(int argc, char *argv[])
      {
        QCoreApplication a(argc, argv);
        qDebug() << "Hello World!";
        return 0;
      }
    EOS

    system bin/"qmake", testpath/"hello.pro"
    system "make"
    assert File.exist?("hello")
    assert File.exist?("main.o")
    system "./hello"
  end
end

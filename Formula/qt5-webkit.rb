class NoQt5WebKitAlreadyRequirement < Requirement
  fatal true
  satisfy(:build_env => false) { !(Formula["qt5"].lib/"QtWebKit.framework").exist? }

  def message; <<~EOS
    Qt5 formula already has QtWebKit installed (e.g. built `--with-webkit`)
  EOS
  end
end

class NoQt5WebKitSandboxRequirement < Requirement
  fatal true

  def pour_bottle?
    # versions of macOS that have a bottle to install
    # if there is no bottle, --no-sandbox is required, since it will default to source install
    # TODO: handle case where pouring bottle fails (tricky here)
    MacOS.version >= :sierra
  end

  satisfy(:build_env => false) do
    (ARGV.build_all_from_source? || ARGV.build_from_source? || ARGV.build_bottle?) ? ARGV.no_sandbox? : ARGV.no_sandbox? || pour_bottle?
  end

  def message; <<~EOS
    Must be built with `brew install --no-sandbox ...`, or install steps will fail.
  EOS
  end
end

class Qt5Webkit < Formula
  desc "QtWebit module for Qt5"
  homepage "https://download.qt.io/official_releases/qt/5.11"
  url "https://github.com/qt/qtwebkit.git",
    :branch => "5.212",
    :commit => "72cfbd7664f21fcc0e62b869a6b01bf73eb5e7da"
  version "5.11.1"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    sha256 "49dbdda9a08a7e3921ad14aa095190e51926e4cef6e11731430a07c6d0395de3" => :sierra
    sha256 "689dc916f223b50ca697600edb7dcb995dc92fa17740197b1fbb13582a3a21ad" => :high_sierra
  end

  keg_only "because Qt5 is keg-only"

  depends_on NoQt5WebKitAlreadyRequirement
  depends_on NoQt5WebKitSandboxRequirement

  depends_on "qt"

  depends_on :macos => :mountain_lion
  depends_on :xcode => :build
  depends_on "cmake" => :build

  def install
    # On Mavericks we want to target libc++, this requires a macx-clang flag.
    if ENV.compiler == :clang && MacOS.version >= :mavericks
      spec = "macx-clang"
    else
      spec = "macx-g++"
    end
    args = %W[-config release -spec #{spec}]

    qt5 = Formula["qt"]

    mkdir "build" do
      system qt5.bin/"qmake", "../WebKit.pro", *args
      system "make"
      # just let it install to qt5 formula prefix
      # NOTE: this violates sandboxing, so --no-sandbox during install required
      system "make", "install"
    end

    # now move installed bits back to this formula prefix
    (lib/"cmake").mkpath
    (lib/"pkgconfig").mkpath
    # (prefix/"imports").mkpath # TODO: necessary for .pri?
    (prefix/"mkspecs/modules").mkpath
    (prefix/"plugins").mkpath
    (prefix/"qml").mkpath
    libexec.mkpath

    mv Dir["#{qt5.opt_lib}/QtWebKit*.framework"], "#{lib}/"
    mv Dir["#{qt5.opt_lib}/cmake/Qt5WebKit*"], "#{lib}/cmake/"
    mv Dir["#{qt5.opt_lib}/pkgconfig/Qt5WebKit*.pc"], "#{lib}/pkgconfig/"
    mv Dir["#{qt5.opt_prefix}/mkspecs/modules/qt_lib_webkit*.pri"], "#{prefix}/mkspecs/modules/"
    #mv qt5.opt_prefix/"plugins/webkit", "#{prefix}/plugins/"
    mv qt5.opt_prefix/"qml/QtWebKit", "#{prefix}/qml/"
    mv qt5.opt_libexec/"QtWebProcess", "#{libexec}/"

    # Rename the .so files
    mv "#{prefix}/qml/QtWebKit/libqmlwebkitplugin.so", "#{prefix}/qml/QtWebKit/libqmlwebkitplugin.dylib"
    mv "#{prefix}/qml/QtWebKit/experimental/libqmlwebkitexperimentalplugin.so", "#{prefix}/qml/QtWebKit/experimental/libqmlwebkitexperimentalplugin.dylib"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    # update pkgconfig files
    Dir["#{lib}/pkgconfig/Qt5WebKit*.pc"].each do |pc|
      inreplace pc do |s|
        s.sub! /^(prefix=).*$/, "\\1#{prefix}"
      end
    end

    # update .pri files
    # TODO: unsure if QT_MODULE_IMPORT_BASE is relative to module or its imports
    Dir["#{prefix}/mkspecs/modules/qt_lib_webkit*.pri"].each do |pri|
      inreplace pri do |s|
        s.gsub! "$$QT_MODULE_LIB_BASE", opt_lib.to_s
        next if pri.end_with? "_private.pri"
        s.gsub! "$$QT_MODULE_BIN_BASE", opt_bin.to_s
      end
    end

    # Fix rpath values
    MachO::Tools.change_install_name("#{lib}/QtWebKitWidgets.framework/Versions/5/QtWebKitWidgets",
                                    "@rpath/QtWebKit.framework/Versions/5/QtWebKit",
                                    "#{lib}/QtWebKit.framework/Versions/5/QtWebKit")
    MachO::Tools.change_install_name("#{prefix}/qml/QtWebKit/libqmlwebkitplugin.dylib",
                                    "@rpath/QtWebKit.framework/Versions/5/QtWebKit",
                                    "#{lib}/QtWebKit.framework/Versions/5/QtWebKit")
    MachO::Tools.change_install_name("#{prefix}/qml/QtWebKit/experimental/libqmlwebkitexperimentalplugin.dylib",
                                    "@rpath/QtWebKit.framework/Versions/5/QtWebKit",
                                    "#{lib}/QtWebKit.framework/Versions/5/QtWebKit")
    MachO::Tools.change_install_name("#{libexec}/QtWebProcess",
                                     "@rpath/QtWebKitWidgets.framework/Versions/5/QtWebKitWidgets",
                                     "#{lib}/QtWebKitWidgets.framework/Versions/5/QtWebKitWidgets")
    MachO::Tools.change_install_name("#{libexec}/QtWebProcess",
                                    "@rpath/QtWebKit.framework/Versions/5/QtWebKit",
                                    "#{lib}/QtWebKit.framework/Versions/5/QtWebKit")





  end

  def caveats; <<~EOS
    Must be built with `brew install --no-sandbox ...`, or install steps will fail.

  EOS
  end

  test do
    (testpath/"hello.pro").write <<~EOS
      QT        += core webkitwidgets
      QT        -= gui
      TARGET     = hello
      CONFIG    += console
      CONFIG    -= app_bundle
      TEMPLATE   = app
      HEADERS    = client.h
      SOURCES   += client.cpp main.cpp
      include(#{prefix}/mkspecs/modules/qt_lib_webkit.pri)
      include(#{prefix}/mkspecs/modules/qt_lib_webkitwidgets.pri)
    EOS

    (testpath/"client.h").write <<~EOS
    #ifndef CLIENT_H
    #define CLIENT_H
    #include <QWebPage>
    #include <QString>

    class Client : public QObject
    {
      Q_OBJECT

    public:
      Client(const QString &url, QObject *parent = 0);

    private Q_SLOTS:
      void loadUrl();
      void output(bool ok);

    private:
      QWebPage page;
      QString url;

    };
    #endif // CLIENT_H
    EOS

    (testpath/"client.cpp").write <<~EOS
    #include "client.h"
    #include <QCoreApplication>
    #include <QDebug>
    #include <QWebFrame>
    #include <QUrl>

    Client::Client(const QString &myurl, QObject *parent)
      : QObject(parent)
      , url(myurl)
    {
    }

    void Client::loadUrl()
    {
      page.mainFrame()->load(QUrl(url));
      connect(&page, SIGNAL(loadFinished(bool)), this, SLOT(output(bool)));
    }

    void Client::output(bool ok)
    {
      if (ok){
        qDebug() << "Page title: " << page.mainFrame()->title();
        QCoreApplication::exit(0);
      } else {
        qDebug() << "Error loading " << url;
        QCoreApplication::exit(1);
      }
    }
    EOS

    (testpath/"main.cpp").write <<~EOS
      #include <QApplication>
      #include <QDebug>
      #include <QTimer>
      #include <QWebView>
      #include "client.h"

      int main(int argc, char *argv[])
      {
        QApplication app(argc, argv);
        Client c("file://#{testpath}/test.html", app.instance());
        qDebug() << "Running application";
        QTimer::singleShot(1000, &c, SLOT(loadUrl()));
        return app.exec();
      }
    EOS

    (testpath/"test.html").write <<~EOS
      <!DOCTYPE html>
      <html lang="en">
      <head><meta charset="utf-8" /><title>My title</title></head>
      <body>Body content</body>
      </html>
    EOS

    cd testpath do
      system Formula["qt5"].bin/"qmake", "hello.pro"
      system "make"
      assert_predicate testpath/"client.o", :exist?
      assert_predicate testpath/"moc_client.o", :exist?
      assert_predicate testpath/"main.o", :exist?
      assert_predicate testpath/"hello", :exist?

      # Test that we can actually serve the page
      pid = fork do
        exec testpath/"hello"
      end
      sleep 2
      begin
        assert_match "<html><body><h1>It works!</h1></body></html>\n", shell_output("curl http://localhost:80")
      ensure
        Process.kill("SIGINT", pid)
        Process.wait(pid)
      end
    end
  end
end

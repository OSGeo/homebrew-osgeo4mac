class OsgeoQtWebkit < Formula
  desc "Classes for a WebKit2 based implementation and a new QML API"
  homepage "https://www.qt.io/developers"
  url "https://github.com/qt/qtwebkit/archive/ab1bd15209abaf7effc51dbc2f272c5681af7223.tar.gz"
  sha256 "0128e09a9623a62ffe93c395294f571306f2d318797cf4e69d812cca6e42ec90"
  version "5.14.1"

  revision 3

  # from the developer: "https://github.com/annulen/webkit.git"
  head "https://github.com/qt/qtwebkit.git"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "72b7e4c0f9740a19b9c296ddf690dff0be1e89d96051084e3036466f8e768673" => :catalina
    sha256 "72b7e4c0f9740a19b9c296ddf690dff0be1e89d96051084e3036466f8e768673" => :mojave
    sha256 "72b7e4c0f9740a19b9c296ddf690dff0be1e89d96051084e3036466f8e768673" => :high_sierra
  end

  # insert the XPC_NOESCAPE macro in the right places in xpc_array_apply and xpc_dictionary_apply
  # to match the definitions now used in the 10.14 SDK
  # patch :DATA

  depends_on "cmake" => :build
  depends_on "ninja" => [:build, :recommended]
  depends_on "fontconfig" => :build
  depends_on "freetype" => :build
  depends_on "gperf" => :build
  depends_on "sqlite" => :build
  depends_on "bison" => :build
  depends_on "pkg-config" => :build

  depends_on "python" => :build
  depends_on "ruby" => :build
  depends_on "perl" => :build
  depends_on :xcode => :build

  depends_on "gcc" => :build # features.h

  depends_on "libxslt"
  depends_on "qt"
  depends_on "webp"
  depends_on "zlib"

  # depends_on "gst-plugins-base"
  # depends_on "libjpeg" # Qt < 5.10
  depends_on "libjpeg-turbo"
  depends_on "libpng"
  depends_on "libxslt"
  depends_on "gst-plugins-good" => :optional

  def cmake_args
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_BUILD_TYPE=Release
      -DCMAKE_FIND_FRAMEWORK=LAST
      -DCMAKE_VERBOSE_MAKEFILE=ON
      -Wno-dev
    ]
    args
  end

  def install
    args = cmake_args
    args << "-DPORT=Qt"
    args << "-DENABLE_TOOLS=OFF"
    args << "-DCMAKE_MACOSX_RPATH=OFF"
    args << "-DEGPF_SET_RPATH=OFF"
    args << "-DCMAKE_SKIP_RPATH=ON"
    args << "-DCMAKE_SKIP_INSTALL_RPATH=ON"

    # Fuck off rpath
    # inreplace "Source/cmake/OptionsQt.cmake",
    #           "set(CMAKE_MACOSX_RPATH\ ON)",
    #           ""
    mkdir "build" do
      system "cmake", "-G", build.with?("ninja") ? "Ninja" : "Unix Makefiles", *args, ".."
      system "cmake", "--build", ".", "--target", "all", "--", "-j", Hardware::CPU.cores
      system "cmake", "--build", ".", "--target", "install", "--", "-j", Hardware::CPU.cores
    end

    # rename the .so files
    mv "#{lib}/qml/QtWebKit/libqmlwebkitplugin.so", "#{lib}/qml/QtWebKit/libqmlwebkitplugin.dylib"
    mv "#{lib}/qml/QtWebKit/experimental/libqmlwebkitexperimentalplugin.so", "#{lib}/qml/QtWebKit/experimental/libqmlwebkitexperimentalplugin.dylib"

    ln_s "#{lib}/qml", "#{prefix}/qml"
    ln_s "#{lib}/libexec", "#{prefix}/libexec"

    # some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # the pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    # for some reason it is not generating the .pc files, that's why they are created
    # although these are not necessary
    mkdir "#{lib}/pkgconfig" do
      # create Qt5WebKit.pc
      File.open("#{lib}/pkgconfig/Qt5WebKit.pc", "w") { |file|
        file << "Name: Qt5WebKit\n"
        file << "Description: Qt WebKit module\n"
        file << "Version: #{version}\n"
        # file << "Libs: -F#{lib} -framework QtWebKit"
        file << "Libs: -L#{lib} -lQt5WebKit\n"
        # file << "Cflags: -DQT_WEBKIT_LIB -I#{include}/QtWebKit\n"
        file << "Cflags: -I#{include}/QtWebKit\n"
        file << "Requires: Qt5Core Qt5Gui Qt5Network"
      }
      # create QtWebKitWidgets.pc
      File.open("#{lib}/pkgconfig/Qt5WebKitWidgets.pc", "w") { |file|
        file << "Name: Qt5WebKitWidgets\n"
        file << "Description: Qt WebKitWidgets module\n"
        file << "Version: #{version}\n"
        # file << "Libs: -F#{lib} -framework QtWebKitWidgets"
        file << "Libs: -L#{lib} -lQt5WebKitWidgets\n"
        # file << "Cflags: -DQT_WEBKITWIDGETS_LIB -I#{include}/QtWebKitWidgets\n"
        file << "Cflags: -I#{include}/QtWebKitWidgets\n"
        file << "Requires:"
      }
    end

    # fix rpath values
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

  # Failed to connect to localhost port 80: Connection refused
  test do
    # (testpath/"hello.pro").write <<~EOS
    #   QT        += core webkitwidgets
    #   QT        -= gui
    #   TARGET     = hello
    #   CONFIG    += console
    #   CONFIG    -= app_bundle
    #   TEMPLATE   = app
    #   HEADERS    = client.h
    #   SOURCES   += client.cpp main.cpp
    #   include(#{prefix}/mkspecs/modules/qt_lib_webkit.pri)
    #   include(#{prefix}/mkspecs/modules/qt_lib_webkitwidgets.pri)
    # EOS
    #
    # (testpath/"client.h").write <<~EOS
    # #ifndef CLIENT_H
    # #define CLIENT_H
    # #include <QWebPage>
    # #include <QString>
    #
    # class Client : public QObject
    # {
    #   Q_OBJECT
    #
    # public:
    #   Client(const QString &url, QObject *parent = 0);
    #
    # private Q_SLOTS:
    #   void loadUrl();
    #   void output(bool ok);
    #
    # private:
    #   QWebPage page;
    #   QString url;
    #
    # };
    # #endif // CLIENT_H
    # EOS
    #
    # (testpath/"client.cpp").write <<~EOS
    # #include "client.h"
    # #include <QCoreApplication>
    # #include <QDebug>
    # #include <QWebFrame>
    # #include <QUrl>
    #
    # Client::Client(const QString &myurl, QObject *parent)
    #   : QObject(parent)
    #   , url(myurl)
    # {
    # }
    #
    # void Client::loadUrl()
    # {
    #   page.mainFrame()->load(QUrl(url));
    #   connect(&page, SIGNAL(loadFinished(bool)), this, SLOT(output(bool)));
    # }
    #
    # void Client::output(bool ok)
    # {
    #   if (ok){
    #     qDebug() << "Page title: " << page.mainFrame()->title();
    #     QCoreApplication::exit(0);
    #   } else {
    #     qDebug() << "Error loading " << url;
    #     QCoreApplication::exit(1);
    #   }
    # }
    # EOS
    #
    # (testpath/"main.cpp").write <<~EOS
    #   #include <QApplication>
    #   #include <QDebug>
    #   #include <QTimer>
    #   #include <QWebView>
    #   #include "client.h"
    #
    #   int main(int argc, char *argv[])
    #   {
    #     QApplication app(argc, argv);
    #     Client c("file://#{testpath}/test.html", app.instance());
    #     qDebug() << "Running application";
    #     QTimer::singleShot(1000, &c, SLOT(loadUrl()));
    #     return app.exec();
    #   }
    # EOS
    #
    # (testpath/"test.html").write <<~EOS
    #   <!DOCTYPE html>
    #   <html lang="en">
    #   <head><meta charset="utf-8" /><title>My title</title></head>
    #   <body>Body content</body>
    #   </html>
    # EOS
    #
    # cd testpath do
    #   system Formula["qt5"].bin/"qmake", "hello.pro"
    #   system "make"
    #   assert_predicate testpath/"client.o", :exist?
    #   assert_predicate testpath/"moc_client.o", :exist?
    #   assert_predicate testpath/"main.o", :exist?
    #   assert_predicate testpath/"hello", :exist?
    #
    #   # test that we can actually serve the page
    #   pid = fork do
    #     exec testpath/"hello"
    #   end
    #   sleep 2
    #   begin
    #     assert_match "<html><body><h1>It works!</h1></body></html>\n", shell_output("curl http://localhost:80")
    #   ensure
    #     Process.kill("SIGINT", pid)
    #     Process.wait(pid)
    #   end
    # end
  end
  # could be used:
  # (testpath/"CMakeLists.txt").write("find_package(Qt5 CONFIG COMPONENTS WebKit WebKitWidgets REQUIRED)")
  # system "cmake", ".", "-Wno-dev"
end

__END__

--- a/Source/cmake/WebKitCommon.cmake
+++ b/Source/cmake/WebKitCommon.cmake
@@ -24,9 +24,9 @@
     # TODO Enforce version requirement for perl
     find_package(Perl 5.10.0 REQUIRED)

-    find_package(PythonInterp 2.7.0 REQUIRED)
-    if (PYTHON_VERSION_MAJOR GREATER 2)
-        message(FATAL_ERROR "Python 2 is required, but Python ${PYTHON_VERSION_MAJOR} was found.")
+    find_package(PythonInterp 3.7.6 REQUIRED)
+    if (PYTHON_VERSION_MAJOR GREATER 3)
+        message(FATAL_ERROR "Python 3 is required, but Python ${PYTHON_VERSION_MAJOR} was found.")
     endif ()

     # We cannot check for RUBY_FOUND because it is set only when the full package is installed and


# --- a/Source/WTF/wtf/spi/darwin/XPCSPI.h 2017-06-17 13:46:54.000000000 +0300
# +++ b/Source/WTF/wtf/spi/darwin/XPCSPI.h 2018-09-08 23:41:06.397523110 +0300
# @@ -89,10 +89,6 @@
#  EXTERN_C const struct _xpc_type_s _xpc_type_string;
#
#  EXTERN_C xpc_object_t xpc_array_create(const xpc_object_t*, size_t count);
# -#if COMPILER_SUPPORTS(BLOCKS)
# -EXTERN_C bool xpc_array_apply(xpc_object_t, xpc_array_applier_t);
# -EXTERN_C bool xpc_dictionary_apply(xpc_object_t xdict, xpc_dictionary_applier_t applier);
# -#endif
#  EXTERN_C size_t xpc_array_get_count(xpc_object_t);
#  EXTERN_C const char* xpc_array_get_string(xpc_object_t, size_t index);
#  EXTERN_C void xpc_array_set_string(xpc_object_t, size_t index, const char* string);

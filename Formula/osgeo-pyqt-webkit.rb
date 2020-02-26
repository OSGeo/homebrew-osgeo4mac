class OsgeoPyqtWebkit < Formula
  desc "Python bindings for v5 of Qt's Webkit"
  homepage "https://www.riverbankcomputing.com/software/pyqt/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt5/5.13.2/PyQt5-5.13.2.tar.gz"
  sha256 "adc17c077bf233987b8e43ada87d1e0deca9bd71a13e5fd5fc377482ed69c827"

  revision 2

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "1e04c2744db39236c0f356fcaf118b9486912e91a348b9040fc1a8d088e7d1e9" => :catalina
    sha256 "1e04c2744db39236c0f356fcaf118b9486912e91a348b9040fc1a8d088e7d1e9" => :mojave
    sha256 "1e04c2744db39236c0f356fcaf118b9486912e91a348b9040fc1a8d088e7d1e9" => :high_sierra
  end

  option "with-debug", "Build with debug symbols"

  keg_only "PyQt 5 Webkit has CMake issues when linked"
  # Error: Failed to fix install linkage
  # adding -DCMAKE_INSTALL_NAME_DIR=#{lib} and -DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON
  # to the CMake arguments will fix the problem.

  depends_on "python"
  depends_on "qt"
  depends_on "osgeo-sip"
  depends_on "osgeo-pyqt"
  depends_on "osgeo-qt-webkit"

  def install
    # sneak the WebKit modules into the Qt.modules setup before referencing in .pro files
    wk_mods = Formula["osgeo-qt-webkit"].opt_prefix/"mkspecs/modules"
    inreplace "configure.py" do |s|
      s.sub! /('TEMPLATE = lib'\])/,
             "\\1\n" + <<-EOS
    pro_lines.append('include(#{wk_mods}/qt_lib_webkit.pri)')
    pro_lines.append('include(#{wk_mods}/qt_lib_webkitwidgets.pri)')
    EOS
    end

    version = Language::Python.major_minor_version "python3"
    args = ["--confirm-license",
            "--bindir=#{bin}",
            "--destdir=#{lib}/python#{version}/site-packages",
            "--stubsdir=#{lib}/python#{version}/site-packages/PyQt5",
            "--sipdir=#{share}/sip/PyQt5",
            # sip.h could not be found automatically
            "--sip-incdir=#{Formula["osgeo-sip"].opt_include}",
            "--qmake=#{Formula["qt"].bin}/qmake",
            # Force deployment target to avoid libc++ issues
            "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
            "--enable=QtWebKit",
            "--enable=QtWebKitWidgets",
            "--no-designer-plugin",
            "--no-python-dbus",
            "--no-qml-plugin",
            "--no-qsci-api",
            "--no-sip-files",
            "--no-tools",
            "--verbose",
            "--no-dist-info"
           ]
    args << "--debug" if build.with? "debug"

    system "python3", "configure.py", *args
    system "make"
    system "make", "install"
    system "make", "clean"

    # clean out non-WebKit artifacts (already in pyqt5 formula prefix)
    rm_r prefix/"share"
    cd "#{lib}/python#{version}/site-packages/PyQt5" do
      rm "__init__.py"
      rm "Qt.so"
      rm_r "uic"
    end
  end

  test do
    version = Language::Python.major_minor_version "python3"
    ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
    system "python3", "-c", '"import PyQt5.QtWebKit"'
    system "python3", "-c", '"import PyQt5.QtWebKitWidgets"'
  end
end

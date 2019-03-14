class OsgeoPyqtWebkit < Formula
  desc "Python bindings for v5 of Qt's Webkit"
  homepage "https://www.riverbankcomputing.com/software/pyqt"
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt5/PyQt5_gpl-5.12.tar.gz"
  sha256 "d9e70065b5980afde5f2b9bc900910050331604e02c70666c45fcfc66b0d4f34"

  revision 1

  option "with-debug", "Build with debug symbols"

  keg_only "PyQt 5 Webkit has CMake issues when linked"
  # Error: Failed to fix install linkage
  # adding -DCMAKE_INSTALL_NAME_DIR=#{lib} and -DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON
  # to the CMake arguments will fix the problem.

  depends_on "python"
  depends_on "python@2"
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

    ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python"].opt_bin}/python3"].each do |python|
      version = Language::Python.major_minor_version python
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

      system python, "configure.py", *args
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
  end

  test do
    ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python"].opt_bin}/python3"].each do |python|
      version = Language::Python.major_minor_version python
      ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
      system python, "-c", '"import PyQt5.QtWebKit"'
      system python, "-c", '"import PyQt5.QtWebKitWidgets"'
    end
  end
end

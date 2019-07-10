class OsgeoPyqtWebkit < Formula
  desc "Python bindings for v5 of Qt's Webkit"
  homepage "https://www.riverbankcomputing.com/software/pyqt/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt5/5.13.0/PyQt5_gpl-5.13.0.tar.gz"
  sha256 "0cdbffe5135926527b61cc3692dd301cd0328dd87eeaf1313e610787c46faff9"

  revision 1

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "96e4c6194d8efbdb449932bcc60ff163b990c26f1f33642c1b2187287e127f90" => :mojave
    sha256 "96e4c6194d8efbdb449932bcc60ff163b990c26f1f33642c1b2187287e127f90" => :high_sierra
    sha256 "5e9ece916a6ada3a4db59f830178590266f3ea64c3866222e1c03909675075a2" => :sierra
  end

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

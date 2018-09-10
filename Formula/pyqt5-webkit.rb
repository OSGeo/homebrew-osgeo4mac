class Pyqt5Webkit < Formula
  desc "Python bindings for v5 of Qt's Webkit"
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://downloads.sourceforge.net/project/pyqt/PyQt5/PyQt-5.10.1/PyQt5_gpl-5.10.1.tar.gz"
  sha256 "9932e971e825ece4ea08f84ad95017837fa8f3f29c6b0496985fa1093661e9ef"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "64f43df75ac00fa8fee60d170e890eb50b0521225ec55e704d9466b31f92a62d" => :high_sierra
    sha256 "64f43df75ac00fa8fee60d170e890eb50b0521225ec55e704d9466b31f92a62d" => :sierra
  end

  option "with-debug", "Build with debug symbols"

  depends_on "qt"
  depends_on "osgeo/osgeo4mac/qt5-webkit"
  depends_on "sip"
  depends_on "pyqt"
  depends_on "python@2" => :recommended
  depends_on "python" => :recommended

  def install
    if build.without?("python3") && build.without?("python")
      odie "pyqt: --with-python3 must be specified when using --without-python"
    end

    # sneak the WebKit modules into the Qt.modules setup before referencing in .pro files
    wk_mods = Formula["qt5-webkit"].opt_prefix/"mkspecs/modules"
    inreplace "configure.py" do |s|
      s.sub! /('TEMPLATE = lib'\])/,
             "\\1\n" + <<-EOS
    pro_lines.append('include(#{wk_mods}/qt_lib_webkit.pri)')
    pro_lines.append('include(#{wk_mods}/qt_lib_webkitwidgets.pri)')
    EOS
    end

    Language::Python.each_python(build) do |python, version|
      # check if the module already exists in pyqt prefix
      if (Formula["pyqt"].lib/"python#{version}/site-packages/PyQt5/QtWebKit.so").exist?
        opoo "PyQt5 formula already has a Python #{version} PyQt5.QtWebKit module (i.e. `qt` probably built `--with-webkit`)"
        next
      end

      args = ["--confirm-license",
              "--bindir=#{bin}",
              "--destdir=#{lib}/python#{version}/site-packages",
              "--stubsdir=#{lib}/python#{version}/site-packages/PyQt5",
              "--sipdir=#{share}/sip/Qt5",
              # sip.h could not be found automatically
              "--sip-incdir=#{Formula["sip"].opt_include}",
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
              "--verbose"]
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
    Language::Python.each_python(build) do |python, python_version|
      next unless (HOMEBREW_PREFIX/"lib/python#{python_version}/site-packages").exist?
      ENV["PYTHONPATH"] = HOMEBREW_PREFIX/"lib/python#{python_version}/site-packages"
      %w[
        WebKit
        WebKitWidgets
      ].each { |mod| system python, "-c", "import PyQt5.Qt#{mod}" }
    end
  end
end

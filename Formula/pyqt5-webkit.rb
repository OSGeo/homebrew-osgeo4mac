class Pyqt5Webkit < Formula
  desc "Python bindings for v5 of Qt's Webkit"
  homepage "https://www.riverbankcomputing.com/software/pyqt"
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt5/PyQt5_gpl-5.12.tar.gz"
  sha256 "d9e70065b5980afde5f2b9bc900910050331604e02c70666c45fcfc66b0d4f34"

  # revision 1

  option "with-debug", "Build with debug symbols"

  depends_on "python" => :recommended
  depends_on "sip-qt5"
  depends_on "qt"
  depends_on "pyqt-qt5"
  depends_on "qt5-webkit"

  def install
    # sneak the WebKit modules into the Qt.modules setup before referencing in .pro files
    wk_mods = Formula["qt5-webkit"].opt_prefix/"mkspecs/modules"
    inreplace "configure.py" do |s|
      s.sub! /('TEMPLATE = lib'\])/,
             "\\1\n" + <<-EOS
    pro_lines.append('include(#{wk_mods}/qt_lib_webkit.pri)')
    pro_lines.append('include(#{wk_mods}/qt_lib_webkitwidgets.pri)')
    EOS
    end

    args = ["--confirm-license",
            "--bindir=#{bin}",
            "--destdir=#{lib}/python#{py_ver}/site-packages",
            "--stubsdir=#{lib}/python#{py_ver}/site-packages/PyQt5",
            "--sipdir=#{share}/sip/PyQt5",
            # sip.h could not be found automatically
            "--sip-incdir=#{Formula["sip-qt5"].opt_include}",
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

    system "#{Formula["python"].opt_bin}/python3", "configure.py", *args
    system "make"
    system "make", "install"
    system "make", "clean"

    # clean out non-WebKit artifacts (already in pyqt5 formula prefix)
    rm_r prefix/"share"
    cd "#{lib}/python#{py_ver}/site-packages/PyQt5" do
      rm "__init__.py"
      rm "Qt.so"
      rm_r "uic"
    end
  end

  test do
    ENV["PYTHONPATH"] = HOMEBREW_PREFIX/"lib/python#{py_ver}/site-packages"
      %w[
        WebKit
        WebKitWidgets
      ].each { |mod| system "#{Formula["python"].opt_bin}/python3", "-c", "import PyQt5.Qt#{mod}" }
  end

  private

  def py_ver
    `#{Formula["python"].opt_bin}/python3 -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`.strip
  end
end

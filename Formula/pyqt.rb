class Pyqt < Formula
  desc "Python bindings for v5 of Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt5/PyQt5_gpl-5.12.tar.gz"
  sha256 "d9e70065b5980afde5f2b9bc900910050331604e02c70666c45fcfc66b0d4f34"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "d10eb031edc7929338d4668164040bc3be948666abc7266fec666bf37b2e5871" => :mojave
    sha256 "d10eb031edc7929338d4668164040bc3be948666abc7266fec666bf37b2e5871" => :high_sierra
    sha256 "d10eb031edc7929338d4668164040bc3be948666abc7266fec666bf37b2e5871" => :sierra
  end

  # revision 1

  depends_on "python" => :recommended
  depends_on "sip"
  depends_on "qt"
  depends_on "dbus" => :optional

  def install
    args = ["--confirm-license",
            "--bindir=#{bin}",
            "--destdir=#{lib}/python#{py_ver}/site-packages",
            "--stubsdir=#{lib}/python#{py_ver}/site-packages/PyQt5",
            "--sipdir=#{share}/sip/PyQt5", # Qt5
            # sip.h could not be found automatically
            "--sip-incdir=#{Formula["sip-qt5"].opt_include}",
            "--qmake=#{Formula["qt"].bin}/qmake",
            # Force deployment target to avoid libc++ issues
            "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
            "--qml-plugindir=#{pkgshare}/plugins",
            "--verbose",
            "--sip=#{Formula["sip-qt5"].opt_bin}/sip",
            #  ERROR: Unknown module(s) in QT
            "--disable=QtWebKit",
            "--disable=QtWebKitWidgets",
            "--disable=QAxContainer",
            "--disable=QtX11Extras",
            "--disable=QtWinExtras",
            "--disable=Enginio",
            "--no-dist-info"
           ]

    system "#{Formula["python"].opt_bin}/python3", "configure.py", *args
    system "make"
    system "make", "install"
    system "make", "clean"
  end

  test do
    system "#{bin}/pyuic5", "--version"
    system "#{bin}/pylupdate5", "-version"
    system "#{Formula["python"].opt_bin}/python3", "-c", "import PyQt5"
      %w[
        Gui
        Location
        Multimedia
        Network
        Quick
        Svg
        Widgets
        Xml
      ].each { |mod| system "#{Formula["python"].opt_bin}/python3", "-c", "import PyQt5.Qt#{mod}" }
  end

  private

  def py_ver
    `#{Formula["python"].opt_bin}/python3 -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`.strip
  end
end

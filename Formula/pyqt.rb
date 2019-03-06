class Pyqt < Formula
  desc "Python bindings for v5 of Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt5/PyQt5_gpl-5.12.tar.gz"
  sha256 "d9e70065b5980afde5f2b9bc900910050331604e02c70666c45fcfc66b0d4f34"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    rebuild 2
    sha256 "12f463e9864fa48666532834d1535b957548a3eed495d296ee45243485d4b162" => :mojave
    sha256 "12f463e9864fa48666532834d1535b957548a3eed495d296ee45243485d4b162" => :high_sierra
    sha256 "47f6f415976db68d642a53282d1a5ede4630ccf244b06cdcd930ed789612bdae" => :sierra
  end

  revision 2

  depends_on "python"
  depends_on "python@2"
  depends_on "osgeo/osgeo4mac/sip"
  depends_on "qt"
  depends_on "dbus" => :optional

  def install
    ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python"].opt_bin}/python3"].each do |python|
      version = Language::Python.major_minor_version python
      args = ["--confirm-license",
              "--bindir=#{bin}",
              "--destdir=#{lib}/python#{version}/site-packages",
              "--stubsdir=#{lib}/python#{version}/site-packages/PyQt5",
              "--sipdir=#{share}/sip/PyQt5", # Qt5
              # sip.h could not be found automatically
              "--sip-incdir=#{Formula["osgeo/osgeo4mac/sip"].opt_include}",
              "--qmake=#{Formula["qt"].bin}/qmake",
              # Force deployment target to avoid libc++ issues
              "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
              "--qml-plugindir=#{pkgshare}/plugins",
              "--verbose",
              "--sip=#{Formula["osgeo/osgeo4mac/sip"].opt_bin}/sip",
              #  ERROR: Unknown module(s) in QT
              "--disable=QtWebKit",
              "--disable=QtWebKitWidgets",
              "--disable=QAxContainer",
              "--disable=QtX11Extras",
              "--disable=QtWinExtras",
              "--disable=Enginio",
              "--no-dist-info"
             ]

      system python, "configure.py", *args
      system "make"
      system "make", "install"
      system "make", "clean"
    end
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
end

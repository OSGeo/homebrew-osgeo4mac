class Pyqt < Formula
  desc "Python bindings for v5 of Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt5/PyQt5_gpl-5.12.tar.gz"
  sha256 "d9e70065b5980afde5f2b9bc900910050331604e02c70666c45fcfc66b0d4f34"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    rebuild 1
    sha256 "e478c59fc564c156abd42a72667e3a4fbc011415b2932c3e01e28b8aabaabed4" => :mojave
    sha256 "e478c59fc564c156abd42a72667e3a4fbc011415b2932c3e01e28b8aabaabed4" => :high_sierra
    sha256 "94bb657efa44cb84ecdd231c9a9248cd37efbcc621cdad9176de706532d654b3" => :sierra
  end

  revision 1

  depends_on "python" => :recommended
  depends_on "osgeo/osgeo4mac/sip"
  depends_on "qt"
  depends_on "dbus" => :optional

  def install
    ["python2", "python3"].each do |python|
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

      system "#{Formula["python"].opt_bin}/python3", "configure.py", *args
      system "make"
      system "make", "install"
      system "make", "clean"
    end
  end

  test do
    system "#{bin}/pyuic5", "--version"
    system "#{bin}/pylupdate5", "-version"

    ["python2", "python3"].each do |python|
      system python, "-c", "import PyQt5"
      %w[
        Gui
        Location
        Multimedia
        Network
        Quick
        Svg
        Widgets
        Xml
      ].each { |mod| system python, "-c", "import PyQt5.Qt#{mod}" }
    end
  end
end

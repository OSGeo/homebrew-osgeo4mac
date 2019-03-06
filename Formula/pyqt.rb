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

  revision 3

  depends_on "python"
  depends_on "python@2"
  depends_on "osgeo/osgeo4mac/sip"
  depends_on "qt"
  depends_on "dbus" => :optional

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/c2/f7/c7b501b783e5a74cf1768bc174ee4fb0a8a6ee5af6afa92274ff964703e0/setuptools-40.8.0.zip"
    sha256 "6e4eec90337e849ade7103723b9a99631c1f0d19990d6e8412dc42f5ae8b304d"
  end

  resource "enum34" do
    url "https://files.pythonhosted.org/packages/e8/26/a6101edcf724453845c850281b96b89a10dac6bd98edebc82634fccce6a5/enum34-1.1.6.zip"
    sha256 "2d81cbbe0e73112bdfe6ef8576f2238f2ba27dd0d55752a776c41d38b7da2850"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", "#{libexec}/lib/python2.7/site-packages"

    resource("setuptools").stage do
      system "#{Formula["python@2"].opt_bin}/python2", "setup.py", "install", "--prefix=#{libexec}", "--single-version-externally-managed", "--record=installed.txt"
    end

    resource("enum34").stage do
      system "#{Formula["python@2"].opt_bin}/python2", "setup.py", "install", "--prefix=#{libexec}", "--optimize=1"
    end

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

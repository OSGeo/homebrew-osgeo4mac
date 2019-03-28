class OsgeoPyqt < Formula
  desc "Python bindings for v5 of Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt5/PyQt5_gpl-5.12.1.tar.gz"
  sha256 "3718ce847d824090fd5f95ff3f13847ee75c2507368d4cbaeb48338f506e59bf"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "a1559a665c5ceece509dc49f490e50337d68b9083dfd3d15a0a9c1e2f19cae5f" => :mojave
    sha256 "a1559a665c5ceece509dc49f490e50337d68b9083dfd3d15a0a9c1e2f19cae5f" => :high_sierra
    sha256 "99da550c7320bc7f8c3c99af603ea698f1b22e8f4fa43c4d910a1a6fcdb45b65" => :sierra
  end

  # revision 1

  depends_on "python"
  depends_on "python@2"
  depends_on "osgeo-sip"
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
              "--sip-incdir=#{Formula["osgeo-sip"].opt_include}",
              "--qmake=#{Formula["qt"].bin}/qmake",
              # Force deployment target to avoid libc++ issues
              "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
              "--qml-plugindir=#{pkgshare}/plugins",
              "--verbose",
              "--sip=#{Formula["osgeo-sip"].opt_bin}/sip",
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

    ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python"].opt_bin}/python3"].each do |python|
      version = Language::Python.major_minor_version python
      ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
      system python, "-c", '"import PyQt5"'
      system python, "-c", '"import PyQt5.QtGui"'
      system python, "-c", '"import PyQt5.QtLocation"'
      system python, "-c", '"import PyQt5.QtMultimedia"'
      system python, "-c", '"import PyQt5.QtNetwork"'
      system python, "-c", '"import PyQt5.QtQuick"'
      system python, "-c", '"import PyQt5.QtSvg"'
      system python, "-c", '"import PyQt5.QtWidgets"'
      system python, "-c", '"import PyQt5.QtXml"'
    end
  end
end

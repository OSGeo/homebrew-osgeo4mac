class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_pyqt_linked }

  def core_pyqt_linked
    Formula["pyqt"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink pyqt\e[0m or remove with brew \e[32muninstall --ignore-dependencies pyqt\e[0m\n\n" if core_pyqt_linked
    s
  end
end

class OsgeoPyqt < Formula
  desc "Python bindings for v5 of Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt5/5.13.2/PyQt5-5.13.2.tar.gz"
  sha256 "adc17c077bf233987b8e43ada87d1e0deca9bd71a13e5fd5fc377482ed69c827"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "3fbaf4df5cfaca0e6c5d7ebf1dce4a9b2ecb14b279cb70f27a17deb9a604db08" => :catalina
    sha256 "3fbaf4df5cfaca0e6c5d7ebf1dce4a9b2ecb14b279cb70f27a17deb9a604db08" => :mojave
    sha256 "3fbaf4df5cfaca0e6c5d7ebf1dce4a9b2ecb14b279cb70f27a17deb9a604db08" => :high_sierra
  end

  revision 1

  # keg_only "pyqt" is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "python"
  depends_on "python@2"
  depends_on "osgeo-sip"
  depends_on "qt"
  depends_on "dbus" => :optional

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/42/3e/2464120172859e5d103e5500315fb5555b1e908c0dacc73d80d35a9480ca/setuptools-45.1.0.zip"
    sha256 "91f72d83602a6e5e4a9e4fe296e27185854038d7cbda49dcd7006c4d3b3b89d5"
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
              "--designer-plugindir=#{pkgshare}/plugins",
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
      # system "make", "install"
      ENV.deparallelize { system "make", "install" }
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

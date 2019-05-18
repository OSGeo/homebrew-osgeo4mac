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
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt5/5.12.2/PyQt5_gpl-5.12.2.tar.gz"
  sha256 "c565829e77dc9c281aa1a0cdf2eddaead4e0f844cbaf7a4408441967f03f5f0f"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "50c9eb83337837bcdc001ea8d0ed1291fca49eef3898d702cbbf3edbba37f2f7" => :mojave
    sha256 "50c9eb83337837bcdc001ea8d0ed1291fca49eef3898d702cbbf3edbba37f2f7" => :high_sierra
    sha256 "94a68066678bb5d42defcd71ffc0ac107f358286b30ce50424ec6ed26c675703" => :sierra
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
    url "https://files.pythonhosted.org/packages/1d/64/a18a487b4391a05b9c7f938b94a16d80305bf0369c6b0b9509e86165e1d3/setuptools-41.0.1.zip"
    sha256 "a222d126f5471598053c9a77f4b5d4f26eaa1f150ad6e01dcf1a42e185d05613"
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

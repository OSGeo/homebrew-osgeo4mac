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
    sha256 "ac0b5e73af59c1394e057729477a948b49858f1b535f00f13c7c74a2a5fb90b6" => :catalina
    sha256 "ac0b5e73af59c1394e057729477a948b49858f1b535f00f13c7c74a2a5fb90b6" => :mojave
    sha256 "ac0b5e73af59c1394e057729477a948b49858f1b535f00f13c7c74a2a5fb90b6" => :high_sierra
  end

  revision 3

  # keg_only "pyqt" is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "python"
  depends_on "osgeo-sip"
  depends_on "qt"
  depends_on "dbus" => :optional

  def install
    version = Language::Python.major_minor_version "python3"
    ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
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

    system "python3", "configure.py", *args
    system "make"
    # system "make", "install"
    ENV.deparallelize { system "make", "install" }
    system "make", "clean"
  end

  test do
    system "#{bin}/pyuic5", "--version"
    system "#{bin}/pylupdate5", "-version"

    version = Language::Python.major_minor_version "python3"
    ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
    system "python3", "-c", '"import PyQt5"'
    system "python3", "-c", '"import PyQt5.QtGui"'
    system "python3", "-c", '"import PyQt5.QtLocation"'
    system "python3", "-c", '"import PyQt5.QtMultimedia"'
    system "python3", "-c", '"import PyQt5.QtNetwork"'
    system "python3", "-c", '"import PyQt5.QtQuick"'
    system "python3", "-c", '"import PyQt5.QtSvg"'
    system "python3", "-c", '"import PyQt5.QtWidgets"'
    system "python3", "-c", '"import PyQt5.QtXml"'
  end
end

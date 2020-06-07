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
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://files.pythonhosted.org/packages/4d/81/b9a66a28fb9a7bbeb60e266f06ebc4703e7e42b99e3609bf1b58ddd232b9/PyQt5-5.14.2.tar.gz"
  sha256 "bd230c6fd699eabf1ceb51e13a8b79b74c00a80272c622427b80141a22269eb0"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "d12d8f3633c20c53d850fa7618003deffcfd643bf2ce300597ad77225c1a21c7" => :catalina
    sha256 "d12d8f3633c20c53d850fa7618003deffcfd643bf2ce300597ad77225c1a21c7" => :mojave
    sha256 "d12d8f3633c20c53d850fa7618003deffcfd643bf2ce300597ad77225c1a21c7" => :high_sierra
  end

  # revision 5

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

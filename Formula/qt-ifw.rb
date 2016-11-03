class QtIfw < Formula
  desc "Tools and utilities to create installers for Qt desktop platforms"
  homepage "http://qt-project.org/wiki/Qt-Installer-Framework"
  url "https://download.qt.io/official_releases/qt-installer-framework/2.0.1/qt-installer-framework-opensource-2.0.1-src.tar.gz"
  sha256 "9f3bdb46182cef0254920750315bb22ea83fef4b45ab19a00161175823fabd98"

  depends_on "qt-ifw-qt5"

  def install
    args = %w[installerfw.pro -config release]
    args << "PREFIX=#{prefix}"

    system "#{Formula["qt-ifw-qt5"].opt_bin}/qmake", *args
    system "make"
    # system "make", "docs"

    # no install targets, just copy to prefix
    prefix.install "bin"
    prefix.install "lib"
    prefix.install "examples"
    prefix.install Dir["LICENSE*"], "LGPL_EXCEPTION.txt"
    # doc.install "doc/html", "doc/ifw.qch"
  end

  def caveats; <<-EOS.undent
      We agreed to the Qt5 opensource license for you.
      If this is unacceptable you should uninstall.
    EOS
  end

  test do
    # pass
  end
end

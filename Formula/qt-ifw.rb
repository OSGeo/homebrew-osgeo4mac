class QtIfw < Formula

  homepage "http://qt-project.org/wiki/Qt-Installer-Framework"
  url "https://gitorious.org/installer-framework/installer-framework.git",
      :revision => "e5d2246c53a1f683de70b9f5044fe5d64704380e"
  version "2.0.0"

  depends_on "qt-ifw-qt5"

  def install
    args = %W[installerfw.pro -config release]
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

end

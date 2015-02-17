class QtIfw < Formula

  homepage "http://qt-project.org/wiki/Qt-Installer-Framework"
  url "https://gitorious.org/installer-framework/installer-framework.git",
      :revision => "e5d2246c53a1f683de70b9f5044fe5d64704380e"
  version "2.0.0"

  depends_on "qt-ifw-qt5"

  # # depends for qt5
  # depends_on :macos => :lion
  # depends_on "pkg-config" => :build
  # depends_on :xcode => :build
  #
  # resource "qt5" do
  #   url "http://qtmirror.ics.com/pub/qtproject/official_releases/qt/5.4/5.4.0/single/qt-everywhere-opensource-src-5.4.0.tar.xz"
  #   mirror "http://download.qt-project.org/official_releases/qt/5.4/5.4.0/single/qt-everywhere-opensource-src-5.4.0.tar.xz"
  #   sha1 "2f5558b87f8cea37c377018d9e7a7047cc800938"
  # end

  def install
    # # vendor static Qt5 to libexec/qt5
    # qt5_prefix = libexec/"qt5"
    # qt5_prefix.mkpath
    #
    # resource("qt5").stage do
    #   args = ["-prefix", qt5_prefix, "-release", "-static", "-accessibility",
    #           "-qt-zlib", "-qt-libpng", "-qt-libjpeg",
    #           "-no-cups", "-no-sql-sqlite", "-no-qml-debug",
    #           "-nomake", "examples", "-nomake", "tests",
    #           "-skip qtactiveqt", "-skip qtenginio", "-skip qtlocation",
    #           "-skip qtmultimedia", "-skip qtserialport", "-skip qtquick1",
    #           "-skip qtquickcontrols", "-skip qtscript", "-skip qtsensors",
    #           "-skip qtwebkit", "-skip qtwebsockets", "-skip qtxmlpatterns",
    #           "-confirm-license", "-opensource"]
    #
    #   system "./configure", *args
    #   system "make"
    #   makeflags = ENV["MAKEFLAGS"]
    #   ENV.deparallelize
    #   system "make", "install"
    #   # reset parallel job count
    #   ENV["MAKEFLAGS"] = makeflags
    # end

    args = %W[installerfw.pro -config release -spec]
    # On >= Mavericks we want to target libc++
    if ENV.compiler == :clang and MacOS.version >= :mavericks
      args << "macx-clang"
    else
      args << "macx-g++"
    end
    args << "PREFIX=#{prefix}"

    # system "#{qt5_prefix}/bin/qmake", *args
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

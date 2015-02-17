class QtIfwQt5 < Formula
  homepage "http://qt-project.org"
  url "http://qtmirror.ics.com/pub/qtproject/official_releases/qt/5.4/5.4.0/single/qt-everywhere-opensource-src-5.4.0.tar.xz"
  mirror "http://download.qt-project.org/official_releases/qt/5.4/5.4.0/single/qt-everywhere-opensource-src-5.4.0.tar.xz"
  sha1 "2f5558b87f8cea37c377018d9e7a7047cc800938"

  depends_on :macos => :lion
  depends_on "pkg-config" => :build
  depends_on :xcode => :build

  keg_only "Qt 5 conflicts Qt 4 (which is currently much more widely used)."

  def install
    args = ["-prefix", prefix, "-release", "-static", "-accessibility",
            "-qt-zlib", "-qt-libpng", "-qt-libjpeg",
            "-no-cups", "-no-sql-sqlite", "-no-qml-debug",
            "-nomake", "examples", "-nomake", "tests",
            "-skip", "qtactiveqt", "-skip", "qtenginio", "-skip", "qtlocation",
            "-skip", "qtmultimedia", "-skip", "qtserialport", "-skip", "qtquick1",
            "-skip", "qtquickcontrols", "-skip", "qtscript", "-skip", "qtsensors",
            "-skip", "qtwebkit", "-skip", "qtwebsockets", "-skip", "qtxmlpatterns",
            "-confirm-license", "-opensource"]

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "install"

    # configure saved PKG_CONFIG_LIBDIR set up by superenv; remove it
    # see: https://github.com/Homebrew/homebrew/issues/27184
    inreplace prefix/"mkspecs/qconfig.pri", /\n\n# pkgconfig/, ""
    inreplace prefix/"mkspecs/qconfig.pri", /\nPKG_CONFIG_.*=.*$/, ""

    Pathname.glob("#{bin}/*.app") { |app| mv app, prefix }
  end

  def caveats; <<-EOS.undent
      We agreed to the Qt5 opensource license for you.
      If this is unacceptable you should uninstall.
    EOS
  end

end

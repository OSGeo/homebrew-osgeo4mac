class QtIfwQt5 < Formula
  homepage "http://qt-project.org"
  url "http://qtmirror.ics.com/pub/qtproject/official_releases/qt/5.4/5.4.0/single/qt-everywhere-opensource-src-5.4.0.tar.xz"
  mirror "http://download.qt-project.org/official_releases/qt/5.4/5.4.0/single/qt-everywhere-opensource-src-5.4.0.tar.xz"
  sha1 "2f5558b87f8cea37c377018d9e7a7047cc800938"

  depends_on :macos => :lion
  depends_on "pkg-config" => :build
  depends_on :xcode => :build

  keg_only "Qt 5 conflicts Qt 4 (which is currently much more widely used)."
  
  # Wrong detection of clang version
  # see: https://bugreports.qt.io/browse/QTBUG-43279
	patch :DATA

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

__END__
--- a/qtbase/src/corelib/global/qcompilerdetection.h
+++ b/qtbase/src/corelib/global/qcompilerdetection.h
@@ -154,17 +154,17 @@
 /* Clang also masquerades as GCC */
 #    if defined(__apple_build_version__)
 #      /* http://en.wikipedia.org/wiki/Xcode#Toolchain_Versions */
-#      if __apple_build_version__ >= 600051
+#      if __apple_build_version__ >= 6000051
 #        define Q_CC_CLANG 305
-#      elif __apple_build_version__ >= 503038
+#      elif __apple_build_version__ >= 5030038
 #        define Q_CC_CLANG 304
-#      elif __apple_build_version__ >= 500275
+#      elif __apple_build_version__ >= 5000275
 #        define Q_CC_CLANG 303
-#      elif __apple_build_version__ >= 425024
+#      elif __apple_build_version__ >= 4250024
 #        define Q_CC_CLANG 302
-#      elif __apple_build_version__ >= 318045
+#      elif __apple_build_version__ >= 3180045
 #        define Q_CC_CLANG 301
-#      elif __apple_build_version__ >= 211101
+#      elif __apple_build_version__ >= 2111001
 #        define Q_CC_CLANG 300
 #      else
 #        error "Unknown Apple Clang version"
 

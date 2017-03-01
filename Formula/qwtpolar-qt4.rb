class QwtpolarQt4 < Formula
  desc "Library for displaying values on a polar coordinate system"
  homepage "https://qwtpolar.sourceforge.io/"
  url "https://downloads.sf.net/project/qwtpolar/qwtpolar/1.1.0/qwtpolar-1.1.0.tar.bz2"
  sha256 "e45a1019b481f52a63483c536c5ef3225f1cced04abf45d7d0ff8e06d30e2355"

  bottle do
    root_url "http://qgis.dakotacarto.com/bottles"
    sha256 "1e98ef9094e4e88737ebee0b1ab1c1a2c2a569f84b432c5bf9242ef9a0866b20" => :sierra
  end

  keg_only "Newer Qt5-only version in homebrew-core"

  option "with-examples", "Install source code for example apps"
  option "without-plugin", "Skip building the Qt Designer plugin"

  depends_on "qt-4"
  depends_on "qwt-qt4"

  # Update designer plugin linking back to qwtpolar framework/lib after install
  # See: https://sourceforge.net/p/qwtpolar/patches/2/
  patch :DATA

  def install
    cd "doc" do
      doc.install "html"
      man3.install Dir["man/man3/{q,Q}wt*"]
    end
    # Remove leftover doxygen files, so they don't get installed
    rm_r "doc"

    libexec.install Dir["examples/*"] if build.with? "examples"

    inreplace "qwtpolarconfig.pri" do |s|
      s.gsub! /^(\s*)QWT_POLAR_INSTALL_PREFIX\s*=\s*(.*)$/,
              "\\1QWT_POLAR_INSTALL_PREFIX=#{prefix}"
      s.sub! /\+(=\s*QwtPolarDesigner)/, "-\\1" if build.without? "plugin"
      # Don't build examples now, since linking flawed until qwtpolar installed
      s.sub! /\+(=\s*QwtPolarExamples)/, "-\\1"

      # Install Qt plugin in `lib/qt-4/plugins/designer`, not `plugins/designer`.
      s.sub! %r{(= \$\$\{QWT_POLAR_INSTALL_PREFIX\})/(plugins/designer)$},
             "\\1/lib/qt-4/\\2"
    end

    args = %w[-config release -spec]
    # On Mavericks we want to target libc++, this requires a unsupported/macx-clang-libc++ flag
    if ENV.compiler == :clang && MacOS.version >= :mavericks
      args << "unsupported/macx-clang-libc++"
    else
      args << "macx-g++"
    end

    ENV["QMAKEFEATURES"] = "#{Formula["qwt-qt4"].opt_prefix}/features"
    system "qmake", *args
    system "make"
    system "make", "install"

    post_install
  end

  def post_install
    # do symlinking of keg-only here, since `brew doctor` complains about it
    # and user may need to re-link again after following suggestion to unlink
    if build.with? "plugin"
      dsubpth = "qt-4/plugins/designer"
      dhppth = HOMEBREW_PREFIX/"lib/#{dsubpth}"
      dhppth.mkpath
      ln_sf "#{opt_lib.relative_path_from(dhppth)}/#{dsubpth}/libqwt_polar_designer_plugin.dylib", "#{dhppth}/"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <qwt_polar_renderer.h>
      int main() {
        QwtPolarRenderer *curve1 = new QwtPolarRenderer();
        return (curve1 == NULL);
      }
    EOS
    system ENV.cxx, "test.cpp", "-o", "out",
           "-framework", "qwtpolar", "-framework", "qwt", "-framework", "QtCore",
           "-F#{Formula["qt-4"].opt_lib}", "-F#{Formula["qwt-qt4"].opt_lib}", "-F#{lib}",
           "-I#{lib}/qwtpolar.framework/Headers",
           "-I#{Formula["qwt-qt4"].opt_lib}/qwt.framework/Headers",
           "-I#{Formula["qt-4"].opt_lib}/QtCore.framework/Headers",
           "-I#{Formula["qt-4"].opt_lib}/QtGui.framework/Headers"
    system "./out"
  end
end

__END__
diff --git a/designer/designer.pro b/designer/designer.pro
index 24770fd..3ff0761 100644
--- a/designer/designer.pro
+++ b/designer/designer.pro
@@ -75,6 +75,16 @@ contains(QWT_POLAR_CONFIG, QwtPolarDesigner) {

     target.path = $${QWT_POLAR_INSTALL_PLUGINS}
     INSTALLS += target
+
+    macx {
+        contains(QWT_POLAR_CONFIG, QwtPolarFramework) {
+            QWTP_LIB = qwtpolar.framework/Versions/$${QWT_POLAR_VER_MAJ}/qwtpolar
+        }
+        else {
+            QWTP_LIB = libqwtpolar.$${QWT_POLAR_VER_MAJ}.dylib
+        }
+        QMAKE_POST_LINK = install_name_tool -change $${QWTP_LIB} $${QWT_POLAR_INSTALL_LIBS}/$${QWTP_LIB} $(DESTDIR)$(TARGET)
+    }
 }
 else {
     TEMPLATE        = subdirs # do nothing

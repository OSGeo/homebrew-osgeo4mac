require "formula"

class Qwtpolar < Formula
  homepage "http://qwtpolar.sourceforge.net/"
  url "http://downloads.sf.net/project/qwtpolar/qwtpolar/1.0.1/qwtpolar-1.0.1.tar.bz2"
  sha1 "8cff25b444037429321a0fdecacc102cc044f695"

  devel do
    url "http://downloads.sf.net/project/qwtpolar/qwtpolar-beta/1.1.0-rc1/qwtpolar-1.1.0-rc1.tar.bz2"
    sha1 "b71d6f462c857fd57f295ad97e87efa88b3b1ada"
  end

  #option "enable-framework", "Build as framework"

  depends_on "qt"
  depends_on "osgeo/osgeo4mac/qwt"

  # fix designer plugin linking, when in non-standard prefix
  def patches
    DATA
  end

  def install

    qwt = Formula.factory("qwt")
    qwt_ver = qwt.linked_keg.realpath.basename.to_s.to_f
    if build.stable? && qwt_ver >= 6.1
      odie "QwtPolar 1.0.x is only compatible with Qwt <= 6.0.x. Use `--devel` build option."
    elsif build.devel? && qwt_ver < 6.1
      odie "QwtPolar `--devel` build requires Qwt >= 6.1.x."
    end

    qwt_lib = qwt.opt_prefix/"lib"
    inreplace "qwtpolarconfig.pri" do |s|
      # change_make_var won't work because there are leading spaces
      s.gsub! /^(\s*)QWT_POLAR_INSTALL_PREFIX\s*=\s*(.*)$/, "\\1QWT_POLAR_INSTALL_PREFIX=#{prefix}"
      s << "\n" << "QWT_POLAR_CONFIG -= QwtPolarFramework" unless build.include? "enable-framework" or build.stable?
      # add paths to installed qwt (built as lib for 6.0.x and framework for 6.1.x)
      if build.devel?
        s << "\n" << "INCLUDEPATH += #{qwt_lib}/qwt.framework/Headers"
        s << "\n" << "QMAKE_LFLAGS += -F#{qwt_lib}/"
        s << "\n" << "LIBS += -framework qwt"
      else
        s << "\n" << "INCLUDEPATH += #{qwt.opt_prefix}/include"
        s << "\n" << "QMAKE_LFLAGS += -L#{qwt_lib}/"
        s << "\n" << "LIBS += -lqwt"
      end
    end

    args = %W[-config release -spec]
    # On Mavericks we want to target libc++, this requires a unsupported/macx-clang-libc++ flag
    if ENV.compiler == :clang and MacOS.version >= :mavericks
      args << "unsupported/macx-clang-libc++"
    else
      args << "macx-g++"
    end

    system "qmake", *args
    system "make"
    system "make", "install"

    # symlink QT Designer plugin (note: not removed on formula uninstall)
    cd Formula.factory('qt').opt_prefix/"plugins/designer" do
      ln_sf prefix/"plugins/designer/libqwt_polar_designer_plugin.dylib", "."
    end
  end

end

__END__
diff --git a/designer/designer.pro b/designer/designer.pro
index 4bca34c..208c428 100644
--- a/designer/designer.pro
+++ b/designer/designer.pro
@@ -58,6 +58,10 @@ contains(QWT_POLAR_CONFIG, QwtPolarDesigner) {

     target.path = $${QWT_POLAR_INSTALL_PLUGINS}
     INSTALLS += target
+    LIBS     = -L../lib $${LIBS}
+    macx {
+        QMAKE_POST_LINK = install_name_tool -change libqwtpolar.1.dylib $${QWT_POLAR_INSTALL_PREFIX}/lib/libqwtpolar.1.dylib ${DESTDIR}/$(TARGET)
+    }
 }
 else {
     TEMPLATE        = subdirs # do nothing

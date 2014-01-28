require "formula"

class Qwtpolar < Formula
  homepage "http://qwtpolar.sourceforge.net/"
  url "http://downloads.sf.net/project/qwtpolar/qwtpolar-beta/1.1.0-rc1/qwtpolar-1.1.0-rc1.tar.bz2"
  sha1 "b71d6f462c857fd57f295ad97e87efa88b3b1ada"

  head 'svn://svn.code.sf.net/p/qwtpolar/code/trunk'

  option "with-examples", "Build example apps"

  depends_on "qt"
  depends_on "qwt"

  # fix lib search paths: https://sourceforge.net/p/qwtpolar/bugs/5/ (committed)
  def patches
    DATA unless build.head?
  end

  def install
    cd "qwtpolar" if build.head?

    qwt_opt = Formula.factory("qwt").opt_prefix
    inreplace "qwtpolarconfig.pri" do |s|
      # change_make_var won't work because there are leading spaces
      s.gsub! /^(\s*)QWT_POLAR_INSTALL_PREFIX\s*=\s*(.*)$/,
              "\\1QWT_POLAR_INSTALL_PREFIX=#{prefix}"
      s.sub! /(QWT_POLAR_CONFIG\s*\+= QwtPolarExamples)/,
             "#\\1" unless build.with? "examples"
      # add paths to installed qwt (this supports non-standard HOMEBREW_PREFIX)
      s << "\n" << "INCLUDEPATH += #{qwt_opt}/lib/qwt.framework/Headers"
      s << "\n" << "QMAKE_LFLAGS += -F#{qwt_opt}/lib"
      s << "\n" << "LIBS += -framework qwt"
    end

    inreplace "qwtpolarbuild.pri" do |s|
        # designer plugin build fails unless there is also a release binary
        s.sub! /^(\s*CONFIG\s*\+=\s*)debug$/,
               "\\1debug_and_release\nCONFIG += build_all"
    end if build.head?

    # update designer plugin linking back to qwtpolar framework/lib
    inreplace "designer/designer.pro" do |s|
      s.sub! /(INSTALLS \+= target)/, "\\1\n" + <<-EOS.undent
        macx {
            contains(QWT_POLAR_CONFIG, QwtPolarFramework) {
                QWTP_LIB = qwtpolar.framework/Versions/$${QWT_POLAR_VER_MAJ}/qwtpolar
            }
            else {
                QWTP_LIB = libqwtpolar.$${QWT_POLAR_VER_MAJ}.dylib
            }
            QMAKE_POST_LINK = install_name_tool -change $${QWTP_LIB} #{opt_prefix}/lib/$${QWTP_LIB} ${DESTDIR}/$(TARGET)
        }
      EOS
    end

    args = %W[-spec]
    # On Mavericks we want to target libc++, this requires a unsupported/macx-clang-libc++ flag
    if ENV.compiler == :clang and MacOS.version >= :mavericks
      args << "unsupported/macx-clang-libc++"
    else
      args << "macx-g++"
    end

    system "qmake", *args
    system "make"
    system "make", "install"

    # remove extraneous qwtpolar.framework due to CONFIG+=build_all (Qt error?)
    rm_r lib/"qwtpolar.framework/qwtpolar.framework" if build.head?

    # symlink Qt Designer plugin (note: not removed on qwtpolar formula uninstall)
    cd Formula.factory("qt").opt_prefix/"plugins/designer" do
      ln_sf prefix/"plugins/designer/libqwt_polar_designer_plugin.dylib", "."
    end
  end

end

__END__
diff --git a/designer/designer.pro b/designer/designer.pro
index 4bca34c..3430550 100644
--- a/designer/designer.pro
+++ b/designer/designer.pro
@@ -34,7 +34,7 @@ contains(QWT_POLAR_CONFIG, QwtPolarDesigner) {
     INCLUDEPATH    += $${QWT_POLAR_ROOT}/src
     DEPENDPATH     += $${QWT_POLAR_ROOT}/src

-    contains(QWT_CONFIG, QwtFramework) {
+    contains(QWT_POLAR_CONFIG, QwtPolarFramework) {

         LIBS      += -F$${QWT_POLAR_ROOT}/lib
     }
diff --git a/examples/examples.pri b/examples/examples.pri
index c24e6c5..b4c5866 100644
--- a/examples/examples.pri
+++ b/examples/examples.pri
@@ -17,7 +17,7 @@ INCLUDEPATH += $${QWT_POLAR_ROOT}/src
 DEPENDPATH  += $${QWT_POLAR_ROOT}/src
 DESTDIR      = $${QWT_POLAR_ROOT}/examples/bin$${SUFFIX_STR}

-contains(QWT_CONFIG, QwtPolarFramework) {
+contains(QWT_POLAR_CONFIG, QwtPolarFramework) {

     LIBS      += -F$${QWT_POLAR_ROOT}/lib
 }

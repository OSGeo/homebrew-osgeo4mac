require "formula"

class Qwtpolar < Formula
  homepage "http://qwtpolar.sourceforge.net/"
  url "http://downloads.sf.net/project/qwtpolar/qwtpolar-beta/1.1.0-rc1/qwtpolar-1.1.0-rc1.tar.bz2"
  sha1 "b71d6f462c857fd57f295ad97e87efa88b3b1ada"

  depends_on "qt"
  depends_on "qwt"

  def install
    qwt_lib = Formula.factory('qwt').opt_prefix/"lib"
    inreplace "qwtpolarconfig.pri" do |s|
      # change_make_var won't work because there are leading spaces
      s.gsub! /^(\s*)QWT_POLAR_INSTALL_PREFIX\s*=\s*(.*)$/, "\\1QWT_POLAR_INSTALL_PREFIX=#{prefix}"
      # don't build framework
      s << "\n" << "QWT_POLAR_CONFIG -= QwtPolarFramework"
      # add paths to installed qwt
      s << "\n" << "INCLUDEPATH += #{qwt_lib}/qwt.framework/Headers"
      s << "\n" << "QMAKE_LFLAGS += -F#{qwt_lib}/"
      s << "\n" << "LIBS += -framework qwt"
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

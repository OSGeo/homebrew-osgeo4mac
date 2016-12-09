class Qwtpolar < Formula
  desc "Library for displaying values on a polar coordinate system"
  homepage "http://qwtpolar.sourceforge.net/"
  url "https://downloads.sf.net/project/qwtpolar/qwtpolar/1.1.1/qwtpolar-1.1.1.tar.bz2"
  sha256 "6168baa9dbc8d527ae1ebf2631313291a1d545da268a05f4caa52ceadbe8b295"
  revision 1

  option "with-examples", "Install source code for example apps"
  option "without-plugin", "Skip building the Qt Designer plugin"

  depends_on "qt5"
  depends_on "qwt"

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

      # Install Qt plugin in `lib/qt5/plugins/designer`, not `plugins/designer`.
      s.sub! %r{(= \$\$\{QWT_POLAR_INSTALL_PREFIX\})/(plugins/designer)$},
             "\\1/lib/qt5/\\2"
    end

    args = %w[-config release -spec]
    # On Mavericks we want to target libc++, this requires a macx-clang flag
    if ENV.compiler == :clang && MacOS.version >= :mavericks
      args << "macx-clang"
    else
      args << "macx-g++"
    end

    ENV["QMAKEFEATURES"] = "#{Formula["qwt"].opt_prefix}/features"
    system Formula["qt5"].bin/"qmake", *args
    system "make"
    system "make", "install"

    # Ensure designer plugin is linked back to opt_prefix
    if build.with? "plugin"
      plug = lib/"qt5/plugins/designer/libqwt_polar_designer_plugin.dylib"
      plug.ensure_writable do
        plug.dynamically_linked_libraries.each do |d|
          next unless d.to_s =~ /qwtpolar/
          system "install_name_tool", "-change", d, opt_lib/d.to_s, plug.to_s
        end
      end
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
    system ENV.cxx, "test.cpp", "-o", "out", "-std=c++11",
           "-framework", "qwtpolar", "-framework", "qwt", "-framework", "QtCore",
           "-F#{Formula["qt5"].opt_lib}", "-F#{Formula["qwt"].opt_lib}", "-F#{lib}",
           "-I#{lib}/qwtpolar.framework/Headers",
           "-I#{Formula["qwt"].opt_lib}/qwt.framework/Headers",
           "-I#{Formula["qt5"].opt_lib}/QtCore.framework/Headers",
           "-I#{Formula["qt5"].opt_lib}/QtGui.framework/Headers"
    system "./out"
  end
end

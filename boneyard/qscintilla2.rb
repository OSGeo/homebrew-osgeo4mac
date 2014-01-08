require 'formula'

class Qscintilla2 < Formula
  homepage 'http://www.riverbankcomputing.co.uk/software/qscintilla/intro'
  url 'http://downloads.sf.net/project/pyqt/QScintilla2/QScintilla-2.8/QScintilla-gpl-2.8.tar.gz'
  sha1 '3edf9d476d4e6af0706a4d33401667a38e3a697e'

  depends_on 'pyqt'
  depends_on 'sip'

  def install

    args = %W[-config release -spec]
    # On Mavericks we want to target libc++, this requires a unsupported/macx-clang-libc++ flag
    if ENV.compiler == :clang and MacOS.version >= :mavericks
      args << "unsupported/macx-clang-libc++"
    else
      args << "macx-g++"
    end

    cd 'Qt4Qt5' do
      inreplace 'qscintilla.pro' do |s|
        s.gsub! '$$[QT_INSTALL_LIBS]', lib
        s.gsub! "$$[QT_INSTALL_HEADERS]", include
        s.gsub! "$$[QT_INSTALL_TRANSLATIONS]", "#{prefix}/trans"
        s.gsub! "$$[QT_INSTALL_DATA]", "#{prefix}/data"
      end

      system "qmake", *args
      system "make"
      system "make", "install"
    end

    cd 'Python' do
      (share/"sip").mkpath
      system 'python', 'configure.py', "-o", lib, "-n", include,
                       "--apidir=#{prefix}/qsci",
                       "--destdir=#{lib}/python2.7/site-packages/PyQt4",
                       "--qsci-sipdir=#{share}/sip",
                       "--pyqt-sipdir=#{HOMEBREW_PREFIX}/share/sip"
      system 'make'
      system 'make', 'install'
    end

    plgd = prefix/"plugins"
    (plgd/"designer").mkpath
    cd "designer-Qt4Qt5" do
      inreplace "designer.pro" do |s|
        s.gsub! "$$[QT_INSTALL_LIBS]", lib
        s.gsub! "$$[QT_INSTALL_PLUGINS]", plgd
      end

      system "qmake", *args
      system "make"
      system "make", "install"
    end
    # symlink QT Designer plugin (note: not removed on formula uninstall)
    cd Formula.factory('qt').opt_prefix/"plugins/designer" do
      ln_sf plgd/"designer/libqscintillaplugin.dylib", "."
    end
  end

  test do
    system "python", "-c", "import PyQt4"
  end
end

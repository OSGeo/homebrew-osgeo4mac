require 'formula'

class Qwt60 < Formula
  homepage 'http://qwt.sourceforge.net/'
  url 'http://downloads.sourceforge.net/project/qwt/qwt/6.0.2/qwt-6.0.2.tar.bz2'
  sha1 'cbdd00b29521987c9e7bc6aa51092f0474b9428d'

  keg_only 'Conflicts with Qwt in main repository.'

  depends_on 'qt'

  def install
    inreplace 'qwtconfig.pri' do |s|
      # change_make_var won't work because there are leading spaces
      s.gsub! /^\s*QWT_INSTALL_PREFIX\s*=(.*)$/, "QWT_INSTALL_PREFIX=#{prefix}"
      # ensure frameworks aren't built, or qwtmathml linking fails to find -lqwt
      s << "\n" << 'QWT_CONFIG -= QwtFramework'
    end

    # see https://github.com/mxcl/homebrew/commit/e4df2f545a037c250f723981d65d59b08a37af44
    args = %w[-config release -spec]
    # On Mavericks we want to target libc++, this requires a unsupported/macx-clang-libc++ flag
    if ENV.compiler == :clang and MacOS.version >= :mavericks
      args << 'unsupported/macx-clang-libc++'
    else
      args << 'macx-g++'
    end
    system 'qmake', *args
    system 'make'
    system 'make install'
  end

  def caveats; <<-EOS.undent
      The qwtmathml library contains code of the MML Widget from the Qt solutions package.
      Beside the Qwt license you also have to take care of its license.
    EOS
  end
end

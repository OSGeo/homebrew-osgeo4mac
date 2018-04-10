require 'formula'

class Openjpeg20 < Formula
  homepage 'http://www.openjpeg.org/'
  url 'http://openjpeg.googlecode.com/files/openjpeg-2.0.0.tar.gz'
  sha1 '0af78ab2283b43421458f80373422d8029a9f7a7'

  keg_only 'Conflicts with openjpeg in main repository.'

  head 'http://openjpeg.googlecode.com/svn/trunk/'

  depends_on 'cmake' => :build
  depends_on 'little-cms2'
  depends_on 'libtiff'
  depends_on "libpng"

  def install
    system 'cmake', '.', *std_cmake_args
    system 'make install'
  end
end

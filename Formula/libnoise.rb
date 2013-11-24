require 'formula'

class Libnoise < Formula
  homepage 'http://libnoise.sourceforge.net/'
  url 'https://github.com/qknight/libnoise/archive/master.zip'
  sha1 '9b5572e4bff04a12aa97b044607e65f118948124'

  version '1.0.0-cmake'

  option "with-docs", 'Install documentation'

  depends_on 'cmake' => :build
  depends_on 'doxygen' if build.include? 'with-docs'

  def install
    inreplace "doc/CMakeLists.txt", "/usr/share", "#{share}" if build.include? 'with-docs'

    args = std_cmake_args
    args << "-DBUILD_LIBNOISE_DOCUMENTATION=ON" if build.include? 'with-docs'

    mkdir 'build' do
      system 'cmake', '..', *args
      system 'make install'
    end
  end
end

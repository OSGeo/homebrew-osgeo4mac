require 'formula'

class Osgearth < Formula
  homepage 'http://osgearth.org'
  url 'https://github.com/gwaldron/osgearth/archive/osgearth-2.4.tar.gz'
  sha1 'f5938da83ef235775856bce60e6f856a6709821b'

  devel do
    url 'https://github.com/gwaldron/osgearth/archive/osgearth-2.5-RC1.tar.gz'
    sha1 'e380fcc255dce8ebdaf445aee9bcd5329c7dbc5f'
  end

  head do
    url 'https://github.com/gwaldron/osgearth.git', :branch => 'master'
  end

  option 'with-minizip', 'Build with Google KMZ file (MiniZIP) support'
  option 'with-v8', 'Build with Google\'s V8 JavaScript engine to embed scripts in earth files'
  option 'external-tinyxml', 'Use external, instead of internal, libtinyxml'
  option :cxx11

  depends_on 'cmake' => :build
  depends_on 'open-scene-graph'
  depends_on 'gdal'
  depends_on 'minizip' => :optional
  depends_on 'v8' => :optional
  depends_on 'tinyxml' if build.include? 'external-tinyxml'

  def install
    cxxstdlib_check :skip
    ENV.cxx11 if build.cxx11?

    args = std_cmake_args
    if MacOS.prefer_64_bit?
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch_64_bit}"
    else
      args << "-DCMAKE_OSX_ARCHITECTURES=i386"
    end

    if build.with? 'minizip'
      args << "-DMINIZIP_INCLUDE_DIR='#{HOMEBREW_PREFIX}/include/minizip'"
      args << "-DMINIZIP_LIBRARY='#{HOMEBREW_PREFIX}/lib/libminizip.dylib'"
    end

    if build.with? 'v8'
      args << "-DV8_INCLUDE_DIR='#{HOMEBREW_PREFIX}/include'"
      args << "-DV8_LIBRARY='#{HOMEBREW_PREFIX}/lib/libv8.dylib'"
    end

    if build.include? 'external-tinyxml'
      args << '-DWITH_EXTERNAL_TINYXML=ON'
      args << "-DTINYXML_INCLUDE_DIR='#{HOMEBREW_PREFIX}/include'"
      args << "-DTINYXML_LIBRARY='#{HOMEBREW_PREFIX}/lib/libtinyxml.dylib'"
    end

    args << '..'

    mkdir 'build' do
      system 'cmake', *args
      system 'make'
      system 'make install'
    end
  end
end

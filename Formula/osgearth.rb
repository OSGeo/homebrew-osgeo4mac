require 'formula'

class Osgearth < Formula
  homepage 'http://osgearth.org'
  url 'https://github.com/gwaldron/osgearth/archive/osgearth-2.5.tar.gz'
  sha1 '97ed0075422c3efcb7b958f89ae02b32d670c48e'

  head do
    url 'https://github.com/gwaldron/osgearth.git', :branch => 'master'
  end

  option 'without-minizip', 'Build without Google KMZ file access support'
  option 'with-v8', 'Build with Google\'s V8 JavaScript engine support'
  option 'with-libnoise', 'Build with coherent noise-generating terrain support'
  option 'external-tinyxml', 'Use external libtinyxml, instead of internal'
  option 'with-docs-examples', 'Build and install html documentation and examples'
  option :cxx11

  depends_on 'cmake' => :build
  depends_on 'open-scene-graph'
  depends_on 'gdal'
  depends_on 'sqlite'
  depends_on 'qt' => :recommended
  depends_on 'minizip' => :recommended
  depends_on 'v8' => :optional
  depends_on 'libnoise' => :optional
  depends_on 'tinyxml' if build.include? 'external-tinyxml'

  depends_on :python => ['sphinx'] if build.include? 'with-docs-examples'

  def install
    cxxstdlib_check :skip
    ENV.cxx11 if build.cxx11?

    args = std_cmake_args
    if MacOS.prefer_64_bit?
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch_64_bit}"
    else
      args << "-DCMAKE_OSX_ARCHITECTURES=i386"
    end

    args << "-DOSG_DIR='#{HOMEBREW_PREFIX}'"

    sdkpath = (MacOS::CLT.installed?) ? "" : "#{MacOS.sdk_path}"
    jscore = "#{sdkpath}/System/Library/Frameworks/JavaScriptCore.framework"
    if File.exists?("#{jscore}/Headers")
      args << "-DJAVASCRIPTCORE_INCLUDE_DIR='#{jscore}/Headers'"
      args << "-DJAVASCRIPTCORE_LIBRARY='#{jscore}/JavaScriptCore'"
    end

    unless build.without? 'minizip'
      args << "-DMINIZIP_INCLUDE_DIR='#{HOMEBREW_PREFIX}/include/minizip'"
      args << "-DMINIZIP_LIBRARY='#{HOMEBREW_PREFIX}/lib/libminizip.dylib'"
    end

    if build.with? 'v8'
      # TODO: check with 32-bit build that 'basebit' suffix is indeed missing
      basebit = (MacOS.prefer_64_bit?) ? ".x64" : ""
      args << "-DV8_BASE_LIBRARY='#{HOMEBREW_PREFIX}/lib/libv8_base#{basebit}.a'"
      args << "-DV8_DIR='#{HOMEBREW_PREFIX}'"
    end

    if build.with? 'libnoise'
      args << "-DLIBNOISE_INCLUDE_DIR='#{HOMEBREW_PREFIX}/include/noise'"
      args << "-DLIBNOISE_LIBRARY='#{HOMEBREW_PREFIX}/lib/libnoise.dylib'"
    end

    if build.include? 'external-tinyxml'
      args << '-DWITH_EXTERNAL_TINYXML=ON'
      args << "-DTINYXML_INCLUDE_DIR='#{HOMEBREW_PREFIX}/include'"
      args << "-DTINYXML_LIBRARY='#{HOMEBREW_PREFIX}/lib/libtinyxml.dylib'"
    end

    args << '..'

    mkdir 'build' do
      system 'cmake', *args
      system 'make install'
    end

    if build.include? 'with-docs-examples'
      cd 'docs' do
        inreplace "Makefile", "sphinx-build", "#{HOMEBREW_PREFIX}/bin/sphinx-build"
        system 'make', 'html'
        doc.install "build/html" => 'html'
      end
      doc.install ['data', 'tests']
    end
  end

  def caveats; <<-EOS.undent
    This formula installs Open Scene Graph plugins. To ensure access when using
    the osgEarth toolset, set the OSG_LIBRARY_PATH enviroment variable (where
    `#.#.#` refers to the installed Open Scene Graph version):

      `export OSG_LIBRARY_PATH=#{HOMEBREW_PREFIX}/lib/osgPlugins-#.#.#`

    EOS
  end

  test do
    system "#{bin}/osgearth_version"
  end
end

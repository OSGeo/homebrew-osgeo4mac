require 'formula'

class Osgearth < Formula
  homepage 'http://osgearth.org'
  url 'https://github.com/gwaldron/osgearth/archive/osgearth-2.5.tar.gz'
  sha1 '97ed0075422c3efcb7b958f89ae02b32d670c48e'

  head 'https://github.com/gwaldron/osgearth.git', :branch => 'master'

  option 'without-minizip', 'Build without Google KMZ file access support'
  option 'with-v8', 'Build with Google\'s V8 JavaScript engine support'
  option 'with-libnoise', 'Build with coherent noise-generating terrain support'
  option 'with-tinyxml', 'Use external libtinyxml, instead of internal'
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
  depends_on 'tinyxml' => :optional

  depends_on :python => ['sphinx'] if build.with? 'docs-examples'

  # fixes finding a v8 lib: https://github.com/gwaldron/osgearth/pull/434
  def patches
    DATA
  end

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
      args << "-DV8_DIR='#{HOMEBREW_PREFIX}'"
    end

    if build.with? 'libnoise'
      args << "-DLIBNOISE_INCLUDE_DIR='#{HOMEBREW_PREFIX}/include/noise'"
      args << "-DLIBNOISE_LIBRARY='#{HOMEBREW_PREFIX}/lib/libnoise.dylib'"
    end

    if build.with? 'tinyxml'
      args << '-DWITH_EXTERNAL_TINYXML=ON'
      args << "-DTINYXML_INCLUDE_DIR='#{HOMEBREW_PREFIX}/include'"
      args << "-DTINYXML_LIBRARY='#{HOMEBREW_PREFIX}/lib/libtinyxml.dylib'"
    end

    mkdir 'build' do
      system 'cmake', '..', *args
      system 'make install'
    end

    if build.with? 'docs-examples'
      cd 'docs' do
        inreplace "Makefile", "sphinx-build", "#{HOMEBREW_PREFIX}/bin/sphinx-build"
        system 'make', 'html'
        doc.install "build/html" => 'html'
      end
      doc.install 'data'
      doc.install 'tests' => 'examples'
    end
  end

  def caveats
    osg = Formula.factory('open-scene-graph')
    osgver = (osg.installed?) ? osg.prefix.basename : '#.#.# (version)'
    <<-EOS.undent
    This formula installs Open Scene Graph plugins. To ensure access when using
    the osgEarth toolset, set the OSG_LIBRARY_PATH enviroment variable to:

      #{HOMEBREW_PREFIX}/lib/osgPlugins-#{osgver}

    EOS
  end

  test do
    system "#{bin}/osgearth_version"
  end
end

__END__
diff --git a/CMakeModules/FindV8.cmake b/CMakeModules/FindV8.cmake
index 9f5684d..94cf4c4 100644
--- a/CMakeModules/FindV8.cmake
+++ b/CMakeModules/FindV8.cmake
@@ -21,7 +21,7 @@ FIND_PATH(V8_INCLUDE_DIR v8.h
 )
 
 FIND_LIBRARY(V8_BASE_LIBRARY
-    NAMES v8_base v8_base.ia32 libv8_base
+    NAMES v8_base v8_base.ia32 v8_base.x64 libv8_base
     PATHS
     ${V8_DIR}
     ${V8_DIR}/lib
@@ -40,7 +40,7 @@ FIND_LIBRARY(V8_BASE_LIBRARY
 )
 
 FIND_LIBRARY(V8_BASE_LIBRARY_DEBUG
-    NAMES v8_base v8_base.ia32 libv8_base
+    NAMES v8_base v8_base.ia32 v8_base.x64 libv8_base
     PATHS
     ${V8_DIR}
     ${V8_DIR}/lib

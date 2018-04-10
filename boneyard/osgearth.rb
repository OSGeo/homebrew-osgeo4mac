require "formula"

class Osgearth < Formula
  homepage "http://osgearth.org"
  url "https://github.com/gwaldron/osgearth/archive/osgearth-2.5.tar.gz"
  sha1 "97ed0075422c3efcb7b958f89ae02b32d670c48e"

  head "https://github.com/gwaldron/osgearth.git", :branch => "master"

  option "without-minizip", "Build without Google KMZ file access support"
  option "with-v8", "Build with Google's V8 JavaScript engine support"
  option "with-libnoise", "Build with coherent noise-generating terrain support"
  option "with-tinyxml", "Use external libtinyxml, instead of internal"
  option "with-docs-examples", "Build and install html documentation and examples"

  depends_on "cmake" => :build
  depends_on "open-scene-graph"
  depends_on "gdal"
  depends_on "sqlite"
  depends_on "qt" => :recommended
  depends_on "minizip" => :recommended
  depends_on "v8" => :optional
  depends_on "libnoise" => :optional
  depends_on "tinyxml" => :optional

  resource "sphinx" do
    url "https://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.2.1.tar.gz"
    sha1 "448cdb89d96c85993e01fe793ce7786494cbcda7"
  end

  # all merged upstream, remove on next version
  # find a v8 lib: https://github.com/gwaldron/osgearth/pull/434
  # find JavaScriptCore lib: https://github.com/gwaldron/osgearth/pull/435
  # find libnoise lib: https://github.com/gwaldron/osgearth/pull/436
  def patches
    DATA
  end

  def install
    if build.with? "docs-examples" and not which("sphinx-build")
      # temporarily vendor a local sphinx install
      sphinx_dir = prefix/"sphinx"
      sphinx_site = sphinx_dir/"lib/python2.7/site-packages"
      sphinx_site.mkpath
      ENV.prepend_create_path "PYTHONPATH", sphinx_site
      resource("sphinx").stage {quiet_system "python2.7", "setup.py", "install", "--prefix=#{sphinx_dir}"}
      ENV.prepend_path "PATH", sphinx_dir/"bin"
    end

    args = std_cmake_args
    if MacOS.prefer_64_bit?
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch_64_bit}"
    else
      args << "-DCMAKE_OSX_ARCHITECTURES=i386"
    end

    args << "-DOSGEARTH_USE_QT=OFF" if build.without? "qt"
    args << "-DWITH_EXTERNAL_TINYXML=ON" if build.with? "tinyxml"

    # v8, noise and minizip options should have empty values if not defined '--with'
    if build.without? "v8"
      args << "-DV8_INCLUDE_DIR=''" << "-DV8_BASE_LIBRARY=''" << "-DV8_SNAPSHOT_LIBRARY=''"
      args << "-DV8_ICUI18N_LIBRARY=''" << "-DV8_ICUUC_LIBRARY=''"
    end
    args << "-DLIBNOISE_INCLUDE_DIR=''" << "-DLIBNOISE_LIBRARY=''" if build.without? "libnoise"
    # define libminizip paths (skips the only pkconfig dependency in cmake modules)
    mzo = Formula.factory("minizip").opt_prefix
    args << "-DMINIZIP_INCLUDE_DIR=#{(build.with? "minizip") ? mzo/"include/minizip" : "''"}"
    args << "-DMINIZIP_LIBRARY=#{(build.with? "minizip") ? mzo/"lib/libminizip.dylib" : "''"}"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end

    if build.with? "docs-examples"
      cd "docs" do
        system "make", "html"
        doc.install "build/html" => "html"
      end
      doc.install "data"
      doc.install "tests" => "examples"
      rm_r prefix/"sphinx" if File.exist?(prefix/"sphinx")
    end
  end

  def caveats
    osg = Formula.factory("open-scene-graph")
    osgver = (osg.linked_keg.exist?) ? osg.version : "#.#.# (version)"
    <<~EOS
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
diff --git a/CMakeModules/FindJavaScriptCore.cmake b/CMakeModules/FindJavaScriptCore.cmake
index 1bca250..3877cd5 100644
--- a/CMakeModules/FindJavaScriptCore.cmake
+++ b/CMakeModules/FindJavaScriptCore.cmake
@@ -21,7 +21,7 @@ FIND_PATH(JAVASCRIPTCORE_INCLUDE_DIR JavaScriptCore.h
 )

 FIND_LIBRARY(JAVASCRIPTCORE_LIBRARY
-    NAMES libJavaScriptCore
+    NAMES libJavaScriptCore JavaScriptCore
     PATHS
     ${JAVASCRIPTCORE_DIR}
     ${JAVASCRIPTCORE_DIR}/lib
diff --git a/CMakeModules/FindLibNoise.cmake b/CMakeModules/FindLibNoise.cmake
index 99d006b..0051b51 100644
--- a/CMakeModules/FindLibNoise.cmake
+++ b/CMakeModules/FindLibNoise.cmake
@@ -43,7 +43,7 @@ FIND_LIBRARY(LIBNOISE_LIBRARY
 )

 FIND_LIBRARY(LIBNOISE_LIBRARY
-  NAMES libnoise
+  NAMES libnoise noise
   PATHS
     ~/Library/Frameworks
     /Library/Frameworks

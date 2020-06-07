class OsgearthQt4 < Formula
  desc "Geospatial SDK and terrain engine for OpenSceneGraph"
  homepage "http://osgearth.org"
  url "https://github.com/gwaldron/osgearth.git",
    :branch => "2.7",
    :commit => "dda0f0a92cedc83d6d40ed69cfb01140008f9911"
  version "2.7.0"
  # QGIS Globe Plugin does not support a larger version than OSGearh v2.7.

  # revision 1

  head "https://github.com/gwaldron/osgearth.git", :branch => "master"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    sha256 "7080cdc8b0da8e250cc48fc3288236ed0366ad7beca38a638fca358a5986e551" => :mojave
    sha256 "7080cdc8b0da8e250cc48fc3288236ed0366ad7beca38a638fca358a5986e551" => :high_sierra
    sha256 "7080cdc8b0da8e250cc48fc3288236ed0366ad7beca38a638fca358a5986e551" => :sierra
  end

  # The OSGearth 2.7 version is not being built with GDAL 2.x.
  patch :DATA

  option "without-minizip", "Build without Google KMZ file access support"
  option "with-v8", "Build with Google's V8 JavaScript engine support"
  option "with-tinyxml", "Use external libtinyxml, instead of internal"
  option "with-docs-examples", "Build and install html documentation and examples"

  depends_on "cmake" => :build
  # depends_on "gdal2"
  depends_on "sqlite"
  depends_on "qt-4"
  depends_on "minizip" => :recommended
  depends_on "v8" => :optional
  depends_on "tinyxml" => :optional

  if (build.with? "docs-examples") && (!which("sphinx-build"))
    # temporarily vendor a local sphinx install
    sphinx_dir = prefix/"sphinx"
    sphinx_site = sphinx_dir/"lib/python#{py_ver}/site-packages"
    sphinx_site.mkpath
    ENV.prepend_create_path "PYTHONPATH", sphinx_site
    resource("Sphinx").stage { quiet_system "python#{py_ver}", "setup.py", "install", "--prefix=#{sphinx_dir}" }
    ENV.prepend_path "PATH", sphinx_dir/"bin"
  end

  def install
    if (build.with? "docs-examples") && (!which("sphinx-build"))
      # temporarily vendor a local sphinx install
      sphinx_dir = prefix/"sphinx"
      sphinx_site = sphinx_dir/"lib/python2.7/site-packages"
      sphinx_site.mkpath
      ENV.prepend_create_path "PYTHONPATH", sphinx_site
      resource("sphinx").stage { quiet_system "python2.7", "setup.py", "install", "--prefix=#{sphinx_dir}" }
      ENV.prepend_path "PATH", sphinx_dir/"bin"
    end

    args = std_cmake_args

    args << "-DOSGEARTH_USE_QT=OFF"

    args << "-DWITH_EXTERNAL_TINYXML=ON" if build.with? "tinyxml"

    # v8 and minizip options should have empty values if not defined '--with'
    if build.without? "v8"
      args << "-DV8_INCLUDE_DIR=''" << "-DV8_BASE_LIBRARY=''" << "-DV8_SNAPSHOT_LIBRARY=''"
      args << "-DV8_ICUI18N_LIBRARY=''" << "-DV8_ICUUC_LIBRARY=''"
    end
    # define libminizip paths (skips the only pkconfig dependency in cmake modules)
    mzo = Formula["minizip"].opt_prefix
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
    osg = Formula["open-scene-graph"]
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

--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -117,7 +117,7 @@
 FIND_PACKAGE(OpenGL)

 FIND_PACKAGE(CURL)
-FIND_PACKAGE(GDAL)
+# FIND_PACKAGE(GDAL)
 FIND_PACKAGE(GEOS)
 FIND_PACKAGE(Sqlite3)
 FIND_PACKAGE(ZLIB)

class OsgearthQt4 < Formula
  desc "Geospatial SDK and terrain engine for OpenSceneGraph"
  homepage "http://osgearth.org"
  url "https://github.com/gwaldron/osgearth/archive/osgearth-2.7.tar.gz"
  sha256 "945bd4d0bc65143a14caeb434b07384eccef1ba89ae11282fc499903a251ec18"

  # revision 1

  head "https://github.com/gwaldron/osgearth.git", :branch => "master"

  bottle do
    cellar :any
    sha256 "48cba11c49074ecbb6dda61a8a5a44881bb7aa121ecfb0eb9a61fb4eb5f05ad7" => :yosemite
    sha256 "289d4169172f3a15c3e84b966fab8114bb0e92358af8274aecea8a098e923dda" => :mavericks
  end

  option "without-minizip", "Build without Google KMZ file access support"
  option "with-v8", "Build with Google's V8 JavaScript engine support"
  option "with-tinyxml", "Use external libtinyxml, instead of internal"
  option "with-docs-examples", "Build and install html documentation and examples"

  depends_on "cmake" => :build
  depends_on "gdal"
  depends_on "sqlite"
  depends_on "qt-4"
  depends_on "minizip" => :recommended
  depends_on "v8" => :optional
  depends_on "tinyxml" => :optional
  depends_on :macos => :mavericks

  resource "sphinx" do
    url "https://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.2.1.tar.gz"
    sha256 "182e5c81c3250e1752e744b6a35af4ef680bb6251276b49ef7d17f1d25e9ce70"
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

    args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch_64_bit}"

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

class OsgeoPyspatialite < Formula
  desc "DB-API 2.0 interface for SQLite with Spatialite"
  homepage "https://code.google.com/p/pyspatialite"

  revision 5

  head "https://code.google.com/p/pyspatialite/", :using => :hg

  stable do
    # temporary download of source, prior to pyspatialite move to github
    url "https://osgeo4mac.s3.amazonaws.com/src/pyspatialite-3.0.1.tar.gz"
    sha256 "81a3e4966fb6348802a985486cbf62e019a0fcb0a1e006b9522e8b02dc08f238"
    patch do
      # Patch to work with libspatialite 4.x, drop amalgamation support, dynamically
      # link libspatialite and sqlite3, and fix redeclaration build error
      # Reported upstream: http://code.google.com/p/pyspatialite/issues/detail?id=15
      # (not tested/supported with HEAD builds)
      url "https://gist.githubusercontent.com/alazarolop/55d05517b8bc6d79c07e65e138500541/raw/d2ae95deef2841543179e55935f4ad296ba0a039/pyspatialite-4.1-Mac-patch-p3.diff"
      sha256 "97b2e70881651389304cbf450f3e83ce872f2425ae07bef3bb4edbf88d44a068"
    end
  end
  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "e092709d45638000fc044d2072230ed80abd586513b90539872e1113cd0da6a5" => :mojave
    sha256 "e092709d45638000fc044d2072230ed80abd586513b90539872e1113cd0da6a5" => :high_sierra
    sha256 "a3139ac50f2e8c5c202cb22a26a74b1a54f188780e2583a00eace33a471e9c7c" => :sierra
  end


  depends_on "python"
  depends_on "geos"
  depends_on "osgeo-proj"
  depends_on "sqlite"
  depends_on "osgeo-libspatialite"

  def install
    # write setup.cfg
    (buildpath/"setup.cfg").write <<~EOS
      [build_ext]
      include_dirs=#{HOMEBREW_PREFIX}/include/:#{HOMEBREW_PREFIX}/opt/sqlite/include/
      library_dirs=#{HOMEBREW_PREFIX}/lib:#{HOMEBREW_PREFIX}/opt/sqlite/lib
    EOS

    system "#{Formula["python"].opt_bin}/python3", "setup.py", "build"
    system "#{Formula["python"].opt_bin}/python3", "setup.py", "install", "--prefix=#{prefix}"
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system "python3", "-c", "import pyspatialite"
    end
  end
end

class OsgeoPyspatialite < Formula
  desc "DB-API 2.0 interface for SQLite with Spatialite"
  homepage "https://code.google.com/p/pyspatialite"

  revision 2

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
      url "https://gist.github.com/dakcarto/7510460/raw/2e56dd217c19d8dd661e4d3ffb2b669f34da580b/pyspatialite-3.0.1-Mac-patch.diff"
      sha256 "8696caaadfc6edf9aa159fe61ed44ce1eac23da2fd68c242148fc2218e6c6901"
    end
  end
  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "688bd53195ba337462aa64ad99adf040058fd2ca110b61889f131e3ed77ccd13" => :mojave
    sha256 "688bd53195ba337462aa64ad99adf040058fd2ca110b61889f131e3ed77ccd13" => :high_sierra
    sha256 "cf4354ad4491e84e976ae0af14ce4490cf8b3646f46061915a5a2fb307f69877" => :sierra
  end


  depends_on "python@2"
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

    system "#{Formula["python@2"].opt_bin}/python2", "setup.py", "build"
    system "#{Formula["python@2"].opt_bin}/python2", "setup.py", "install", "--prefix=#{prefix}"
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import pyspatialite"
    end
  end
end

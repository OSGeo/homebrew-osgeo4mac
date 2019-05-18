class OsgeoGdalFilegdb < Formula
  desc "GDAL/OGR 2.x plugin for ESRI FileGDB driver"
  homepage "http://www.gdal.org/drv_filegdb.html"
  url "https://download.osgeo.org/gdal/2.4.1/gdal-2.4.1.tar.gz"
  sha256 "f1a11d1982205b9e4cc10e16f016a5559bfc9fa9a9ea69015e99ccd6a738ea4c"

  revision 1

  head "https://github.com/OSGeo/gdal.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "06b710042bf008561b3ac3924c88457513a3fa612fbcbfc3e746ae1b4f6895a5" => :mojave
    sha256 "06b710042bf008561b3ac3924c88457513a3fa612fbcbfc3e746ae1b4f6895a5" => :high_sierra
    sha256 "96ed6da1839e26d55c2b3de33f5049a9a5daf6fd63977bfe784c5ba767992eb7" => :sierra
  end

  depends_on "osgeo-filegdb-api"
  depends_on "osgeo-gdal"

  def gdal_majmin_ver
    gdal_ver_list = Formula["osgeo-gdal"].version.to_s.split(".")
    "#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def gdal_plugins_subdirectory
    "gdalplugins/#{gdal_majmin_ver}"
  end

  def install
    ENV.cxx11
    filegdb_opt = Formula["osgeo-filegdb-api"].opt_prefix

    gdal_plugins = lib/gdal_plugins_subdirectory
    gdal_plugins.mkpath

    # cxx flags
    args = %W[-Iport -Igcore -Iogr -Iogr/ogrsf_frmts -Iogr/ogrsf_frmts/generic
              -Iogr/ogrsf_frmts/filegdb -I#{filegdb_opt}/include/filegdb]

    # source files
    Dir["ogr/ogrsf_frmts/filegdb/*.c*"].each do |src|
      args.concat %W[#{src}]
    end

    # plugin dylib
    dylib_name = "ogr_FileGDB.dylib"
    args.concat %W[
      -dynamiclib
      -install_name #{opt_lib}/#{gdal_plugins_subdirectory}/#{dylib_name}
      -current_version #{version}
      -compatibility_version #{gdal_majmin_ver}.0
      -o #{gdal_plugins}/#{dylib_name}
      -undefined dynamic_lookup
    ]

    # ld flags
    args.concat %W[-L#{filegdb_opt}/lib -lFileGDBAPI]

    # build and install shared plugin
    system ENV.cxx, *args
  end

  def caveats; <<~EOS
      This formula provides a plugin that allows GDAL or OGR to access geospatial
      data stored in its format. In order to use the shared plugin, you may need
      to set the following enviroment variable:

        export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins
    EOS
  end

  test do
    ENV["GDAL_DRIVER_PATH"] = "#{HOMEBREW_PREFIX}/lib/gdalplugins"
    gdal_opt_bin = Formula["osgeo-gdal"].opt_bin
    out = shell_output("#{gdal_opt_bin}/ogrinfo --formats")
    assert_match "FileGDB -vector- (rw+)", out
  end
end

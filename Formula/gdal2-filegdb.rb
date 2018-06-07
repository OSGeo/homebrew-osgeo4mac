class Gdal2Filegdb < Formula
  desc "GDAL/OGR 2.x plugin for ESRI FileGDB driver"
  homepage "http://www.gdal.org/drv_filegdb.html"
  url "http://download.osgeo.org/gdal/2.3.0/gdal-2.3.0.tar.gz"
  sha256 "2944bbfee009bf1ca092716e4fd547cb4ae2a1e8816186236110c22f11c7e1e9"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "60ee125ad80a95510815a63c13e23b8892ca74c5d662186d1d4d4c83df5aa2c4" => :high_sierra
    sha256 "60ee125ad80a95510815a63c13e23b8892ca74c5d662186d1d4d4c83df5aa2c4" => :sierra
  end

  depends_on "filegdb-api"
  depends_on "gdal2"

  def gdal_majmin_ver
    gdal_ver_list = Formula["gdal2"].version.to_s.split(".")
    "#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def gdal_plugins_subdirectory
    "gdalplugins/#{gdal_majmin_ver}"
  end

  def install
    ENV.cxx11
    filegdb_opt = Formula["filegdb-api"].opt_prefix

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
    gdal_opt_bin = Formula["gdal2"].opt_bin
    out = shell_output("#{gdal_opt_bin}/ogrinfo --formats")
    assert_match "FileGDB -vector- (rw+)", out
  end
end

class Gdal1Oracle < Formula
  desc "GDAL/OGR 1.x plugin for Oracle Spatial driver"
  homepage "http://www.gdal.org/drv_oci.html"
  url "http://download.osgeo.org/gdal/1.11.5/gdal-1.11.5.tar.gz"
  sha256 "49f99971182864abed9ac42de10545a92392d88f7dbcfdb11afe449a7eb754fe"

  depends_on "oracle-client-sdk"
  depends_on "gdal"

  def gdal_majmin_ver
    gdal_ver_list = Formula["gdal"].version.to_s.split(".")
    "#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def gdal_plugins_subdirectory
    "gdalplugins/#{gdal_majmin_ver}"
  end

  def install
    oracle_opt = Formula["oracle-client-sdk"].opt_prefix

    gdal_plugins = lib/gdal_plugins_subdirectory
    gdal_plugins.mkpath
    (HOMEBREW_PREFIX/"lib/#{gdal_plugins_subdirectory}").mkpath

    # cxx flags
    args = %W[-Iport -Igcore -Iogr -Iogr/ogrsf_frmts -Iogr/ogrsf_frmts/generic
              -Iogr/ogrsf_frmts/oci -I#{oracle_opt}/include/oci]

    # source files
    Dir["ogr/ogrsf_frmts/oci/oci_utils.cpp", "ogr/ogrsf_frmts/oci/ogr*.c*"].each do |src|
      args.concat %W[#{src}]
    end

    # plugin dylib
    dylib_name = "ogr_OCI.dylib"
    args.concat %W[
      -dynamiclib
      -install_name #{opt_lib}/#{gdal_plugins_subdirectory}/#{dylib_name}
      -current_version #{version}
      -compatibility_version #{gdal_majmin_ver}.0
      -o #{gdal_plugins}/#{dylib_name}
      -undefined dynamic_lookup
    ]

    # ld flags
    args.concat %W[-L#{oracle_opt}/lib -lclntsh]

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
    gdal_opt_bin = Formula["gdal"].opt_bin
    out = `#{gdal_opt_bin}/ogrinfo --formats`
    assert_match "\"OCI\" (read/write)", out
  end
end

class OsgeoGdalOracle < Formula
  desc "GDAL/OGR 3.x plugin for Oracle Spatial driver"
  homepage "http://www.gdal.org/drv_oci.html"
  url "https://download.osgeo.org/gdal/3.1.2/gdal-3.1.2.tar.xz"
  sha256 "767c8d0dfa20ba3283de05d23a1d1c03a7e805d0ce2936beaff0bb7d11450641"

  # revision 1

  head "https://github.com/OSGeo/gdal.git", :branch => "master"

  # bottle do
  #   never
  # end

  depends_on "osgeo-oracle-client-sdk"
  depends_on "osgeo-gdal"

  def gdal_majmin_ver
    gdal_ver_list = Formula["osgeo-gdal"].version.to_s.split(".")
    "#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def gdal_plugins_subdirectory
    "gdalplugins/#{gdal_majmin_ver}"
  end

  def install
    oracle_opt = Formula["osgeo-oracle-client-sdk"].opt_prefix

    gdal_plugins = lib/gdal_plugins_subdirectory
    gdal_plugins.mkpath

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
      -std=c++11
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
    gdal_opt_bin = Formula["osgeo-gdal"].opt_bin
    out = shell_output("#{gdal_opt_bin}/ogrinfo --formats")
    assert_match "OCI -vector- (rw+)", out
  end
end

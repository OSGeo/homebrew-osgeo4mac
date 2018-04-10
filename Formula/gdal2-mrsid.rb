class Gdal2Mrsid < Formula
  desc "GDAL/OGR 2 plugin for MrSID raster and LiDAR drivers"
  homepage "http://www.gdal.org/frmt_mrsid.html"
  url "http://download.osgeo.org/gdal/2.2.4/gdal-2.2.4.tar.gz"
  sha256 "b9d5a723787f3006a82cb276db171c721187b048b866c0e20e6df464d671a1a4"

  # bottle do
  #   never
  # end

  depends_on "mrsid-sdk"
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
    mrsid_sdk_opt = Formula["mrsid-sdk"].opt_prefix

    gdal_plugins = lib/gdal_plugins_subdirectory
    gdal_plugins.mkpath

    plugins = {}
    lidar_args = []
    mrsid_args = []

    # source files & cxx/ld flags
    # gdal_MG4Lidar.dylib
    Dir["frmts/mrsid_lidar/*.c*"].each { |src| lidar_args.concat %W[#{src}] }
    lidar_args.concat %W[
      -Iport -Igcore -Ifrmts -Ifrmts/mrsid_lidar
      -I#{mrsid_sdk_opt}/include/mrsid
    ]
    lidar_args.concat %W[-L#{mrsid_sdk_opt}/lib -llti_lidar_dsdk]
    plugins[:gdal_MG4Lidar] = lidar_args

    # gdal_MrSID.dylib
    Dir["frmts/mrsid/*.c*"].each { |src| mrsid_args.concat %W[#{src}] }
    mrsid_args.concat %W[
      -DMRSID_J2K=1
      -Iport -Igcore -Ifrmts -Ifrmts/mrsid -Ifrmts/gtiff/libgeotiff
      -I#{mrsid_sdk_opt}/include/mrsid
    ]
    mrsid_args.concat %W[-L#{mrsid_sdk_opt}/lib -lltidsdk]
    plugins[:gdal_MrSID] = mrsid_args

    # plugin dylib
    plugins.each do |key, args|
      args.concat %W[
        -dynamiclib
        -install_name #{opt_lib}/#{gdal_plugins_subdirectory}/#{key}.dylib
        -current_version #{version}
        -compatibility_version #{gdal_majmin_ver}.0
        -o #{gdal_plugins}/#{key}.dylib
        -undefined dynamic_lookup
      ]
      # build and install shared plugin
      system ENV.cxx, *args
    end
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
    out = shell_output("#{gdal_opt_bin}/gdalinfo --formats")
    assert_match "MG4Lidar -raster- (ro)", out
    assert_match "MrSID -raster- (rov)", out
    assert_match "JP2MrSID -raster- (rov)", out
  end
end

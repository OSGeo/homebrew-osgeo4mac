class Gdal2Mrsid < Formula
  desc "MrSID raster and LiDAR plugins for GDAL"
  homepage "http://www.gdal.org/frmt_mrsid.html"
  url "http://download.osgeo.org/gdal/2.1.0/gdal-2.1.0.tar.gz"
  sha256 "eb499b18e5c5262a803bb7530ae56e95c3293be7b26c74bcadf67489203bf2cd"

  depends_on "mrsid-sdk"
  depends_on "gdal-20"

  def install
    mrsid_sdk_opt = Formula["mrsid-sdk"].opt_prefix
    gdal_ver_list = version.to_s.split(".")
    gdal_majmin_ver = "#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
    gdal_plugins = lib/"gdalplugins/#{gdal_majmin_ver}"
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

    # configure gdal
    gdal_args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--with-local=#{prefix}",
      "--with-threads",
      "--with-libtool",
    ]
    system "./configure", *gdal_args

    # plugin dylib
    plugins.each do |key, args|
      # TODO: can the compatibility_version be 1.10.0?
      args.concat %W[
        -dynamiclib
        -install_name #{gdal_plugins}/#{key}.dylib
        -current_version #{version}
        -compatibility_version #{version}
        -o #{gdal_plugins}/#{key}.dylib
        -undefined dynamic_lookup
      ]
      # build and install shared plugin
      system ENV.cxx, *args
    end
  end

  def caveats; <<-EOS.undent
      This formula provides a plugin that allows GDAL or OGR to access geospatial
      data stored in its format. In order to use the shared plugin, you will need
      to set the following enviroment variable:

        export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins
    EOS
  end

  test do
    #
  end
end

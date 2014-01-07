require "formula"
require File.expand_path("../../Requirements/gdal_third_party", Pathname.new(__FILE__).realpath)

class GdalMrsid < Formula
  homepage "http://www.gdal.org/frmt_mrsid.html"
  url "http://download.osgeo.org/gdal/1.10.1/gdal-1.10.1.tar.gz"
  sha1 "b4df76e2c0854625d2bedce70cc1eaf4205594ae"

  option "with-docs", "Intall third-party library documentation and examples"

  depends_on GdalThirdParty
  depends_on "geos"
  depends_on "jasper"
  depends_on "tbb" # threading building blocks
  depends_on "gdal"

  resource "mrsid" do
    url "file://#{ENV["GDAL_THIRD_PARTY"]}/MrSID_DSDK-9.0.0.3864-darwin12.universal.gccA42.tar.gz"
    sha1 "8a693cc71dbb8638f34e35efb8086f29b08fa764"
    version "9.0.0"
  end

  def install

    # stage third-party libs in prefix
    mrsid = prefix/"mrsid"
    mrsid.mkpath
    lidar_dsdk = mrsid/"Lidar_DSDK"
    raster_dsdk = mrsid/"Raster_DSDK"

    resource("mrsid").stage do
      # first strip unnecessary installs
      rm_r "Raster_DSDK/3rd-party" # already part of gdal install
      rm Dir["Raster_DSDK/lib/libgeos*"]
      rm "Raster_DSDK/lib/libtbb.dylib"
      unless build.with? "docs"
        rm_r "examples"
        cd "Lidar_DSDK" do
          %W[contributions doc examples].each {|f| rm_r f}
        end
        cd "Raster_DSDK" do
          %W[doc examples].each {|f| rm_r f}
        end
      end

      mrsid.install Dir["*"]
    end

    # link to binary executables
    bin.mkpath
    cd bin do
      %W[lidardecode lidarinfo].each {|f| ln_s lidar_dsdk/"bin/#{f}", f}
      %W[mrsiddecode mrsidinfo].each {|f| ln_s raster_dsdk/"bin/#{f}", f}
    end

    # update third-party libs
    cd lidar_dsdk/"lib" do
      # convert base version to symlink again
      rm "liblti_lidar_dsdk.dylib"
      ln_s "liblti_lidar_dsdk.1.dylib", "liblti_lidar_dsdk.dylib"

      system "install_name_tool", "-id",
             "#{lidar_dsdk}/lib/liblti_lidar_dsdk.1.dylib",
             "liblti_lidar_dsdk.1.dylib"
    end
    cd raster_dsdk/"lib" do
      # convert base versions to symlinks again
      rm "libltidsdk.dylib"
      ln_s "libltidsdk.9.dylib", "libltidsdk.dylib"

      system "install_name_tool", "-id",
             "#{raster_dsdk}/lib/libltidsdk.9.dylib",
             "libltidsdk.9.dylib"

      tbb = Formula.factory("tbb")
      system "install_name_tool", "-change",
             "libtbb.dylib",
             "#{tbb.opt_prefix}/lib/libtbb.dylib",
             "libltidsdk.dylib"
    end

    (lib/"gdalplugins").mkpath
    plugins = {}
    ldr_args, sid_args = [], []

    # source files & cxx/ld flags
    # gdal_MG4Lidar.dylib
    Dir["frmts/mrsid_lidar/*.c*"].each { |src| ldr_args.concat %W[#{src}] }
    ldr_args.concat %W[-Iport -Igcore -Ifrmts -Ifrmts/mrsid_lidar -I#{lidar_dsdk}/include]
    ldr_args.concat %W[-L#{lidar_dsdk}/lib -llti_lidar_dsdk]
    plugins[:gdal_MG4Lidar] = ldr_args

    # gdal_MrSID.dylib
    Dir["frmts/mrsid/*.c*"].each { |src| sid_args.concat %W[#{src}] }
    sid_args.concat %W[-Iport -Igcore -Ifrmts -Ifrmts/mrsid -I#{raster_dsdk}/include]
    sid_args.concat %W[-L#{HOMEBREW_PREFIX}/lib -lgeotiff -ljasper -L#{raster_dsdk}/lib -lltidsdk]
    plugins[:gdal_MrSID] = sid_args

    # plugin dylib
    plugins.each do |key, args|
      # TODO: can the compatibility_version be 1.10.0?
      args.concat %W[
        -dynamiclib
        -install_name #{HOMEBREW_PREFIX}/lib/gdalplugins/#{key.to_s}.dylib
        -current_version #{version}
        -compatibility_version #{version}
        -o #{lib}/gdalplugins/#{key.to_s}.dylib
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

      The MrSID libraries are `keg-only`. To build software that uses them, add
      to the following environment variables:

        CPPFLAGS: -I#{opt_prefix}/mrsid/Lidar_DSDK/include/lidar
        LDFLAGS:  -L#{opt_prefix}/mrsid/Lidar_DSDK/lib

        CPPFLAGS: -I#{opt_prefix}/mrsid/Raster_DSDK/include
        LDFLAGS:  -L#{opt_prefix}/mrsid/Raster_DSDK/lib

      ============================== IMPORTANT ==============================
      If compiled using clang (default) on 10.9+ this plugin links to libc++
      (whereas MrSID libs/binaries link to libstdc++). This may lead to issues
      during usage, including crashes. Please report any issues to:
          https://github.com/dakcarto/homebrew-osgeo4mac/issues

    EOS
  end
end

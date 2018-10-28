class Gdal2Mongodb < Formula
  desc "GDAL/OGR 2.x plugin for MongoDB driver"
  homepage "http://www.gdal.org/drv_mongodb.html"
  url "http://download.osgeo.org/gdal/2.3.2/gdal-2.3.2.tar.gz"
  sha256 "7808dd7ea7ee19700a133c82060ea614d4a72edbf299dfcb3713f5f79a909d64"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 1
    sha256 "985fdb1a63a9ba5b871213cd015e6b0ba165bc41462bc17d1fe28d704c9bcf43" => :high_sierra
    sha256 "985fdb1a63a9ba5b871213cd015e6b0ba165bc41462bc17d1fe28d704c9bcf43" => :sierra
  end

  depends_on "gdal2"
  depends_on "libtiff"
  depends_on "libgeotiff"
  depends_on "mongo-cxx-driver-legacy"
  depends_on "boost"

  def gdal_majmin_ver
    gdal_ver_list = Formula["gdal2"].version.to_s.split(".")
    "#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def gdal_plugins_subdirectory
    "gdalplugins/#{gdal_majmin_ver}"
  end

  def configure_args
    args = [
      # Base configuration.
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--with-local=#{prefix}",
      "--with-threads",
      "--with-libtool",
      # force correction of dylib setup, even though we are not building framework here
      "--with-macosx-framework",
    ]

    args << "--with-mongocxx=#{Formula["mongo-cxx-driver-legacy"].opt_prefix}"

    # nix all other configure tests, i.e. minimal base gdal build
    without_pkgs = %w[
      armadillo bsb cfitsio cryptopp curl dds dods-root
      ecw epsilon expat fgdb fme freexl
      geos gif gnm grass grib gta
      hdf4 hdf5 idb ingres
      jasper jp2mrsid jpeg jpeg12 kakadu kea
      libgrass libkml liblzma libz
      mdb mrf mrsid_lidar mrsid msg mysql netcdf
      oci odbc ogdi opencl openjpeg
      pam pcidsk pcraster pcre perl pg php png python
      qhull rasdaman rasterlite2
      sde sfcgal sosi spatialite sqlite3 static-proj4
      teigha webp xerces xml2
    ]
    args.concat without_pkgs.map { |b| "--without-" + b }
    args
  end

  def install
    gdal_plugins = lib/gdal_plugins_subdirectory
    gdal_plugins.mkpath

    ENV.cxx11

    # configure GDAL/OGR with minimal drivers
    system "./configure", *configure_args

    # cxx flags
    args = %W[-DLINUX -DUNIX -Iport -Igcore -Iogr
              -Iogr/ogrsf_frmts -Iogr/ogrsf_frmts/generic
              -Iogr/ogrsf_frmts/mongodb]

    # source files
    Dir["ogr/ogrsf_frmts/mongodb/ogrmongodb*.c*"].each do |src|
      args.concat %W[#{src}]
    end

    # plugin dylib
    dylib_name = "ogr_MongoDB.dylib"
    args.concat %W[
      -std=c++11
      -dynamiclib
      -install_name #{opt_lib}/#{gdal_plugins_subdirectory}/#{dylib_name}
      -current_version #{version}
      -compatibility_version #{gdal_majmin_ver}.0
      -o #{gdal_plugins}/#{dylib_name}
      -undefined dynamic_lookup
    ]

    # Add the Mongo lib
    args.concat %W[-L#{Formula["mongo-cxx-driver-legacy"].opt_lib} -lmongoclient]

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
    system "#{gdal_opt_bin}/ogrinfo", "--format", "MongoDB"
  end
end

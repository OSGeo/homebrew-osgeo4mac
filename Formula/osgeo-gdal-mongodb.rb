class OsgeoGdalMongodb < Formula
  desc "GDAL/OGR 2.x plugin for MongoDB driver"
  homepage "http://www.gdal.org/drv_mongodb.html"
  url "https://github.com/OSGeo/gdal/releases/download/v3.0.4/gdal-3.0.4.tar.gz"
  sha256 "fc15d2b9107b250305a1e0bd8421dd9ec1ba7ac73421e4509267052995af5e83"

  # revision 1

  head "https://github.com/OSGeo/gdal.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "9b81af29f823aff2629a3d53689b506645d9e7c6071bab98e8aff526cb727c63" => :mojave
    sha256 "9b81af29f823aff2629a3d53689b506645d9e7c6071bab98e8aff526cb727c63" => :high_sierra
    sha256 "935707dd54a940511a607a2ee37157f20695a42a6de1dbbcaefdf13d05cc8157" => :sierra
  end

  depends_on "boost"
  depends_on "libtiff"
  depends_on "osgeo-libgeotiff"
  depends_on "osgeo-gdal"
  depends_on "osgeo-mongo-cxx-driver-legacy"

  def gdal_majmin_ver
    gdal_ver_list = Formula["osgeo-gdal"].version.to_s.split(".")
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

    args << "--with-mongocxx=#{Formula["osgeo-mongo-cxx-driver-legacy"].opt_prefix}"

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
    args.concat %W[-L#{Formula["osgeo-mongo-cxx-driver-legacy"].opt_lib} -lmongoclient]

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
    system "#{gdal_opt_bin}/ogrinfo", "--format", "MongoDB"
  end
end

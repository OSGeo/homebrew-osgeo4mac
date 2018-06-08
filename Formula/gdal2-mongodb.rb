class Gdal2Mongodb < Formula
  desc "GDAL/OGR 2.x plugin for MongoDB driver"
  homepage "http://www.gdal.org/drv_mongodb.html"
  url "http://download.osgeo.org/gdal/2.3.0/gdal-2.3.0.tar.gz"
  sha256 "2944bbfee009bf1ca092716e4fd547cb4ae2a1e8816186236110c22f11c7e1e9"

   bottle do
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
      j2lura jasper jp2mrsid jpeg jpeg12 kakadu kea
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
    ENV.deparallelize

    # Patch configuration scripts to look for dylib, not .so
#    inreplace "configure.ac", "libmongoclient.so", "libmongoclient.dylib"
#    inreplace "configure", "libmongoclient.so", "libmongoclient.dylib"

    # configure GDAL/OGR with minimal drivers
    system "./configure", *configure_args

    #raise

    # cxx flags
    args = %W[-DLINUX -DUNIX -Iport -Igcore -Iogr
              -Iogr/ogrsf_frmts -Iogr/ogrsf_frmts/generic
              -Iogr/ogrsf_frmts/mongodb]

    # source files
    Dir["ogr/ogrsf_frmts/mongodb/ogrmongodb*.c*"].each do |src|
      args.concat %W[#{src}]
    end

    # plugin dylib
    dylib_name = "ogr_mongodb.dylib"
    args.concat %W[
      -std=c++11
      -dynamiclib
      -install_name #{opt_lib}/#{gdal_plugins_subdirectory}/#{dylib_name}
      -current_version #{version}
      -compatibility_version #{gdal_majmin_ver}.0
      -o #{gdal_plugins}/#{dylib_name}
      -undefined dynamic_lookup
    ]

    # build and install shared plugin
    system ENV.cxx, *args

    dylib = lib/gdal_plugins_subdirectory/dylib_name
#    dylib.ensure_writable do
      # manually add the libjvm.dylib rpath directory entry to the plugin
#      MachO::Tools.add_rpath(dylib.to_s, "#{Formula['mongo-c-driver'].opt_lib}", :strict => false)
#    end

#    libexec.install resource("jackcess-jar")
#    resource("logging-jars").stage do
#      libexec.install Dir["lib/commons*.jar"]
#    end
  end

  def caveats; <<~EOS
      This formula provides a plugin that allows GDAL or OGR to access geospatial
      data stored in its format. In order to use the shared plugin, you may need
      to set the following enviroment variable:

        export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins

      To have a functional MDB driver, install supporting .jar files in:
        /Library/Java/Extensions/
      from:
        #{opt_libexec}/*.jar

      (However, this can affect other JAVA software)

      Optionally, set the following JAVA environment variable, per session:

        export CLASSPATH=#{Dir[libexec/"*.jar"].join(":")}

      See: http://www.gdal.org/ogr/drv_mdb.html

      !!!!!!!!! IMPORTANT !!!!!!!!!

      You may need to adjust your JAVA JRE or JDK install to allow JNI usage:

        see: https://oliverdowling.com.au/2015/10/09/oracles-jdk-8-on-mac-os-x-el-capitan/
    EOS
  end

  test do
    # cmd = Language::Java.java_home_cmd("1.8+")
    # ENV["JAVA_HOME"] = Utils.popen_read(cmd).chomp
    ENV["CLASSPATH"] = Dir[libexec/"*.jar"].join(":")
    # puts "JAVA_HOME=#{ENV["JAVA_HOME"]}"
    # puts "CLASSPATH=#{ENV["CLASSPATH"]}"
    ENV["GDAL_DRIVER_PATH"] = "#{HOMEBREW_PREFIX}/lib/gdalplugins"
    gdal_opt_bin = Formula["gdal2"].opt_bin
    system "#{gdal_opt_bin}/ogrinfo", "--format", "MDB"
    resource("test-mdb").stage testpath
    system "#{gdal_opt_bin}/ogrinfo", "-ro", testpath/"Atlantic.mdb".to_s
  end
end

class OsgeoGdalMdb < Formula
  desc "GDAL/OGR 3.x plugin for MDB driver"
  homepage "http://www.gdal.org/drv_mdb.html"
  url "https://download.osgeo.org/gdal/3.1.2/gdal-3.1.2.tar.xz"
  sha256 "767c8d0dfa20ba3283de05d23a1d1c03a7e805d0ce2936beaff0bb7d11450641"

  #revision 1
  
  head "https://github.com/OSGeo/gdal.git", :branch => "master"

  # bottle do
  #   never (runtime JAVA version may change too much, or be different from Travis CI)
  # end

  depends_on :java
  depends_on "osgeo-gdal"
  depends_on "libtiff"
  depends_on "osgeo-libgeotiff"

  # various deps needed for configuring
  depends_on "json-c"

  resource "jackcess-jar" do
    url "https://downloads.sf.net/project/jackcess/jackcess/1.2.14.3/jackcess-1.2.14.3.jar"
    sha256 "a6fab0c4b5daf23dcf7fd309ee4ffc6df12ff982510c094e45442adf88712787"
  end

  resource "logging-jars" do
    # lib/commons*.jar
    url "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/mdb-sqlite/mdb-sqlite-1.0.2.tar.bz2"
    sha256 "43a584903f4c820b97104758a0d8f15731c70cee5d3d88d96669b1d91e902520"
  end

  resource "test-mdb" do
    url "https://osgeo4mac.s3.amazonaws.com/src/NJ-Streets_Atlantic.zip"
    sha256 "811ea90c55be918d8c3a2a5c75105e224c7a37fafb7f6154f67ec8eb9d8b86ef"
  end

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

      # various deps needed for configuring
      "--with-libjson-c=#{Formula["json-c"].opt_prefix}",

      # force correction of dylib setup, even though we are not building framework here
      "--with-macosx-framework",
    ]

    cmd = Language::Java.java_home_cmd("1.8")
    ENV["JAVA_HOME"] = Utils.popen_read(cmd).chomp
    args << "--with-java=yes"
    args << "--with-jvm-lib=#{ENV["JAVA_HOME"]}/jre/lib/server"
    # args << "--with-jvm-lib=dlopen" # doesn't seem to work on macOS
    # The rpath is only embedded for Oracle Java (non-framework) installs,
    # though it does not work here as we are just compiling a plugin directly
    args << "--with-jvm-lib-add-rpath=yes"
    args << "--with-mdb=yes"

    # nix all other configure tests, i.e. minimal base gdal build
    without_pkgs = %w[
      armadillo bsb cfitsio cryptopp curl dds dods-root
      ecw epsilon expat fgdb fme freexl
      geos gif gnm grass grib gta
      hdf4 hdf5 idb ingres
      j2lura jasper jp2mrsid jpeg jpeg12 kakadu kea
      libgrass libkml liblzma libz
      mongocxx mrf mrsid_lidar mrsid msg mysql netcdf
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
              -Iogr/ogrsf_frmts/mdb -I#{ENV["JAVA_HOME"]}/include/darwin
              -I#{ENV["JAVA_HOME"]}/include]

    # source files
    Dir["ogr/ogrsf_frmts/mdb/ogrmdb*.c*"].each do |src|
      args.concat %W[#{src}]
    end

    # plugin dylib
    dylib_name = "ogr_MDB.dylib"
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
    args.concat %W[-L#{ENV["JAVA_HOME"]}/jre/lib/server -ljvm]

    # build and install shared plugin
    system ENV.cxx, *args

    dylib = lib/gdal_plugins_subdirectory/dylib_name
    dylib.ensure_writable do
      # manually add the libjvm.dylib rpath directory entry to the plugin
      MachO::Tools.add_rpath(dylib.to_s, "#{ENV["JAVA_HOME"]}/jre/lib/server", :strict => false)
    end

    libexec.install resource("jackcess-jar")
    resource("logging-jars").stage do
      libexec.install Dir["lib/commons*.jar"]
    end
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
    gdal_opt_bin = Formula["odgeo-gdal"].opt_bin
    system "#{gdal_opt_bin}/ogrinfo", "--format", "MDB"
    resource("test-mdb").stage testpath
    system "#{gdal_opt_bin}/ogrinfo", "-ro", testpath/"Atlantic.mdb".to_s
  end
end

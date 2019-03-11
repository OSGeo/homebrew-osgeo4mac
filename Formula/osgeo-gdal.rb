class OsgeoGdal < Formula
  desc "GDAL: Geospatial Data Abstraction Library"
  homepage "https://www.gdal.org/"
  url "https://github.com/OSGeo/gdal/archive/v2.4.0.tar.gz"
  sha256 "625f84721e09151626274922c0ee1b0eec0537e9735c65bc892ba96541a1bd14"

  # revision 1

  head do
    url "https://github.com/OSGeo/gdal.git", :branch => "master"
    depends_on "doxygen" => :build
  end

  keg_only "older version of gdal is in main tap and installs similar components"

  option "with-postgresql10", "Build with PostgreSQL 10 client"

  depends_on "pkg-config"
  depends_on "libiconv"
  depends_on "expat"
  depends_on "zlib"
  depends_on "qhull"
  depends_on "curl"
  depends_on "libpng"
  depends_on "freexl"
  depends_on "geos"
  depends_on "jpeg"
  depends_on "json-c"
  depends_on "giflib"
  depends_on "libgeotiff"
  depends_on "libpq"
  depends_on "sqlite"
  depends_on "pcre"
  depends_on "libspatialite"
  depends_on "libtiff"
  depends_on "proj"
  depends_on "numpy"
  # depends_on "libkml-dev"
  depends_on "armadillo"
  depends_on "sfcgal"
  depends_on "netcdf"
  depends_on "hdf4"
  depends_on "cfitsio"
  depends_on "epsilon"
  depends_on "hdf5"
  depends_on "jasper"
  depends_on "libdap"
  depends_on "libxml2"
  depends_on "openjpeg"
  depends_on "zstd"
  depends_on "webp"
  depends_on "unixodbc"
  depends_on "xerces-c"
  depends_on "xz"
  depends_on :java => ["1.8", :build]
  depends_on "ant"
  depends_on "swig"
  depends_on "mdbtools"
  depends_on "libzip"
  # depends_on "charls" # Cask

  if build.with?("postgresql10")
    depends_on "postgresql@10"
  else
    depends_on "postgresql"
  end

  def configure_args
    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--with-libtool",
      "--with-bsb",
      "--with-grib",
      "--with-pam",
      # "--with-cpp14",
      # "--with-pic",
      # "--with-aix-soname",
      # "--with-gnu-ld",
      # "--with-sysroot",
      # "--without-libtool",
      # "--without-ld-shared",
      # "--with-unix-stdio-64",
      # "--with-sse",
      # "--with-ssse3",,
      # "--with-avx",
      # "--with-hide-internal-symbols",
      # "--with-rename-internal-libtiff-symbols",
      # "--with-rename-internal-libgeotiff-symbols",
      # "--with-rename-internal-shapelib-symbols",
      "--with-local=#{prefix}",
      "--with-threads=yes",
      "--with-libz=#{Formula["libzip"].opt_prefix}",
      # "--with-gnu-ld",
      "--with-libiconv-prefix=#{Formula["libiconv"].opt_prefix}",
      # "--without-libiconv-prefix",
      "--with-proj=#{Formula["proj"].opt_prefix}",
      "--with-liblzma=yes",
      "--with-zstd=#{Formula["zstd"].opt_prefix}",
      "--with-pg=#{Formula["postgresql"].opt_prefix}/bin/pg_config",
      "--with-grass=no",
      "--with-libgrass=no",
      "--with-cfitsio=#{Formula["cfitsio"].opt_prefix}",
      "--with-pcraster=internal",
      "--with-png=#{Formula["libpng"].opt_prefix}",
      # "--with-dds",
      "--with-gta=no",
      "--with-pcidsk=internal",
      "--with-libtiff=#{Formula["libtiff"].opt_prefix}",
      "--with-geotiff=#{Formula["libgeotiff"].opt_prefix}",
      "--with-jpeg=#{Formula["jpeg"].opt_prefix}",
      # "--with-charls=yes",
      "--without-jpeg12",
      "--with-gif=#{Formula["giflib"].opt_prefix}",
      "--with-ogdi=no",
      "--with-fme=no",
      "--with-sosi=no",
      "--with-mongocxx=no",
      # "--with-boost-lib-path",
      "--with-mongocxxv3=no",
      "--with-hdf4=#{Formula["hdf4"].opt_prefix}",
      "--with-hdf5=#{Formula["hdf5"].opt_prefix}",
      # "--with-kea",
      "--with-netcdf=#{Formula["netcdf"].opt_prefix}",
      # "--with-jasper=#{Formula["jasper"].opt_prefix}"
      "--with-openjpeg=#{Formula["openjpeg"].opt_prefix}",
      "--with-fgdb=no",
      "--with-ecw=no",
      "--with-kakadu=no",
      "--with-mrsid=no",
      "--with-jp2mrsid=no",
      "--with-mrsid_lidar=no",
      # "--with-j2lura",
      "--with-msg=no",
      "--with-oci=no",
      # "--with-oci-include",
      # "--with-oci-lib",
      "--with-gnm",
      "--with-mysql=no",
      "--with-ingres=no",
      "--with-xerces=#{Formula["xerces-c"].opt_prefix}",
      "--with-xerces-inc=#{Formula["xerces-c"].opt_include}",
      "--with-xerces-lib=#{Formula["xerces-c"].opt_lib}",
      "--with-expat=#{Formula["expat"].opt_prefix}",
      "--with-expat-inc=#{Formula["expat"].opt_include}",
      "--with-expat-lib=#{Formula["expat"].opt_lib}",
      # "--with-libkml=#{Formula["libkml-dev"].opt_prefix}",
      # "--with-libkml-inc=#{Formula["libkml-dev"].opt_include}",
      # "--with-libkml-lib=#{Formula["libkml-dev"].opt_lib}",
      "--with-odbc=#{Formula["unixodbc"].opt_prefix}",
      "--with-dods-root=/usr/local",
      "--with-curl=#{Formula["curl"].opt_bin}/curl-config",
      "--with-xml2=#{Formula["libxml2"].opt_bin}/xml2-config",
      "--with-spatialite=#{Formula["libspatialite"].opt_prefix}",
      # "--with-spatialite-soname",
      "--with-sqlite3=#{Formula["sqlite"].opt_prefix}",
      # "--with-rasterlite2",
      "--with-pcre",
      # "--with-teigha",
      # "--with-teigha-plt",
      "--with-idb=no",
      "--with-sde=no",
      # "--with-sde-version",
      "--with-epsilon=#{Formula["epsilon"].opt_prefix}",
      "--with-webp=#{Formula["webp"].opt_prefix}",
      "--with-geos=#{Formula["geos"].opt_prefix}/bin/geos-config",
      "--with-sfcgal=#{Formula["sfcgal"].opt_bin}/sfcgal-config",
      "--with-qhull=internal",
      "--with-opencl",
      # "--with-opencl-include",
      # "--with-opencl-lib",
      "--with-freexl=#{Formula["freexl"].opt_prefix}",
      "--with-libjson-c=#{Formula["json-c"].opt_prefix}",
      # "--without-pam",
      "--with-poppler=no",
      "--with-podofo=no",
      # "--with-podofo-lib",
      # "--with-podofo-extra-lib-for-test",
      "--with-pdfium=no",
      # "--with-pdfium-lib",
      # "--with-pdfium-extra-lib-for-test",
      # "--with-gdal-ver",
      "--with-macosx-framework",
      "--with-perl=no",
      "--with-python=no",
      "--with-java=yes",
      # "--with-hdfs",
      "--with-mdb",
      # "--with-jvm-lib",
      # "--with-jvm-lib-add-rpath",
      # "--with-rasdaman=no",
      "--with-armadillo=#{Formula["armadillo"].opt_prefix}",
      "--with-cryptopp=#{Formula["cryptopp"].opt_prefix}",
      "--with-crypto=#{Formula["openssl"].opt_prefix}",
      "--without-lerc",
      # "--with-null",
      # "--without-php",
      # "--without-dwgdirect",
      # "--without-ruby",
    ]
    args
  end

  def plugins_subdirectory
    gdal_ver_list = version.to_s.split(".")
    "gdalplugins/#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def install
    # Temporary fix for Xcode/CLT 9.0.x issue of missing header files
    # See: https://github.com/OSGeo/homebrew-osgeo4mac/issues/276
    # Work around "error: no member named 'signbit' in the global namespace"
    if DevelopmentTools.clang_build_version >= 900
      ENV.delete "SDKROOT"
      ENV.delete "HOMEBREW_SDKROOT"
    end

    # Linking flags for SQLite are not added at a critical moment when the GDAL
    # library is being assembled. This causes the build to fail due to missing
    # symbols. Also, ensure Homebrew SQLite is used so that Spatialite is
    # functional
    # Fortunately, this can be remedied using LDFLAGS
    sqlite = Formula["sqlite"]
    ENV.append "LDFLAGS", "-L#{sqlite.opt_lib} -lsqlite3"
    ENV.append "CFLAGS", "-I#{sqlite.opt_include}"

    # Reset ARCHFLAGS to match how we build
    ENV["ARCHFLAGS"] = "-arch #{MacOS.preferred_arch}"

    chdir "gdal" do
      # GDAL looks for the renamed hdf4 library, which is an artifact of old builds, so we need to repoint it
      inreplace "configure", "-ldf", "-lhdf"

      # Fix hardcoded mandir: http://trac.osgeo.org/gdal/ticket/5092
      inreplace "configure", %r[^mandir='\$\{prefix\}/man'$], ""

      # These libs are statically linked in libkml-dev and libkml formula
      inreplace "configure", " -lminizip -luriparser", ""

      # All PDF driver functionality moved to gdal2-pdf plugin,
      # so nix default internal-built PDF w+ driver, which keeps plugin from loading.
      # Just using --enable-pdf-plugin isn't enough (we don't want the plugin built here)
      inreplace "GDALmake.opt.in", "PDF_PLUGIN),yes", "PDF_PLUGIN),no"

      system "./configure", *args
      system "make"
      system "make", "install"

      # Add GNM headers for gdal2-python swig wrapping
      include.install Dir["gnm/**/*.h"]

      cd "swig/java" do
        inreplace "java.opt", "linux", "darwin"
        inreplace "java.opt", "#JAVA_HOME = /usr/lib/jvm/java-6-openjdk/", "JAVA_HOME=#{ENV["JAVA_HOME"]}"
        system "make"
        system "make", "install"

        # Install the jar that complements the native JNI bindings
        lib.install "gdal.jar"
      end

      system "make", "man" if build.head?
      # Force man installation dir: https://trac.osgeo.org/gdal/ticket/5092
      system "make", "install-man", "INST_MAN=#{man}"
      # Clean up any stray doxygen files
      system "make", "install-man"
      # Clean up any stray doxygen files.
      Dir.glob("#{bin}/*.dox") { |p| rm p }
    end
  end

  def post_install
    # Create versioned plugins path for other formulae
    (HOMEBREW_PREFIX/"lib/#{plugins_subdirectory}").mkpath
  end

  def caveats
    s = <<~EOS
      Plugins for this version of GDAL/OGR, generated by other formulae, should
      be symlinked to the following directory:

        #{HOMEBREW_PREFIX}/lib/#{plugins_subdirectory}

      You may need to set the following enviroment variable:

        export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins

      PYTHON BINDINGS are now built in a separate formula: gdal2-python
    EOS
    s
  end

  test do
    # basic tests to see if third-party dylibs are loading OK
    system "#{bin}/gdalinfo", "--formats"
    system "#{bin}/ogrinfo", "--formats"
  end
end

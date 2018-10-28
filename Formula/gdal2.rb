class Gdal2 < Formula
  desc "GDAL: Geospatial Data Abstraction Library"
  homepage "https://www.gdal.org/"
  url "https://github.com/OSGeo/gdal/archive/v2.3.2.tar.gz"
  sha256 "e0f751bff9ba6fb541065acbe7a76007be76a3c6309240faf4e6440f6ff1702a"

  # revision 1

  head do
    url "https://github.com/OSGeo/gdal.git", :branch => "master"
    depends_on "doxygen" => :build
  end

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 3
    sha256 "f67eaadc28e5feb7502ed693d03077f6efd8fb810ec483b1e439b4d0c8aba90e" => :high_sierra
    sha256 "f67eaadc28e5feb7502ed693d03077f6efd8fb810ec483b1e439b4d0c8aba90e" => :sierra
  end

  # Needed to build the swig bindings, until https://github.com/OSGeo/gdal/pull/713 is merged.
  # patch :DATA

  keg_only "older version of gdal is in main tap and installs similar components"

  option "with-complete", "Use additional Homebrew libraries to provide more drivers."
  option "with-qhull", "Build with internal qhull libary support"
  option "with-opencl", "Build with OpenCL acceleration."
  option "with-armadillo", "Build with Armadillo accelerated TPS transforms."
  option "with-unsupported", "Allow configure to drag in any library it can find. Invoke this at your own risk."
  option "with-mdb", "Build with Access MDB driver (requires Java 1.6+ JDK/JRE, from Apple or Oracle)."
  option "without-gnm", "Build without Geographic Network Model support"
  option "with-libkml", "Build with Google's libkml driver (requires libkml-dev >= 1.3)"
  option "with-swig-java", "Build the swig java bindings"
  option "with-sfcgal", "Build with CGAL C++ wrapper support"
  option "with-ogdi", "Build with OGDI support (consider gdal2-ogdi instead)"

  deprecated_option "enable-opencl" => "with-opencl"
  deprecated_option "enable-armadillo" => "with-armadillo"
  deprecated_option "enable-unsupported" => "with-unsupported"
  deprecated_option "complete" => "with-complete"
  deprecated_option "with-java" => "with-swig-java"

  depends_on "pkg-config"
  depends_on "zlib"
  depends_on "qhull"
  depends_on "curl"
  # depends_on "charls" # Cask
  depends_on "libpng"
  depends_on "freexl"
  depends_on "geos"
  depends_on "jpeg"
  depends_on "json-c"
  depends_on "giflib"
  depends_on "libgeotiff"
  depends_on "libpq"
  depends_on "sqlite" # To ensure compatibility with SpatiaLite.
  depends_on "pcre" # for REGEXP operator in SQLite/Spatialite driver
  depends_on "libspatialite"
  depends_on "libtiff"
  depends_on "proj"
  depends_on "numpy"
  depends_on "libkml-dev" if build.with? "libkml"
  depends_on "postgresql" => :optional
  depends_on "mysql" => :optional
  depends_on "ogdi" => :optional
  depends_on "armadillo" => :optional
  depends_on "sfcgal" => :optional

  if build.with? "swig-java"
    depends_on :java => ["1.8", :build]
    depends_on "ant" => :build
    depends_on "swig" => :build
  end

  if build.with? "complete"
    # Raster libraries
    depends_on "netcdf" # Also brings in HDF5
    depends_on "osgeo/osgeo4mac/hdf4"
    depends_on "cfitsio"
    depends_on "epsilon"
    depends_on "hdf5"
    depends_on "jasper"
    depends_on "libdap"
    depends_on "libxml2"
    depends_on "openjpeg"
    depends_on "zstd"
    depends_on "webp"
    # Vector libraries
    depends_on "unixodbc" # OS X version is not complete enough
    depends_on "xerces-c"
    # Other libraries
    depends_on "xz" # get liblzma compression algorithm library from XZutils
  end

  def configure_args
    args = [
      # Base configuration.
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--with-libtool",
      "--with-local=#{prefix}",
      "--with-threads",
      # GDAL native backends
      "--with-bsb",
      "--with-grib",
      "--with-pam",
      "--with-pcidsk=internal",
      "--with-pcraster=internal",
      # Other
      "--with-libiconv-prefix=#{Formula["libiconv"].opt_prefix}",
      "--with-libz=#{Formula["libzip"].opt_prefix}",
      "--with-curl=#{Formula["curl"].opt_bin}/curl-config",
      "--with-freexl=#{Formula["freexl"].opt_prefix}",
      "--with-geos=#{Formula["geos"].opt_prefix}/bin/geos-config",
      "--with-geotiff=internal",
      "--with-libtiff=internal",
      "--with-gif=#{Formula["giflib"].opt_prefix}",
      "--with-libjson-c=#{Formula["json-c"].opt_prefix}",
      "--with-png=#{Formula["libpng"].opt_prefix}",
      "--with-spatialite=#{Formula["libspatialite"].opt_prefix}",
      "--with-expat=#{Formula["expat"].opt_prefix}",
      "--with-sqlite3=#{Formula["sqlite"].opt_prefix}",
      "--with-zstd=#{Formula["zstd"].opt_prefix}",
      "--with-xml2=#{Formula["libxml2"].opt_bin}/xml2-config",
      "--with-webp=#{Formula["webp"].opt_prefix}",
      "--with-netcdf=#{Formula["netcdf"].opt_prefix}",
      "--with-hdf5=#{Formula["hdf5"].opt_prefix}",
      "--with-jasper=#{Formula["jasper"].opt_prefix}",
      "--with-openjpeg=#{Formula["openjpeg"].opt_prefix}",
      "--with-cfitsio=#{Formula["cfitsio"].opt_prefix}",
      "--with-proj=#{Formula["proj"].opt_prefix}",
      "--with-jpeg=#{Formula["jpeg"].opt_prefix}",
      # GRASS backend explicitly disabled.  Creates a chicken-and-egg problem.
      # Should be installed separately after GRASS installation using the
      # official GDAL GRASS plugin.
      "--without-grass",
      "--without-libgrass",
      # Python is installed manually to ensure everything is properly sandboxed
      "--without-python",
      "--without-perl",
      "--without-php",
      "--without-fme",
      "--without-hdf4",
      "--without-ecw",
      "--without-kakadu",
      "--without-mrsid",
      "--without-jp2mrsid",
      "--without-msg",
      "--without-oci",
      "--without-ingres",
      "--without-odbc",
      "--without-idb",
      "--without-sde",
      "--without-jpeg12", # Needs specially configured JPEG and TIFF libraries
      # "--with-static-proj4",
      # "--with-charls=yes",
    ]
    args
  end

  def plugins_subdirectory
    gdal_ver_list = version.to_s.split(".")
    "gdalplugins/#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def install
    args = configure_args

    # Optional Homebrew packages supporting additional formats.
    supported_backends = %w[
      liblzma
      hdf5
      cfitsio
      netcdf
      jasper
      xerces
      odbc
      dods-root
      epsilon
      zstd
      webp
      openjpeg
      ogdi
    ]

    # The following libraries are either proprietary, not available for public
    # download or have no stable version in the Homebrew core that is
    # compatible with GDAL. Interested users will have to install such software
    # manually and most likely have to tweak the install routine.
    unsupported_backends = %w[
      hdf4
      dwgdirect
      podofo
      gta
      fme
      fgdb
      ecw
      kakadu
      mrsid
      jp2mrsid
      mrsid_lidar
      msg
      oci
      ingres
      idb
      sde
      rasdaman
      sosi
    ]
    args.concat(unsupported_backends.map { |b| "--without-" + b }) if build.without? "unsupported"

    if build.with? "complete"
      supported_backends.delete "liblzma"
      args << "--with-liblzma=yes"
      args.concat(supported_backends.map { |b| "--with-" + b + "=" + HOMEBREW_PREFIX })
    elsif build.without? "unsupported"
      args.concat(supported_backends.map { |b| "--without-" + b })
    end

    if build.without? "unsupported"
      args.concat unsupported_backends.map { |b| "--without-" + b }
    end

    # Database support
    args << (build.with?("postgresql") ? "--with-pg=#{HOMEBREW_PREFIX}/bin/pg_config" : "--without-pg")
    args << (build.with?("mysql") ? "--with-mysql=#{HOMEBREW_PREFIX}/bin/mysql_config" : "--without-mysql")

    args << "--with-libkml=#{Formula["libkml-dev"].opt_prefix}" if build.with? "libkml"

    args << "--with-qhull=#{build.with?("qhull") ? "internal" : "no"}"

    args << "--without-gnm" if build.without? "gnm"

    # All PDF driver functionality moved to gdal2-pdf plugin
    # Older pdfium (for gdal driver) is still built against libstdc++ and
    # causes the base build to be built like that as well.
    # See: https://github.com/rouault/pdfium
    args << "--with-pdfium=no"
    args << "--with-poppler=no"
    args << "--with-podofo=no"

    args << "--with-ogdi=#{build.with?("ogdi") ? Formula["ogdi"].opt_prefix.to_s : "no"}"

    args << "--with-sfcgal=#{build.with?("sfcgal") ? HOMEBREW_PREFIX/"bin/sfcgal-config" : "no"}"

    args << (build.with?("opencl") ? "--with-opencl" : "--without-opencl")
    args << (build.with?("armadillo") ? "--with-armadillo=#{Formula["armadillo"].opt_prefix}" : "--with-armadillo=no")

    # Linking flags for SQLite are not added at a critical moment when the GDAL
    # library is being assembled. This causes the build to fail due to missing
    # symbols. Also, ensure Homebrew SQLite is used so that Spatialite is
    # functional
    # Fortunately, this can be remedied using LDFLAGS
    sqlite = Formula["sqlite"]
    ENV.append "LDFLAGS", "-L#{sqlite.opt_lib} -lsqlite3"
    ENV.append "CFLAGS", "-I#{sqlite.opt_include}"

    ENV.append "LDFLAGS", "-L#{Formula["ogdi"].opt_lib}/ogdi" if build.with? "ogdi"

    # Reset ARCHFLAGS to match how we build
    ENV["ARCHFLAGS"] = "-arch #{MacOS.preferred_arch}"

    # Temporary fix for Xcode/CLT 9.0.x issue of missing header files
    # See: https://github.com/OSGeo/homebrew-osgeo4mac/issues/276
    ENV.delete("SDKROOT") if DevelopmentTools.clang_build_version >= 900

    chdir "gdal" do
      # GDAL looks for the renamed hdf4 library, which is an artifact of old builds, so we need to repoint it
      inreplace "configure", "-ldf", "-lhdf" if build.with? "complete"

      # Fix hardcoded mandir: http://trac.osgeo.org/gdal/ticket/5092
      inreplace "configure", %r[^mandir='\$\{prefix\}/man'$], ""

      # These libs are statically linked in libkml-dev and libkml formula
      inreplace "configure", " -lminizip -luriparser", "" if build.with? "libkml"

      # All PDF driver functionality moved to gdal2-pdf plugin,
      # so nix default internal-built PDF w+ driver, which keeps plugin from loading.
      # Just using --enable-pdf-plugin isn't enough (we don't want the plugin built here)
      inreplace "GDALmake.opt.in", "PDF_PLUGIN),yes", "PDF_PLUGIN),no"

      system "./configure", *args
      system "make"
      system "make", "install"

      # Add GNM headers for gdal2-python swig wrapping
      include.install Dir["gnm/**/*.h"] if build.with? "gnm"

      if build.with? "swig-java"
        cd "swig/java" do
          inreplace "java.opt", "linux", "darwin"
          inreplace "java.opt", "#JAVA_HOME = /usr/lib/jvm/java-6-openjdk/", "JAVA_HOME=#{ENV["JAVA_HOME"]}"
          system "make"
          system "make", "install"

          # Install the jar that complements the native JNI bindings
          lib.install "gdal.jar"
        end
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

# __END__
# diff --git a/gdal/swig/java/GNUmakefile b/gdal/swig/java/GNUmakefile
# index 1313bd9974f..5e4e6844d47 100644
# --- a/swig/java/GNUmakefile
# +++ b/swig/java/GNUmakefile
# @@ -56,13 +56,13 @@ generate: makedir ${WRAPPERS}
#  build: generate ${JAVA_OBJECTS} ${JAVA_MODULES}
#  ifeq ($(HAVE_LIBTOOL),yes)
#
# -	if [ -f ".libs/libgdaljni.so" ] ; then \
# +	if [ -f ".libs/libgdalalljni.so" ] ; then \
#  		cp .libs/*.so . ; \
#  	fi
#
#  	echo "$(wildcard .libs/*.dylib)"
#
# -	if [ -f ".libs/libgdaljni.dylib" ] ; then \
# +	if [ -f ".libs/libgdalalljni.dylib" ] ; then \
#  		cp .libs/*.dylib . ; \
#  	fi

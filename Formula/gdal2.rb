class Gdal2 < Formula
  desc "GDAL: Geospatial Data Abstraction Library"
  homepage "http://www.gdal.org/"
  url "http://download.osgeo.org/gdal/2.3.1/gdal-2.3.1.tar.gz"
  sha256 "034456405d3c43d42643ba68685e4a76da71f040f139d7c57b9a12fbf1378223"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 1
    sha256 "68b33081ef6500b71b30fd807e4a448e69da63b8e44f7c7391b47e0150d2c3ff" => :high_sierra
    sha256 "68b33081ef6500b71b30fd807e4a448e69da63b8e44f7c7391b47e0150d2c3ff" => :sierra
  end

  head do
    url "https://svn.osgeo.org/gdal/trunk/gdal"
    depends_on "doxygen" => :build
  end

  # Needed to build the swig bindings, until https://github.com/OSGeo/gdal/pull/713 is merged.
  patch :DATA

  def plugins_subdirectory
    gdal_ver_list = version.to_s.split(".")
    "gdalplugins/#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

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

  depends_on "libpng"
  depends_on "jpeg"
  depends_on "giflib"
  depends_on "libtiff"
  depends_on "libgeotiff"
  depends_on "proj"
  depends_on "geos"
  depends_on "json-c"

  depends_on "sqlite" # To ensure compatibility with SpatiaLite.
  depends_on "pcre" # for REGEXP operator in SQLite/Spatialite driver
  depends_on "freexl"
  depends_on "libspatialite"

  depends_on "postgresql" => :optional
  depends_on "mysql" => :optional

  depends_on "ogdi" => :optional

  depends_on "armadillo" => :optional

  depends_on "libkml-dev" if build.with? "libkml"

  depends_on :java if build.with? "swig-java"

  if build.with? "complete"
    # Raster libraries
    depends_on "netcdf" # Also brings in HDF5
    depends_on "hdf4"
    depends_on "jasper"
    depends_on "webp"
    depends_on "cfitsio"
    depends_on "epsilon"
    depends_on "libdap"
    depends_on "libxml2"
    depends_on "openjpeg"

    # Vector libraries
    depends_on "unixodbc" # OS X version is not complete enough
    depends_on "xerces-c"

    # Other libraries
    depends_on "xz" # get liblzma compression algorithm library from XZutils
  end

  if build.with? "swig-java"
    depends_on :java => ["1.8", :build]
    depends_on "ant" => :build
    depends_on "swig" => :build
  end

  depends_on "sfcgal" => :optional

  def configure_args
    args = [
      # Base configuration.
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--with-local=#{prefix}",
      "--with-threads",
      "--with-libtool",

      # GDAL native backends.
      "--with-pcraster=internal",
      "--with-pcidsk=internal",
      "--with-bsb",
      "--with-grib",
      "--with-pam",

      # Backends supported by OS X.
      "--with-libiconv-prefix=/usr",
      "--with-libz=/usr",
      "--with-png=#{Formula["libpng"].opt_prefix}",
      "--with-expat=/usr",
      "--with-curl=/usr/bin/curl-config",

      # Default Homebrew backends.
      "--with-jpeg=#{HOMEBREW_PREFIX}",
      "--without-jpeg12", # Needs specially configured JPEG and TIFF libraries.
      "--with-gif=#{HOMEBREW_PREFIX}",
      "--with-libtiff=#{HOMEBREW_PREFIX}",
      "--with-geotiff=#{HOMEBREW_PREFIX}",
      "--with-sqlite3=#{Formula["sqlite"].opt_prefix}",
      "--with-freexl=#{HOMEBREW_PREFIX}",
      "--with-spatialite=#{HOMEBREW_PREFIX}",
      "--with-geos=#{HOMEBREW_PREFIX}/bin/geos-config",
      "--with-static-proj4=#{HOMEBREW_PREFIX}",
      "--with-libjson-c=#{Formula["json-c"].opt_prefix}",
      "--with-xml2=#{Formula["libxml2"].opt_bin}/xml2-config",

      # GRASS backend explicitly disabled.  Creates a chicken-and-egg problem.
      # Should be installed separately after GRASS installation using the
      # official GDAL GRASS plugin.
      "--without-grass",
      "--without-libgrass",
    ]

    # Optional Homebrew packages supporting additional formats.
    supported_backends = %w[
      liblzma
      hdf4
      hdf5
      cfitsio
      netcdf
      jasper
      xerces
      odbc
      dods-root
      epsilon
      webp
      openjpeg
    ]
    if build.with? "complete"
      supported_backends.delete "liblzma"
      args << "--with-liblzma=yes"
      args.concat(supported_backends.map { |b| "--with-" + b + "=" + HOMEBREW_PREFIX })
    elsif build.without? "unsupported"
      args.concat(supported_backends.map { |b| "--without-" + b })
    end

    # The following libraries are either proprietary, not available for public
    # download or have no stable version in the Homebrew core that is
    # compatible with GDAL. Interested users will have to install such software
    # manually and most likely have to tweak the install routine.

    unsupported_backends = %w[
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

    # Database support.
    args << (build.with?("postgresql") ? "--with-pg=#{HOMEBREW_PREFIX}/bin/pg_config" : "--without-pg")
    args << (build.with?("mysql") ? "--with-mysql=#{HOMEBREW_PREFIX}/bin/mysql_config" : "--without-mysql")

    args << "--with-libkml=#{Formula["libkml-dev"].opt_prefix}" if build.with? "libkml"

    args << "--with-qhull=#{build.with?("qhull") ? "internal" : "no"}"

    args << "--without-gnm" if build.without? "gnm"

    # All PDF driver functionality moved to gdal2-pdf plugin
    # Older pdfium (for gdal driver) is still built against libstdc++ and
    #   causes the base build to be built like that as well.
    # See: https://github.com/rouault/pdfium
    args << "--with-pdfium=no"
    args << "--with-poppler=no"
    args << "--with-podofo=no"

    args << "--with-ogdi=#{build.with?("ogdi") ? Formula["ogdi"].opt_prefix.to_s : "no"}"

    args << "--with-sfcgal=#{build.with?("sfcgal") ? HOMEBREW_PREFIX/"bin/sfcgal-config" : "no"}"

    # Python is installed manually to ensure everything is properly sandboxed.
    # see
    args << "--without-python"

    # Scripting APIs that have not been re-worked to respect Homebrew prefixes.
    #
    # Currently disabled as they install willy-nilly into locations outside of
    # the Homebrew prefix.  Enable if you feel like it, but uninstallation may be
    # a manual affair.
    #
    # TODO: Fix installation of script bindings so they install into the
    # Homebrew prefix.
    args << "--without-perl"
    args << "--without-php"

    args << (build.with?("opencl") ? "--with-opencl" : "--without-opencl")
    args << (build.with?("armadillo") ? "--with-armadillo=#{Formula["armadillo"].opt_prefix}" : "--with-armadillo=no")

    args
  end

  def install
    # Linking flags for SQLite are not added at a critical moment when the GDAL
    # library is being assembled. This causes the build to fail due to missing
    # symbols. Also, ensure Homebrew SQLite is used so that Spatialite is
    # functional.
    #
    # Fortunately, this can be remedied using LDFLAGS.
    sqlite = Formula["sqlite"]
    ENV.append "LDFLAGS", "-L#{sqlite.opt_lib} -lsqlite3"
    ENV.append "CFLAGS", "-I#{sqlite.opt_include}"

    ENV.append "LDFLAGS", "-L#{Formula["ogdi"].opt_lib}/ogdi" if build.with? "ogdi"

    # GDAL looks for the renamed hdf4 library, which is an artifact of old builds, so we need to repoint it
    inreplace "configure", "-ldf", "-lhdf" if build.with? "complete"

    # Reset ARCHFLAGS to match how we build.
    ENV["ARCHFLAGS"] = "-arch #{MacOS.preferred_arch}"

    # Fix hardcoded mandir: http://trac.osgeo.org/gdal/ticket/5092
    inreplace "configure", %r[^mandir='\$\{prefix\}/man'$], ""

    # These libs are statically linked in libkml-dev and libkml formula
    inreplace "configure", " -lminizip -luriparser", "" if build.with? "libkml"

    # All PDF driver functionality moved to gdal2-pdf plugin,
    # so nix default internal-built PDF w+ driver, which keeps plugin from loading.
    # Just using --enable-pdf-plugin isn't enough (we don't want the plugin built here)
    inreplace "GDALmake.opt.in", "PDF_PLUGIN),yes", "PDF_PLUGIN),no"

    # Temporary fix for Xcode/CLT 9.0.x issue of missing header files
    # See: https://github.com/OSGeo/homebrew-osgeo4mac/issues/276
    ENV.delete("SDKROOT") if DevelopmentTools.clang_build_version >= 900

    system "./configure", *configure_args
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
    system "make", "install-man"
    # Clean up any stray doxygen files.
    Dir.glob("#{bin}/*.dox") { |p| rm p }
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
__END__
diff --git a/gdal/swig/java/GNUmakefile b/gdal/swig/java/GNUmakefile
index 1313bd9974f..5e4e6844d47 100644
--- a/swig/java/GNUmakefile
+++ b/swig/java/GNUmakefile
@@ -56,13 +56,13 @@ generate: makedir ${WRAPPERS}
 build: generate ${JAVA_OBJECTS} ${JAVA_MODULES}
 ifeq ($(HAVE_LIBTOOL),yes)

-	if [ -f ".libs/libgdaljni.so" ] ; then \
+	if [ -f ".libs/libgdalalljni.so" ] ; then \
 		cp .libs/*.so . ; \
 	fi

 	echo "$(wildcard .libs/*.dylib)"

-	if [ -f ".libs/libgdaljni.dylib" ] ; then \
+	if [ -f ".libs/libgdalalljni.dylib" ] ; then \
 		cp .libs/*.dylib . ; \
 	fi


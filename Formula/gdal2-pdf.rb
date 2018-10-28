class Gdal2Pdf < Formula
  desc "GDAL/OGR 2.x plugin for PDF driver"
  homepage "http://www.gdal.org/frmt_pdf.html"
  url "http://download.osgeo.org/gdal/2.3.2/gdal-2.3.2.tar.gz"
  sha256 "7808dd7ea7ee19700a133c82060ea614d4a72edbf299dfcb3713f5f79a909d64"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 1
    sha256 "2597ffc9899eb45360908c85ac8ff87ac4f38070f0279f1ba20d70b7c721bb82" => :high_sierra
    sha256 "2597ffc9899eb45360908c85ac8ff87ac4f38070f0279f1ba20d70b7c721bb82" => :sierra
  end

  option "without-poppler", "Build without additional Poppler support"
  option "with-pdfium", "Build without PDFium support (stdlib for C++ issues)"
  option "with-podofo", "Build with additional PoDoFo support"

  if build.with? "poppler"
    depends_on "pkg-config" => :build
    depends_on "cairo"
    depends_on "fontconfig"
    depends_on "freetype"
    depends_on "gettext"
    depends_on "glib"
    depends_on "gobject-introspection"
    depends_on "jpeg"
    depends_on "libpng"
    depends_on "libtiff"
    depends_on "libgeotiff"
    depends_on "openjpeg"
  end
  depends_on "pdfium-gdal2" if build.with? "pdfium"
  depends_on "podofo" => :optional
  depends_on "gdal2"

  # various deps needed for configuring
  depends_on "json-c"

  # upstream poppler 0.59.0 incompatibility
  resource "poppler" do
    url "https://poppler.freedesktop.org/poppler-0.57.0.tar.xz"
    sha256 "0ea37de71b7db78212ebc79df59f99b66409a29c2eac4d882dae9f2397fe44d8"
  end

  resource "poppler-data" do
    url "https://poppler.freedesktop.org/poppler-data-0.4.8.tar.gz"
    sha256 "1096a18161f263cccdc6d8a2eb5548c41ff8fcf9a3609243f1b6296abdf72872"
  end

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

      # various deps needed for configuring
      "--with-libjson-c=#{Formula["json-c"].opt_prefix}",

      # force correction of dylib setup, even though we are not building framework here
      "--with-macosx-framework",
      "--enable-pdf-plugin",
    ]

    # PDF-supporting backends for writing
    args << "--with-pdfium=" + (build.with?("pdfium") ? Formula["pdfium-gdal2"].opt_prefix : "no")
    # poppler is locally vendored
    args << "--with-poppler=" + (build.with?("poppler") ? "#{libexec}/poppler" : "no")
    args << "--with-podofo=" + (build.with?("podofo") ? Formula["podofo"].opt_prefix : "no")

    # nix all other configure tests, i.e. minimal base gdal build
    without_pkgs = %w[
      armadillo bsb cfitsio cryptopp curl dds dods-root
      ecw epsilon expat fgdb fme freexl
      geos gif gnm grass grib gta
      hdf4 hdf5 idb ingres
      j2lura jasper java jp2mrsid jpeg jpeg12 kakadu kea
      libgrass libkml liblzma libz
      mdb mongocxx mrf mrsid_lidar mrsid msg mysql netcdf
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
    if build.without?("pdfium") && build.without?("poppler") && build.without?("podofo")
      opoo "Need to have at least one PDF supporting library enabled for basic read support"
    end

    gdal_plugins = lib/gdal_plugins_subdirectory
    gdal_plugins.mkpath

    # ENV.cxx11
    needs :cxx11 if MacOS.version < :mavericks
    # ENV.libstdcxx
    # set ARCHFLAGS to match how we build
    ENV["ARCHFLAGS"] = "-arch #{MacOS.preferred_arch}"
    # ENV.append_to_cflags "-mmacosx-version-min=10.8"
    # ENV["CXXFLAGS"] = "-mmacosx-version-min=10.8"
    # ENV["MACOSX_DEPLOYMENT_TARGET"] = "10.8"

    if build.with? "poppler"
      # locally vendor dependency
      resource("poppler").stage do
        # Temp fix for supporting new OpenJPEG 2.x version, which is API/ABI compatible with OpenJPEG 2.2
        opj_ver_list = Formula["openjpeg"].version.to_s.split(".")
        opj_ver = "#{opj_ver_list[0]}.#{opj_ver_list[1]}"
        ENV["LIBOPENJPEG_CFLAGS"] = "-I#{Formula["openjpeg"].opt_include}/openjpeg-#{opj_ver}"

        inreplace "poppler.pc.in", "Cflags: -I${includedir}/poppler",
                  "Cflags: -I${includedir}/poppler -I${includedir}"

        system "./configure", "--disable-dependency-tracking",
               "--prefix=#{libexec}/poppler",
               "--enable-xpdf-headers",
               "--enable-poppler-glib",
               "--disable-gtk-test",
               "--enable-introspection=no",
               "--disable-poppler-qt4"
        system "make", "install"
        resource("poppler-data").stage do
          system "make", "install", "prefix=#{libexec}/poppler"
        end
      end
    end

    ENV.deparallelize

    inreplace "configure", "stdlib=libstdc", "stdlib=libc"
    inreplace "configure", "-std=c++0x", ""
    # inreplace "port/cpl_string.h", /#ifndef HAVE_CXX11([^#]+)#endif/, "\\1"

    # configure GDAL/OGR with minimal drivers
    system "./configure", *configure_args

    # raise

    # PDF driver needs memory driver object files
    cd "ogr/ogrsf_frmts/mem" do
      system "make"
    end

    cd "frmts/pdf" do
      gdal_opt = Formula["gdal2"].opt_prefix
      # force std libc++ and linkage to libgdal.dylib
      inreplace "GNUmakefile" do |s|
        s.gsub! "libstdc", "libc"
        s.sub! "$(CONFIG_LIBS)", "-L#{gdal_opt}/lib -lgdal"
      end

      system "make", "plugin"
      mv "gdal_PDF.dylib", "#{gdal_plugins}/"
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
    if build.without?("pdfium") && build.without?("poppler") && build.without?("podofo")
      # just native gdal write support
      assert_match "PDF -raster,vector- (w+): Geospatial PDF", out
    else
      assert_match "PDF -raster,vector- (rw+vs): Geospatial PDF", out
    end
  end
end

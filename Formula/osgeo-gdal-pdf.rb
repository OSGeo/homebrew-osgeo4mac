class OsgeoGdalPdf < Formula
  desc "GDAL/OGR 3.x plugin for PDF driver"
  homepage "http://www.gdal.org/frmt_pdf.html"
  url "https://download.osgeo.org/gdal/3.1.2/gdal-3.1.2.tar.xz"
  sha256 "767c8d0dfa20ba3283de05d23a1d1c03a7e805d0ce2936beaff0bb7d11450641"

  #revision 1
  
  head "https://github.com/OSGeo/gdal.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "3daada45817c48da90738d7b8052e2bd5fb25117e2c25c35bed2030f2b96517a" => :catalina
    sha256 "3daada45817c48da90738d7b8052e2bd5fb25117e2c25c35bed2030f2b96517a" => :mojave
    sha256 "3daada45817c48da90738d7b8052e2bd5fb25117e2c25c35bed2030f2b96517a" => :high_sierra
  end

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
  depends_on "osgeo-libgeotiff"
  depends_on "openjpeg"
  depends_on "podofo"
  # TODO: new code for GDAL >3.1 from: 
  # https://github.com/rouault/pdfium_build_gdal_3_1
  #depends_on "osgeo-pdfium"
  depends_on "osgeo-gdal"

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

      # various deps needed for configuring
      "--with-libjson-c=#{Formula["json-c"].opt_prefix}",

      # force correction of dylib setup, even though we are not building framework here
      "--with-macosx-framework",
      "--enable-pdf-plugin",
      "--without-libtool"
    ]

    # PDF-supporting backends for writing
    # args << "--with-pdfium=#{Formula["osgeo-pdfium"].opt_prefix}"

    # poppler is locally vendored
    args << "--with-poppler=#{libexec}/poppler"
    args << "--with-podofo=#{Formula["podofo"].opt_prefix}"

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
    gdal_plugins = lib/gdal_plugins_subdirectory
    gdal_plugins.mkpath

    # ENV.cxx11
    needs :cxx11 if MacOS.version < :mavericks
    # ENV.libstdcxx
    # set ARCHFLAGS to match how we build
    ENV["ARCHFLAGS"] = "-arch #{Hardware::CPU.arch}"
    # ENV.append_to_cflags "-mmacosx-version-min=10.8"
    # ENV["CXXFLAGS"] = "-mmacosx-version-min=10.8"
    # ENV["MACOSX_DEPLOYMENT_TARGET"] = "10.8"

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

    ENV.deparallelize

    inreplace "configure", "stdlib=libstdc", "stdlib=libc"
    inreplace "configure", "-std=c++0x", ""
    # inreplace "port/cpl_string.h", /#ifndef HAVE_CXX11([^#]+)#endif/, "\\1"

    # configure GDAL/OGR with minimal drivers
    system "./configure", *configure_args

    # PDF driver needs memory driver object files
    cd "ogr/ogrsf_frmts/mem" do
      system "make"
    end

    cd "frmts/pdf" do
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
    gdal_opt_bin = Formula["osgeo-gdal"].opt_bin
    out = shell_output("#{gdal_opt_bin}/gdalinfo --formats")
    assert_match "PDF -raster,vector- (rw+s): Geospatial PDF", out
  end
end

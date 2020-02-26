class OsgeoOssim < Formula
  desc "Geospatial libs and apps to process imagery, terrain, and vector data"
  homepage "https://trac.osgeo.org/ossim/"
  url "https://github.com/ossimlabs/ossim/archive/OrchidIsland-2.11.1.tar.gz"
  sha256 "2823d132c8da3cb57c030f72ab4c0fbf493eccac6b34c1ec7192741312a839eb"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "2f9e74bcc0f1cc41b39279d707c168a028f8bdaeff5d4c53091d420f6a70251b" => :catalina
    sha256 "2f9e74bcc0f1cc41b39279d707c168a028f8bdaeff5d4c53091d420f6a70251b" => :mojave
    sha256 "2f9e74bcc0f1cc41b39279d707c168a028f8bdaeff5d4c53091d420f6a70251b" => :high_sierra
  end

  revision 1

  head "https://github.com/ossimlabs/ossim.git", :branch => "master"

  option "with-curl-apps", "Build curl-dependent apps"
  option "with-pg10", "Build with PostgreSQL 10 client"

  depends_on "cmake" => :build
  depends_on "jpeg"
  depends_on "jsoncpp"
  depends_on "libtiff"
  depends_on "geos"
  depends_on "freetype"
  depends_on "zlib"
  depends_on "libpng"
  depends_on "opencv"
  depends_on "openjpeg"
  depends_on "doxygen"
  depends_on "minizip"
  depends_on "bzip2"
  depends_on "ffmpeg"
  depends_on "podofo"
  depends_on "qt"
  depends_on "jsoncpp"
  depends_on "potrace"
  depends_on "sqlite"
  depends_on "fftw"
  depends_on "expat"
  depends_on "curl"
  depends_on "jpeg-turbo"
  depends_on "osgeo-proj"
  depends_on "osgeo-libgeotiff"
  depends_on "osgeo-laszip@2"
  depends_on "osgeo-liblas"
  depends_on "osgeo-pdal"
  depends_on "osgeo-gdal"
  depends_on "osgeo-libkml"
  depends_on "osgeo-openscenegraph" # just for its OpenThreads lib # openthreads

  depends_on "cppunit"
  depends_on "regex-opt"

  # depends_on "subversion"
  # depends_on "git"

  depends_on "hdf5" => :optional
  depends_on "open-mpi" => :optional

  # GPSTk
  # Geotrans
  # MrSid

  depends_on :java => :optional # => ["1.8", :build]

  if build.with? "pg10"
    depends_on "osgeo-postgresql@10"
  else
    depends_on "osgeo-postgresql"
  end

  def install
    ENV.cxx11

    ENV["OSSIM_DEV_HOME"] = buildpath.to_s
    ENV["OSSIM_BUILD_DIR"] = (buildpath/"build").to_s
    ENV["OSSIM_INSTALL_PREFIX"] = prefix.to_s

    # TODO: add options and deps for plugins
    args = std_cmake_args + %W[
      -DOSSIM_DEV_HOME=#{ENV["OSSIM_DEV_HOME"]}
      -DINSTALL_LIBRARY_DIR=#{lib}
      -DINSTALL_ARCHIVE_DIR:PATH=#{lib}
      -DFREETYPE_INCLUDE_DIR_ft2build=#{Formula["freetype"].opt_include}
      -DBUILD_OSSIM_TESTS=ON
      -DBUILD_OSSIM_FREETYPE_SUPPORT=ON
      -DBUILD_OSSIM_ID_SUPPORT=ON
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_OSSIM_APPS=ON
      -DBUILD_OMS=ON
      -DBUILD_OSSIM_VIDEO=ON
      -DBUILD_OSSIM_WMS=ON
      -DBUILD_OSSIM_PLANET=ON
    ]

    # not used by the project
    # args += %W[
    #   -DBUILD_CNES_PLUGIN=OFF
    #   -DBUILD_GDAL_PLUGIN=ON
    #   -DBUILD_GEOPDF_PLUGIN=ON
    #   -DBUILD_KAKADU_PLUGIN=OFF
    #   -DBUILD_KML_PLUGIN=ON
    #   -DBUILD_MRSID_PLUGIN=OFF
    #   -DBUILD_OPENCV_PLUGIN=ON
    #   -DBUILD_OPENJPEG_PLUGIN=ON
    #   -DBUILD_PDAL_PLUGIN=ON
    #   -DBUILD_PNG_PLUGIN=ON
    #   -DBUILD_POTRACE_PLUGIN=ON
    #   -DBUILD_SQLITE_PLUGIN=ON
    #   -DBUILD_WEB_PLUGIN=ON
    #   -DMRSID_DIR=
    #   -DOSSIM_BUILD_ADDITIONAL_DIRECTORIES=
    #   -DOSSIM_PLUGIN_LINK_TYPE=SHARED
    # ]

    # error: no member named 'printError' in 'H5::Exception'
    args << "-DBUILD_OSSIM_HDF5_SUPPORT=" + (build.with?("hdf5") ? "ON" : "OFF")

    # generate library instead of framework
    args << "-DBUILD_OSSIM_FRAMEWORKS=ON"

    # build new ossimGui library and geocell application
    args << "-DBUILD_OSSIM_GUI=ON"

    args << "-DBUILD_OSSIM_MPI_SUPPORT=" + (build.with?("mpi") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_CURL_APPS=" + (build.with?("curl-apps") ? "ON" : "OFF")

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end

    # inreplace "#{buildpath}/share/ossim/templates/ossim_preferences_template" do |s|
    #   s.sub! "epsg_database_file1: $(OSSIM_DATA)/ossim/share/ossim/projection/ossim_epsg_projections-v7_4.csv",
    #          "epsg_database_file1: $(OSSIM_DATA)/projection/ossim_epsg_projections-v7_4.csv"
    #   s.sub! "epsg_database_file2: $(OSSIM_DATA)/ossim/share/ossim/projection/ossim_harn_state_plane_epsg.csv",
    #          "epsg_database_file2: $(OSSIM_DATA)/projection/ossim_harn_state_plane_epsg.csv"
    #   s.sub! "epsg_database_file3: $(OSSIM_DATA)/ossim/share/ossim/projection/ossim_state_plane_spcs.csv",
    #          "epsg_database_file3: $(OSSIM_DATA)/projection/ossim_state_plane_spcs.csv"
    #   s.sub! "epsg_database_file4: $(OSSIM_DATA)/ossim/share/ossim/projection/ossim_harn_state_plane_esri.csv",
    #          "epsg_database_file4: $(OSSIM_DATA)/projection/ossim_harn_state_plane_esri.csv"
    #   s.sub! "wkt_database_file: $(OSSIM_DATA)/ossim/share/ossim/projection/ossim_wkt_pcs.csv",
    #          "wkt_database_file: $(OSSIM_DATA)/projection/ossim_wkt_pcs.csv"
    #   s.sub! "geoid_ngs_directory: $(OSSIM_DATA)/ear1/geoid/geoid99",
    #          "geoid_ngs_directory: $(OSSIM_DATA)/geoids/geoid99"
    #   s.sub! "geoid_egm_96_grid: $(OSSIM_DATA)/ele1/geoid/geoid96/egm96.grd",
    #          "geoid_egm_96_grid: $(OSSIM_DATA)/geoids/geoid1996/egm96.grd"
    # end

    cp_r "#{buildpath}/share/ossim/templates", "#{share}/ossim/"
    cp_r "#{buildpath}/share/ossim/geoids", "#{share}/ossim/"
  end

  test do
    system bin/"ossim-cli", "--version"
  end
end

class Ossim < Formula
  desc "Geospatial libs and apps to process imagery, terrain, and vector data"
  homepage "https://trac.osgeo.org/ossim/"

  stable do
    url "https://github.com/ossimlabs/ossim/archive/Hollywood-2.4.2.tar.gz"
    sha256 "1dd0cdc1533753b35922d9e49142012293b132f16bc7bc18823a5dfc541c44eb"
  end

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 3
    sha256 "99d3505fce4506a141f5a22f174136df7dee39bc5a4e9558183c789afa80e0c4" => :high_sierra
    sha256 "99d3505fce4506a141f5a22f174136df7dee39bc5a4e9558183c789afa80e0c4" => :sierra
  end

  option "with-curl-apps", "Build curl-dependent apps"
  option "without-framework", "Generate library instead of framework"
  option "with-gui", "Build new ossimGui library and geocell application"
  option "with-libkml", "Build with Google's libkml driver (requires libkml-dev >= 1.3)"

  depends_on "cmake" => :build
  depends_on "open-scene-graph" # just for its OpenThreads lib
  depends_on "jpeg"
  depends_on "jsoncpp"
  depends_on "libtiff"
  depends_on "libgeotiff"
  depends_on "geos"
  depends_on "freetype"
  depends_on "zlib"
  depends_on "gdal2" => :recommended
  depends_on "open-mpi" => :optional
  depends_on "hdf5" => :optional
  depends_on "libpng" => :optional
  depends_on "opencv" => :optional
  depends_on "openjpeg" => :optional

  if build.with? "libkml"
    depends_on "libkml-dev"
  end

  def install
    ENV.cxx11

    ENV["OSSIM_DEV_HOME"] = buildpath.to_s
    ENV["OSSIM_BUILD_DIR"] = (buildpath/"build").to_s
    ENV["OSSIM_INSTALL_PREFIX"] = prefix.to_s

    # TODO: add options and deps for plugins
    args = std_cmake_args + %W[
      -DOSSIM_DEV_HOME=#{ENV["OSSIM_DEV_HOME"]}
      -DINSTALL_LIBRARY_DIR=lib
      -DBUILD_OSSIM_APPS=ON
      -DBUILD_OMS=OFF
      -DBUILD_CNES_PLUGIN=OFF
      -DBUILD_GEOPDF_PLUGIN=OFF
      -DBUILD_KAKADU_PLUGIN=OFF
      -DBUILD_MRSID_PLUGIN=OFF
      -DMRSID_DIR=
      -DOSSIM_PLUGIN_LINK_TYPE=SHARED
      -DBUILD_PDAL_PLUGIN=OFF
      -DBUILD_POTRACE_PLUGIN=OFF
      -DBUILD_SQLITE_PLUGIN=OFF
      -DBUILD_WEB_PLUGIN=OFF
      -DBUILD_OSSIM_VIDEO=OFF
      -DBUILD_OSSIM_WMS=OFF
      -DBUILD_OSSIM_PLANET=OFF
      -DOSSIM_BUILD_ADDITIONAL_DIRECTORIES=
      -DBUILD_OSSIM_TESTS=OFF
    ]

    # Additional file support
    args << "-DBUILD_GDAL_PLUGIN=" + (build.with?("gdal2") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_HDF5_SUPPORT=" + (build.with?("hdf5") ? "ON" : "OFF")
    args << "-DBUILD_KML_PLUGIN=" + (build.with?("libkml") ? "ON" : "OFF")
    args << "-DBUILD_OPENCV_PLUGIN=" + (build.with?("opencv") ? "ON" : "OFF")
    args << "-DBUILD_PNG_PLUGIN=" + (build.with?("libpng") ? "ON" : "OFF")
    args << "-DBUILD_OPENJPEG_PLUGIN=" + (build.with?("openjpeg") ? "ON" : "OFF")


    args << "-DBUILD_OSSIM_FRAMEWORKS=" + (build.with?("framework") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_MPI_SUPPORT=" + (build.with?("mpi") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_CURL_APPS=" + (build.with?("curl-apps") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_GUI=" + (build.with?("gui") ? "ON" : "OFF")

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system bin/"ossim-cli", "--version"
  end
end

class Ossim < Formula
  desc "Geospatial libs and apps to process imagery, terrain, and vector data"
  homepage "https://trac.osgeo.org/ossim/"

  # TODO: request a tagged release
  # May 18, 2016 commit
  url "https://github.com/ossimlabs/ossim.git",
      :branch => "master",
      :revision => "f01c951587eeb63623b913750bec5097ece86d9a"
  version "1.9.0"
  revision 5

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    sha256 "5377c220a9e7448445989e9b3f89e9dd38710e81bc8936291161d846303a4e58" => :sierra
    sha256 "5377c220a9e7448445989e9b3f89e9dd38710e81bc8936291161d846303a4e58" => :high_sierra
  end

  option "with-curl-apps", "Build curl-dependent apps"
  option "without-framework", "Generate library instead of framework"
  option "with-gui", "Build new ossimGui library and geocell application"

  depends_on "cmake" => :build
  depends_on "open-scene-graph" # just for its OpenThreads lib
  depends_on "jpeg"
  depends_on "jsoncpp"
  depends_on "libtiff"
  depends_on "libgeotiff"
  depends_on "geos"
  depends_on "freetype"
  depends_on "zlib"
  depends_on "mpi" => [:cc, :cxx, :optional]

  def install
    ENV.cxx11

    # build setup expects the checkout to be in subdir named 'ossim'
    cur_dir = Dir["*", ".git*"]
    mkdir "ossim"
    (buildpath/"ossim").install cur_dir
    mkdir "build"

    ENV["OSSIM_DEV_HOME"] = buildpath.to_s
    ENV["OSSIM_BUILD_DIR"] = (buildpath/"build").to_s
    ENV["OSSIM_INSTALL_PREFIX"] = prefix.to_s

    # TODO: add options and deps for plugins
    args = std_cmake_args + %W[
      -DCMAKE_CXX_STANDARD=11
      -DOSSIM_DEV_HOME=#{ENV["OSSIM_DEV_HOME"]}
      -DINSTALL_LIBRARY_DIR=lib
      -DBUILD_OSSIM_APPS=ON
      -DBUILD_OMS=OFF
      -DBUILD_CNES_PLUGIN=OFF
      -DBUILD_GEOPDF_PLUGIN=OFF
      -DBUILD_GDAL_PLUGIN=OFF
      -DBUILD_HDF5_PLUGIN=OFF
      -DBUILD_KAKADU_PLUGIN=OFF
      -DBUILD_KML_PLUGIN=OFF
      -DBUILD_MRSID_PLUGIN=OFF
      -DMRSID_DIR=
      -DOSSIM_PLUGIN_LINK_TYPE=SHARED
      -DBUILD_OPENCV_PLUGIN=OFF
      -DBUILD_OPENJPEG_PLUGIN=OFF
      -DBUILD_PDAL_PLUGIN=OFF
      -DBUILD_PNG_PLUGIN=OFF
      -DBUILD_POTRACE_PLUGIN=OFF
      -DBUILD_SQLITE_PLUGIN=OFF
      -DBUILD_WEB_PLUGIN=OFF
      -DBUILD_OSSIM_VIDEO=OFF
      -DBUILD_OSSIM_WMS=OFF
      -DBUILD_OSSIM_PLANET=OFF
      -DOSSIM_BUILD_ADDITIONAL_DIRECTORIES=
      -DBUILD_OSSIM_TESTS=OFF
    ]

    args << "-DBUILD_OSSIM_FRAMEWORKS=" + (build.with?("framework") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_MPI_SUPPORT=" + (build.with?("mpi") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_CURL_APPS=" + (build.with?("curl-apps") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_GUI=" + (build.with?("gui") ? "ON" : "OFF")

    # fix up include/ossim/base/ossimRefPtr.h
    inreplace "ossim/include/ossim/base/ossimRefPtr.h" do |s|
      s.sub! /(#include <stddef.h>)/, "\\1\n#include <cstddef>"
      s.gsub! "nullptr_t", "std::nullptr_t"
    end

    cd "build" do
      system "cmake", "../ossim/cmake", *args
      # bbedit = "/usr/local/bin/bbedit"
      # system bbedit, "CMakeCache.txt"
      # raise
      system "make"
      system "make", "install"
      File.rename (prefix/"lib64").to_s, lib.to_s
    end
  end

  test do
    system bin/"ossim-cli", "--version"
  end
end

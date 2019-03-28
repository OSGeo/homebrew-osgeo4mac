class OssimAT21 < Formula
  desc "Geospatial libs and apps to process imagery, terrain, and vector data"
  homepage "https://trac.osgeo.org/ossim/"

  stable do
    url "https://github.com/ossimlabs/ossim/archive/EgmontKey-2.1.0.tar.gz"
    sha256 "f1a9577c10ee98962d024b19e78ba53b029d5acc4f506b322a5cffe89e3c122f"
  end

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 1
    sha256 "9002228f425c996fe332e1e150424cf2bc6bb94b8bea8687ab626a9185e872d7" => :high_sierra
    sha256 "9002228f425c996fe332e1e150424cf2bc6bb94b8bea8687ab626a9185e872d7" => :sierra
  end

  keg_only :versioned_formula

  option "with-curl-apps", "Build curl-dependent apps"
  option "without-framework", "Generate library instead of framework"
  option "with-gui", "Build new ossimGui library and geocell application"

  depends_on "cmake" => :build
  depends_on "open-scene-graph" # just for its OpenThreads lib
  depends_on "jpeg"
  depends_on "jsoncpp"
  depends_on "libtiff"
  depends_on "osgeo-libgeotiff"
  depends_on "geos"
  depends_on "freetype"
  depends_on "zlib"
  depends_on "open-mpi" => :optional

  def install
    ENV.cxx11

    # build setup expects the checkout to be in subdir named 'ossim'
#    cur_dir = Dir["*", ".git*"]
#    mkdir "ossim"
#    (buildpath/"ossim").install cur_dir
#    mkdir "build"

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
#    inreplace "ossim/include/ossim/base/ossimRefPtr.h" do |s|
#      s.sub! /(#include <stddef.h>)/, "\\1\n#include <cstddef>"
#      s.gsub! "nullptr_t", "std::nullptr_t"
#    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
#      File.rename (prefix/"lib64").to_s, lib.to_s
    end
  end

  test do
    system bin/"ossim-cli", "--version"
  end
end

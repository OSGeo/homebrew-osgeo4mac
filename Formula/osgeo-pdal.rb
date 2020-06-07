class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_pdal_linked }

  def core_pdal_linked
    Formula["pdal"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink pdal\e[0m or remove with brew \e[32muninstall --ignore-dependencies pdal\e[0m\n\n" if core_pdal_linked
    s
  end
end

class OsgeoPdal < Formula
  include Language::Python::Virtualenv
  desc "Point data abstraction library"
  homepage "https://www.pdal.io/"
  url "https://github.com/PDAL/PDAL/archive/2.1.0.tar.gz"
  sha256 "43ed8ba8ef143e1ded67e96ef72bb73ee133723da0320c3e4f2f87d9bfc3737c"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "184ccc09667aec537a79e1541bc400a5ecfe8238fbfe46c9a0117ffb2a2cd9e9" => :catalina
    sha256 "184ccc09667aec537a79e1541bc400a5ecfe8238fbfe46c9a0117ffb2a2cd9e9" => :mojave
    sha256 "184ccc09667aec537a79e1541bc400a5ecfe8238fbfe46c9a0117ffb2a2cd9e9" => :high_sierra
  end

  #revision 1

  head "https://github.com/PDAL/PDAL.git", :branch => "master"

  option "with-pg11", "Build with PostgreSQL 11 client"

  # keg_only "pdal is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "python"
  depends_on "numpy"
  depends_on "hdf5"
  depends_on "jsoncpp"
  depends_on "sqlite"
  depends_on "laszip" # >= 3.1
  depends_on "geos"
  depends_on "zlib"
  depends_on "libxml2"
  depends_on "curl"
  depends_on "boost"
  depends_on "qt"
  depends_on "eigen"
  depends_on "flann"
  depends_on "libusb"
  depends_on "qhull"
  depends_on "glew"
  depends_on "osgeo-libgeotiff"
  depends_on "osgeo-gdal"
  depends_on "osgeo-laz-perf"
  depends_on "osgeo-vtk"
  depends_on "osgeo-pcl"
  depends_on "osgeo-hexer"

  if build.with?("pg11")
    depends_on "osgeo-postgresql@11"
  else
    depends_on "osgeo-postgresql"
  end

  # -- The following features have been disabled:
  #  * Bash completion, completion for PDAL command line
  #  * CPD plugin, Coherent Point Drift (CPD) computes rigid or nonrigid transformations between point sets
  #  * Delaunay plugin, perform Delaunay triangulation of point cloud
  #  * GeoWave plugin, Read and Write data using GeoWave
  #  * I3S plugin, Read from a I3S server or from a SLPK file
  #  * Matlab plugin, write data to a .mat file
  #  * MrSID plugin, read data in the MrSID format
  #  * NITF plugin, read/write LAS data wrapped in NITF
  #  * OpenSceneGraph plugin, read/write OpenSceneGraph objects
  #  * Oracle OCI plugin, Read/write point clould patches to Oracle
  #  * RiVLib plugin, read data in the RXP format
  #  * rdblib plugin, read data in the RDB format
  #  * MBIO plugin, add features that depend on MBIO
  #  * FBX plugin, add features that depend on FBX

  def install
    ENV.cxx11

    args = std_cmake_args

    args += %W[
      -DBUILD_PLUGIN_GREYHOUND=ON
      -DBUILD_PLUGIN_ICEBRIDGE=ON
      -DBUILD_PLUGIN_PCL=ON
      -DBUILD_PLUGIN_PGPOINTCLOUD=ON
      -DBUILD_PLUGIN_PYTHON=ON
      -DBUILD_PLUGIN_SQLITE=ON
      -DWITH_LASZIP=TRUE
      -DWITH_LAZPERF=TRUE"
    ]

    # args << "-DBUILD_PLUGIN_HEXBIN=ON" # not used by the project

    args << "-DLASZIP_LIBRARIES=#{Formula["laszip"].opt_lib}/liblaszip.dylib"
    args << "-DLASZIP_INCLUDE_DIR=#{Formula["laszip"].opt_include}"

    args << "-DPYTHON_EXECUTABLE=#{Formula["python"].opt_bin}/python#{py_ver}"
    args << "-DPYTHON_INCLUDE_DIR=#{Formula["python"].opt_frameworks}/Python.framework/Versions/#{py_ver}/Headers"
    args << "-DPYTHON_LIBRARY=#{Formula["python"].opt_frameworks}/Python.framework/Versions/#{py_ver}/lib/libpython#{py_ver}.dylib"

    if build.with?("pg10")
      args << "-DPG_CONFIG=#{Formula["osgeo-postgresql@11"].opt_bin}/pg_config"
      args << "-DPOSTGRESQL_INCLUDE_DIR=#{Formula["osgeo-postgresql@11"].opt_include}"
      args << "-DPOSTGRESQL_LIBRARIES=#{Formula["osgeo-postgresql@11"].opt_lib}/libpq.dylib"
    else
      args << "-DPG_CONFIG=#{Formula["osgeo-postgresql"].opt_bin}/pg_config"
      args << "-DPOSTGRESQL_INCLUDE_DIR=#{Formula["osgeo-postgresql"].opt_include}"
      args << "-DPOSTGRESQL_LIBRARIES=#{Formula["osgeo-postgresql"].opt_lib}/libpq.dylib"
    end

    system "cmake", ".", *args
    system "make", "install"
    doc.install "examples", "test"
  end

  test do
    system bin/"pdal", "info", doc/"test/data/las/interesting.las"
  end

  private

  def py_ver
    `#{Formula["python"].opt_bin}/python3 -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`.strip
  end
end

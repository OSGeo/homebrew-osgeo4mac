class OsgeoPcl < Formula
  desc "Library for 2D/3D image and point cloud processing"
  homepage "http://www.pointclouds.org/"
  url "https://github.com/PointCloudLibrary/pcl/archive/pcl-1.11.0.tar.gz"
  sha256 "4255c3d3572e9774b5a1dccc235711b7a723197b79430ef539c2044e9ce65954"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "1c805512e41ce1c2b3414dba02c5bb8531b16caaa0ef97301d93a0f7fb4fac5b" => :catalina
    sha256 "1c805512e41ce1c2b3414dba02c5bb8531b16caaa0ef97301d93a0f7fb4fac5b" => :mojave
    sha256 "1c805512e41ce1c2b3414dba02c5bb8531b16caaa0ef97301d93a0f7fb4fac5b" => :high_sierra
  end

  #revision 3

  head "https://github.com/PointCloudLibrary/pcl.git", :branch => "master"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "cminpack"
  depends_on "eigen"
  depends_on "flann"
  depends_on "glew" # and glu
  depends_on "libusb"
  depends_on "qhull"
  depends_on "qt"
  depends_on "open-mpi"
  depends_on "libharu"
  depends_on "hdf5"
  depends_on "gl2ps"
  depends_on "python"
  depends_on "sphinx"
  depends_on "zlib"
  depends_on "libpng"
  depends_on "libpcap"
  depends_on "doxygen"
  depends_on "szip"
  depends_on "libxml2"
  depends_on "osgeo-proj"
  depends_on "osgeo-netcdf"
  depends_on "osgeo-vtk"
  depends_on "osgeo-qt-webkit"

  depends_on :java => ["1.8", :build]

  # openni2
  # cuda
  # FZAPI, Fotonic and ENSENSO
  # David Vision Systems SDK
  # DepthSense SDK
  # RealSense SDK
  # Mudule: metslib

  # apps - not building:
  # 3d_rec_framework: OpenNI
  # in_hand_scanner: OpenNI
  # cloud_composer: Qt4
  # modeler: Qt4
  # optronic_viewer: Qt
  # point_cloud_editor: Qt4

  def install
    args = std_cmake_args + %w[
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_apps=AUTO_OFF
      -DBUILD_apps_3d_rec_framework=AUTO_OFF
      -DBUILD_apps_cloud_composer=AUTO_OFF
      -DBUILD_apps_in_hand_scanner=AUTO_OFF
      -DBUILD_apps_optronic_viewer=AUTO_OFF
      -DBUILD_apps_point_cloud_editor=AUTO_OFF
      -DBUILD_examples:BOOL=OFF
      -DBUILD_global_tests:BOOL=OFF
      -DBUILD_outofcore:BOOL=AUTO_OFF
      -DBUILD_people:BOOL=AUTO_OFF
      -DBUILD_simulation:BOOL=AUTO_OFF
      -DWITH_CUDA:BOOL=OFF
      -DWITH_DOCS:BOOL=OFF
      -DWITH_QT:BOOL=FALSE
      -DWITH_TUTORIALS:BOOL=OFF
    ]

    # -DCUDA_HOST_COMPILER=/usr/local/bin/gcc

    if build.head?
      args << "-DBUILD_apps_modeler=AUTO_OFF"
    else
      args << "-DBUILD_apps_modeler:BOOL=OFF"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
      prefix.install Dir["#{bin}/*.app"]
    end
  end

  test do
    assert_match "tiff files", shell_output("#{bin}/pcl_tiff2pcd -h", 255)
  end
end

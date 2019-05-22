class OsgeoMarble < Formula
  homepage "http://marble.kde.org/"
  url "https://download.kde.org/stable/applications/19.04.1/src/marble-19.04.1.tar.xz"
  sha256 "acd9c15c4758684f6eff6c2318fc4dd88fd68dd41336de9458cad4d5f6832c61"
  version "19.04.1"

  # revision 1

  head "git://anongit.kde.org/marble"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    rebuild 1
    sha256 "b9b28fdf6d0fbf2894f6103abffa263f05727f7b1c7ac7b5a830725a6e9243f4" => :mojave
    sha256 "b9b28fdf6d0fbf2894f6103abffa263f05727f7b1c7ac7b5a830725a6e9243f4" => :high_sierra
    sha256 "0e556ae04c4a72d7b5e2b486d1a3298ab81ec9d1cd3d06e056cf3820f7bdd1db" => :sierra
  end

  option "with-debug", "Enable debug build type"
  option "without-tools", "Build without extra Marble Tools"
  option "with-examples", "Build Marble library C++ examples"
  option "with-tests", "Build and run unit tests"

  depends_on "cmake" => :build
  depends_on "qt"
  depends_on "quazip" => :recommended
  depends_on "shapelib" => :recommended
  depends_on "gpsd" => :recommended
  depends_on "protobuf" if build.with? "tools"

  def install
    # basic std_cmake_args
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_BUILD_TYPE=#{(build.with?('debug')) ? 'Debug' : 'Release' }
      -DCMAKE_FIND_FRAMEWORK=LAST
      -DCMAKE_VERBOSE_MAKEFILE=TRUE
      -Wno-dev
    ]

    # args << "-DCMAKE_INSTALL_LIBDIR=#{lib}"
    # args << "-DCMAKE_INSTALL_SYSCONFDIR=#{etc}"
    args << "-DQT_PLUGINS_DIR=#{HOMEBREW_PREFIX}/lib/qt/plugins"
    args << "-DBUILD_TESTING=OFF"

    # app build
    args.concat %W[
      -DBUILD_MARBLE_TESTS=#{((build.with? "tests") ? "ON" : "OFF")}
      -DMOBILE=OFF
      -DWITH_libgps=OFF
      -DWITH_libwlocate=OFF
      -DWITH_DESIGNER_PLUGIN=OFF
      -DBUILD_MARBLE_TOOLS=#{((build.with? "tools") ? "ON" : "OFF")}
      -DBUILD_MARBLE_EXAMPLES=#{((build.with? "examples") ? "ON" : "OFF")}
    ]

    # not used by the project
    # args << "-DQTONLY=ON"
    # args << "-DWITH_KF5"
    # args << "-DWITH_Phonon=OFF"
    # args << "-DWITH_QextSerialPort=OFF"
    # args << "-DWITH_QtLocation=OFF"
    # args << "-DWITH_liblocation=OFF"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
  end
end

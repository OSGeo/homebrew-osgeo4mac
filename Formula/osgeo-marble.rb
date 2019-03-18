class OsgeoMarble < Formula
  homepage "http://marble.kde.org/"
  url "https://download.kde.org/stable/applications/18.12.3/src/marble-18.12.3.tar.xz"
  sha256 "0bfd7ae576e42ebbddadc8c83c2fec5edaf462bcf284642b1002d36d751b24ee"
  version "18.12.3"

  revision 1

  head "git://anongit.kde.org/marble"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    sha256 "8f841a6e59e8ddd33832a8a063d4add71b782118db305dfa386aa5c8d383d7d5" => :mojave
    sha256 "8f841a6e59e8ddd33832a8a063d4add71b782118db305dfa386aa5c8d383d7d5" => :high_sierra
    sha256 "ec0502ae4ef80e2d2a3f5def21e97a93017b2491a5a62bc51f9babd7cfbfb5c1" => :sierra
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

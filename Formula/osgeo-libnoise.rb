class OsgeoLibnoise < Formula
  desc "Portable, open-source, coherent noise-generating library for C++"
  homepage "https://github.com/qknight/libnoise"
  url "https://github.com/qknight/libnoise/archive/2fb16f638aac6868d550c735898f217cdefa3559.zip"
  sha256 "6f19ddf41682a716713b12507215a0639f15cf12d94d3ae56256ae63aeb2c22b"
  version "1.0.0-cmake"

  revision 1

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "c9cc8d283d929be6fc8a13b0a71bfc9c3bd47d3c0350ed344a45cbe98f1de2a9" => :mojave
    sha256 "c9cc8d283d929be6fc8a13b0a71bfc9c3bd47d3c0350ed344a45cbe98f1de2a9" => :high_sierra
    sha256 "1e1f0f9842717772ca813a2c58993551af582c04103bf1fc81bec718aa945d7b" => :sierra
  end

  option "with-docs", "Install documentation"

  depends_on "cmake" => :build
  depends_on "doxygen" => :build if build.with? "docs"

  resource "examples" do
    url "http://libnoise.sourceforge.net/downloads/examples.zip"
    sha256 "d6b0d36e0938a2a60d6c9d74a3fd0b7fae5cac3d8f66ffc738a215e856b4702b"
  end

  resource "noiseutils" do
    url "http://libnoise.sourceforge.net/downloads/noiseutils.zip"
    sha256 "2c3d7adf288020b22b42d76d047b676f4e3ef33485808a3334ca062f4b52a7db"
  end

  def install
    inreplace "doc/CMakeLists.txt", "/usr/share", share if build.with? "docs"

    args = std_cmake_args
    args << "-DBUILD_LIBNOISE_DOCUMENTATION=ON" if build.with? "docs"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end

    (prefix/"examples").install resource("examples")

    resource("noiseutils").stage do
      (Pathname.pwd/"CMakeLists.txt").write <<~EOS
        set( PROJECT_NAME libnoiseutils )
        include_directories( "${CMAKE_INSTALL_PREFIX}/include" )
        add_library( noiseutils SHARED noiseutils.cpp )

        set_target_properties( noiseutils PROPERTIES LIBNOISE_VERSION 2 )
        target_link_libraries( noiseutils ${CMAKE_INSTALL_PREFIX}/lib/libnoise.dylib )
        add_definitions( "-Wall -ansi -pedantic -O3" )

        install( FILES "${PROJECT_SOURCE_DIR}/noiseutils.h" DESTINATION
          "${CMAKE_INSTALL_PREFIX}/include" )
        install( TARGETS noiseutils DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" )
      EOS
      mkdir "build" do
        system "cmake", "..", *std_cmake_args
        system "make", "install"
      end
    end
  end

  def caveats; <<~EOS
    This formula is installed from a fork of the main project, which offers a
    a CMake-based install. Original project is located here:

      `http://libnoise.sourceforge.net`

    EOS
  end

  test do
    system ENV.cxx, "#{prefix}/examples/texturejade.cpp", "-o", "test",
           "-I#{include}", "-L#{lib}", "-lnoise", "-lnoiseutils"
    system "./test"
    outputs = %w[textureplane.bmp textureseamless.bmp texturesphere.bmp]
    outputs.each_with_index do |f,i|
      f_size = FileTest.size(f)
      assert f_size && f_size > 102400 # > 100 KiB
      puts "#{f} (#{i+1}/#{outputs.length}) is #{f_size/1024} KiB" if ARGV.verbose?
    end
  end
end

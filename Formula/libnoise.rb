class Libnoise < Formula
  homepage "https://github.com/qknight/libnoise"
  url "https://github.com/qknight/libnoise.git",
      :revision => "ea2e5174ccbc4b30ccdb23e9685a18f3fff66596"
  version "1.0.0-cmake"
  revision 1

  option "with-docs", "Install documentation"

  depends_on "cmake" => :build
  depends_on "doxygen" => :build if build.with? "docs"

  resource "examples" do
    url "http://libnoise.sourceforge.net/downloads/examples.zip"
    sha1 "823e5c1fbe4b889190bdaf1bf6ce5500c8410384"
  end

  resource "noiseutils" do
    url "http://libnoise.sourceforge.net/downloads/noiseutils.zip"
    sha1 "031f13dac6e3383cf9d01219e10080fafb13e45d"
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
      (Pathname.pwd/"CMakeLists.txt").write <<-EOS.undent
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

  def caveats; <<-EOS.undent
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

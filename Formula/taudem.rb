class Taudem < Formula
  homepage "http://hydrology.usu.edu/taudem/taudem5/"
  url "http://hydrology.usu.edu/taudem/taudem5/TauDEM5PCsrc_511.zip"
  sha1 "7d357abcdc2bb4f28134a1a95f54b20426d6edc1"

  bottle do
    root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
    cellar :any
    sha1 "a810d7027dbe24ab04887f8d2f266a259882df24" => :mavericks
  end

  devel do
    # multi-file (directory) support
    url "https://github.com/dtarb/TauDEM.git", :branch => "master"
    version "5.2"
  end

  resource "logan" do
    url "http://hydrology.usu.edu/taudem/taudem5/LoganDemo.zip"
    sha1 "12177f13e6d654b04be1b56713c8fdd6f96360d8"
    version "5.1.1"
  end

  depends_on "cmake" => :build
  depends_on :mpi => [:cc, :cx]

  def install

    inreplace %W[commonLib.h linearpart.h] do |s|
      s.gsub! '"mpi.h"', "<mpi.h>"
    end

    inreplace "Node.cpp",'"stdlib.h"', "<stdlib.h>"
    inreplace "PeukerDouglas.cpp", '"ctime"', "<ctime>"

    inreplace "tiffTest.cpp" do |s|
      s.gsub! '"mpi.h"', "<mpi.h>"
      s.gsub! '"stdint.h"', "<stdint.h>"
    end

    args = std_cmake_args
    mpi = Formula["open-mpi"]
    args << "-DCMAKE_CXX_FLAGS=-I#{mpi.opt_prefix}/include"
    args << "-DCMAKE_EXE_LINKER_FLAGS=-L#{mpi.opt_prefix}/lib -lmpi -lmpi_cxx"

    cd "src" if build.devel?
    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end

  end

  test do
    resource("logan").stage do
      system "#{opt_prefix}/bin/pitremove", "logan.tif"
    end
  end
end

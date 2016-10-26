require File.expand_path("../../Strategies/cache-download", Pathname.new(__FILE__).realpath)

ECWJP2_SDK = "/Hexagon/ERDASEcwJpeg2000SDK5.3.0/Desktop_Read-Only".freeze

class EcwJpeg2000SDK < Requirement
  fatal true
  satisfy(:build_env => false) { File.exist? ECWJP2_SDK }

  def message; <<-EOS.undent
    ERDAS ECW/JP2 SDK was not found at:
      #{ECWJP2_SDK}

    Download SDK and install 'Desktop Read-Only' to default location from:
      http://download.intergraph.com/?ProductName=ERDAS%20ECW/JPEG2000%20SDK
  EOS
  end
end

class Ecwjp2Sdk < Formula
  desc "Decompression library for ECW- and JPEG2000- compressed imagery"
  homepage "http://www.hexagongeospatial.com/products/provider-suite/erdas-ecw-jp2-sdk"
  url "http://qgis.dakotacarto.com/osgeo4mac/dummy.tar.gz"
  version "5.3.0"
  sha256 "e7776e2ff278d6460300bd69a26d7383e6c5e2fbeb17ff12998255e7fc4c9511"

  depends_on :macos => :lion # as per SDK docs
  depends_on EcwJpeg2000SDK
  depends_on "gdal2"

  def gdal_clib
    gdal_lib = "#{Formula["gdal2"].opt_lib}/libgdal.dylib"
    (`otool -L #{gdal_lib}`.include? "libstdc++") ? "std" : ""
  end

  def install
    # vendor Desktop Read-Only lib, etc
    # match c-lib that gdal was built against
    lib.mkpath
    (include/"ECWJP2").mkpath
    cp "#{ECWJP2_SDK}/redistributable/lib#{gdal_clib}c++/libNCSEcw.dylib", "#{lib}/"
    %w[etc Licenses].each { |f| cp_r "#{ECWJP2_SDK}/#{f}", "#{prefix}/" }
    cp_r Dir["#{ECWJP2_SDK}/include/*"], "#{include}/ECWJP2/"

    # for test
    (prefix/"test").mkpath
    cp "#{ECWJP2_SDK}/Examples/decompression/example1/dexample1.c", prefix/"test/"
    cp "#{ECWJP2_SDK}/TestData/RGB_8bit.ecw", prefix/"test/"
    cp "#{ECWJP2_SDK}/TestData/RGB_8bit.jp2", prefix/"test/"
  end

  def caveats; <<-EOS.undent
    Once formula is installed, the ERDAS ECW/JP2 SDK can be deleted from its
    default install location of:

      #{Pathname.new(ECWJP2_SDK).dirname}

    Headers installed to:

      #{opt_include}/ECWJP2

    EOS
  end

  test do
    cp prefix/"test/dexample1.c", testpath
    system ENV.cc, "-I#{opt_include}/ECWJP2", "-L#{opt_lib}", "-lNCSEcw",
           "-o", "test", "dexample1.c"

    %w[ecw jp2].each do |f|
      out = `./test #{prefix}/test/RGB_8bit.#{f}`
      assert_match "Region   99", out
      assert_match "Region    0", out
      assert_match "ALL    time", out
    end
  end
end

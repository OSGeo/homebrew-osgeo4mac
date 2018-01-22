require File.expand_path("../../Strategies/cache-download", Pathname.new(__FILE__).realpath)

ECWJP2_SDK = "/Hexagon/ERDASEcwJpeg2000SDK5.3.0/Desktop_Read-Only".freeze

class EcwJpeg2000SDK < Requirement
  fatal true
  satisfy(:build_env => false) { File.exist? ECWJP2_SDK }

  def message; <<~EOS
    ERDAS ECW/JP2 SDK was not found at:
      #{ECWJP2_SDK}

    Download SDK and install 'Desktop Read-Only' to default location from:
      http://download.intergraph.com/?ProductName=ERDAS%20ECW/JPEG2000%20SDK
  EOS
  end
end

class Ecwjp2Sdk < Formula
  desc "Decompression library for ECW- and JPEG2000-compressed imagery"
  homepage "http://www.hexagongeospatial.com/products/provider-suite/erdas-ecw-jp2-sdk"
  url "https://osgeo4mac.s3.amazonaws.com/src/dummy.tar.gz"
  version "5.3.0"
  sha256 "e7776e2ff278d6460300bd69a26d7383e6c5e2fbeb17ff12998255e7fc4c9511"

  depends_on :macos => :lion # as per SDK docs
  depends_on EcwJpeg2000SDK

  def install
    lib.mkpath
    (include/"ECWJP2").mkpath
    cd ECWJP2_SDK do
      # vendor Desktop Read-Only libs, etc
      # suffix only the older stdc++
      cp "redistributable/libc++/libNCSEcw.dylib", "#{lib}/"
      cp "redistributable/libstdc++/libNCSEcw.dylib", "#{lib}/libNCSEcw-stdcxx.dylib"
      system "install_name_tool", "-id", opt_lib/"libNCSEcw-stdcxx.dylib", lib/"libNCSEcw-stdcxx.dylib"
      %w[etc Licenses].each { |f| cp_r f.to_s, "#{prefix}/" }
      cp_r Dir["include/*"], "#{include}/ECWJP2/"

      # for test
      (prefix/"test").mkpath
      cp "Examples/decompression/example1/dexample1.c", prefix/"test/"
      %w[ecw jp2].each { |f| cp "TestData/RGB_8bit.#{f}", prefix/"test/" }
    end
  end

  def caveats; <<~EOS
    Once formula is installed, the ERDAS ECW/JP2 SDK can be deleted from its
    default install location of:

      #{Pathname.new(ECWJP2_SDK).dirname}

    Headers installed to:

      #{opt_include}/ECWJP2

    EOS
  end

  test do
    cp prefix/"test/dexample1.c", testpath
    ["", "-stdcxx"].each do |s|
      system ENV.cc, "-I#{opt_include}/ECWJP2", "-L#{opt_lib}", "-lNCSEcw#{s}",
             "-o", "test#{s}", "dexample1.c"

      %w[ecw jp2].each do |f|
        out = `./test#{s} #{prefix}/test/RGB_8bit.#{f}`
        assert_match "Region   99", out
        assert_match "Region    0", out
        assert_match "ALL    time", out
      end
    end
  end
end

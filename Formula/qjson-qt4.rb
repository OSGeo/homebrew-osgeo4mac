class QjsonQt4 < Formula
  desc "Map JSON to QVariant objects"
  homepage "https://qjson.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/qjson/qjson/0.8.1/qjson-0.8.1.tar.bz2"
  mirror "https://mirrors.kernel.org/debian/pool/main/q/qjson/qjson_0.8.1.orig.tar.bz2"
  sha256 "cd4db5b956247c4991a9c3e95512da257cd2a6bd011357e363d02300afc814d9"
  head "https://github.com/flavio/qjson.git"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    sha256 "b1c454074eb32130bb2be41f9790f8d138437ee1cdc1c29c5cf1922e25e22f0c" => :sierra
    sha256 "b1c454074eb32130bb2be41f9790f8d138437ee1cdc1c29c5cf1922e25e22f0c" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "qt-4"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <qjson/parser.h>
      int main() {
        QJson::Parser parser;
        return 0;
      }
    EOS
    system ENV.cxx, "-I#{include}", "-I#{Formula["qt-4"].opt_include}",
           "-L#{lib}", "-lqjson",
           testpath/"test.cpp", "-o", testpath/"test"
    system "./test"
  end
end

class Shark < Formula
  desc "Machine leaning library"
  homepage "http://image.diku.dk/shark/"
  url "https://github.com/Shark-ML/Shark/archive/v4.0.1.tar.gz"
  sha256 "1caf9c73c5ebf54f9543a090e2b05ac646f95559aa1de483cd7662c378c1ec21"

  revision 1

  head "https://github.com/Shark-ML/Shark.git", :branch => "master"

  bottle :disable, "needs to be rebuilt with latest boost"

  depends_on "cmake" => :build
  depends_on "boost"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system bin/"SharkVersion"
    # (testpath/"data.csv").write <<~EOS
    #   1 1 0
    #   2 2 1
    # EOS
    #
    # (testpath/"test.cpp").write <<~EOS
    #   #include <shark/Data/Csv.h>
    #   using namespace shark;
    #
    #   int main() {
    #     ClassificationDataset data;
    #     importCSV(data, "data.csv", LAST_COLUMN, ' ');
    #   }
    # EOS
    #
    # system ENV.cxx, "test.cpp", "-o", "test", "-L#{lib}", "-lshark",
    #        "-L#{Formula["boost"].lib}", "-lboost_serialization",
    #        "-I#{Formula["boost"].include}"
    # system "./test"
  end
end

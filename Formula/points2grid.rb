require 'formula'

class Points2grid < Formula
  homepage 'https://github.com/CRREL/points2grid'
  url 'https://github.com/CRREL/points2grid/archive/1.1.1.tar.gz'
  sha1 'f0a7841f1cd804b67bf7ccd15bc5b3bcada975a7'

  depends_on 'cmake' => :build
  depends_on 'boost'

  def install
    prefix.install "example.las"
    system "cmake", ".", *std_cmake_args
    system "make install"
  end

  test do
    mktemp do
      system bin/"points2grid",
             "-i", prefix/"example.las",
             "-o", "example",
             "--max", "--output_format", "grid"
      assert_equal 5, %x(grep -c '423.820000' < example.max.grid).strip.to_i
    end
  end
end

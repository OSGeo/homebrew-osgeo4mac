require 'formula'

class Points2grid < Formula
  homepage 'https://github.com/CRREL/points2grid'
  url 'https://github.com/CRREL/points2grid/archive/1.2.0.tar.gz'
  sha1 '49fbc3016b2904ed75c67c486cba839b5ac3548c'

  head "https://github.com/CRREL/points2grid.git"

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
      assert_equal 5, %x(grep -c '423.82' < example.max.grid).strip.to_i
    end
  end
end

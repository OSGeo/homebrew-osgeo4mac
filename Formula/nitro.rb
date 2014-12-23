class Nitro < Formula
  homepage "https://github.com/hobu/nitro"
  # TODO: request a tagged release
  url "https://github.com/hobu/nitro.git", :revision => "a3539c63128d9190fbd0043c1652d1b9397f8fcd"
  version "1.0-a3539c6"
  sha1 "a3539c63128d9190fbd0043c1652d1b9397f8fcd"

  head "https://github.com/hobu/nitro.git", :branch => "master"

  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  test do
    # installs just a lib
  end
end

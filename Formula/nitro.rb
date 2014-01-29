require "formula"

class Nitro < Formula
  homepage "https://github.com/hobu/nitro"
  # TODO: request a tagged release
  url "https://github.com/hobu/nitro.git", :revision => "c0c3fbba2638a68d3300191cd0a204542b78fc78"
  version "1.0-c0c3fbb"
  sha1 "c0c3fbba2638a68d3300191cd0a204542b78fc78"

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

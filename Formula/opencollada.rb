class Opencollada < Formula
  desc "Stream based reader and writer library for COLLADA files"
  homepage "http://www.opencollada.org"
  url "https://github.com/KhronosGroup/OpenCOLLADA/archive/v1.6.59.tar.gz"
  sha256 "638ce67a3f8fe0ce99b69ba143f1ecf80813b41ed09438cfbb07aa913f1b89d7"

  # revision 1

  head "https://github.com/KhronosGroup/OpenCOLLADA.git", :branch => "master"

  bottle do
    cellar :any_skip_relocation
    sha256 "34252dd8c9f605f9f1ffdef4c5675820e14ccc586236f4eb095d7182dba13a55" => :mojave
    sha256 "34252dd8c9f605f9f1ffdef4c5675820e14ccc586236f4eb095d7182dba13a55" => :high_sierra
    sha256 "34252dd8c9f605f9f1ffdef4c5675820e14ccc586236f4eb095d7182dba13a55" => :sierra
  end

  depends_on "cmake" => :build
  unless OS.mac?
    depends_on "libxml2"
    depends_on "pcre"
  end

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
      prefix.install "bin"
      Dir.glob("#{bin}/*.xsd") { |p| rm p }
    end
  end

  test do
    system "#{bin}/OpenCOLLADAValidator"
  end
end

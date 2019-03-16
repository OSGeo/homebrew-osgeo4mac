class OsgeoOpencollada < Formula
  desc "Stream based reader and writer library for COLLADA files"
  homepage "http://www.opencollada.org"
  url "https://github.com/KhronosGroup/OpenCOLLADA/archive/v1.6.68.tar.gz"
  sha256 "d9db0c0a518aa6ac0359626f222707c6ca1b63a83cbf229d97a5999c9cde347b"

  revision 1

  head "https://github.com/KhronosGroup/OpenCOLLADA.git", :branch => "master"

  depends_on "cmake" => :build
  #unless OS.mac?
  depends_on "libxml2"
  depends_on "pcre"
  # end

  # fixed PCRE usage
  patch do
    url "https://patch-diff.githubusercontent.com/raw/KhronosGroup/OpenCOLLADA/pull/615.diff"
    sha256 "cf45702543aaabb443111781285f95db95b2fbda71f56458dafc73387ebab78b"
  end

  # detecting isnan
  patch do
    url "https://patch-diff.githubusercontent.com/raw/KhronosGroup/OpenCOLLADA/pull/576.diff"
    sha256 "346eb47bf4f0d77284a59b566cba8d9edd97c2a89cac1da71f7c272bd5c40b8c"
  end

  def install
    args = std_cmake_args

    args << "-DUSE_LIBXML=ON"
    args << "-DUSE_STATIC=ON"
    args << "-DUSE_SHARED=ON"
    # args << "USE_EXPAT=OFF" # Use expat parser. Unsupported currently. Do not use.
    # args << "-DWITH_IN_SOURCE_BUILD=ON"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
      prefix.install "bin"
      Dir.glob("#{bin}/*.xsd") { |p| rm p }
    end
  end

  test do
    system "#{bin}/OpenCOLLADAValidator"
  end
end

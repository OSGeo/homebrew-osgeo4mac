class OsgeoMuparserx < Formula
  desc "the muparserx math parser library"
  homepage "http://articles.beltoforion.de/article.php?a=muparserx"
  url "https://github.com/beltoforion/muparserx/archive/v4.0.8.tar.gz"
  sha256 "5913e0a4ca29a097baad1b78a4674963bc7a06e39ff63df3c73fbad6fadb34e1"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    sha256 "5af85a06844fecba30fb23c997031958ba9f8b7be00245a26330755f81b71112" => :mojave
    sha256 "5af85a06844fecba30fb23c997031958ba9f8b7be00245a26330755f81b71112" => :high_sierra
    sha256 "ded4ce5df774c51f10a8137b7b23b98317ecdef59183bba0375815201699a127" => :sierra
  end

  # revision 1

  head "https://github.com/beltoforion/muparserx.git", :branch => "master"

  depends_on "cmake" => :build

  def install
    args = std_cmake_args + %W[
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_EXAMPLES=OFF
    ]

    # args << "-DCMAKE_SKIP_RPATH=ON"

    mkdir "builddir" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    # TODO
  end
end

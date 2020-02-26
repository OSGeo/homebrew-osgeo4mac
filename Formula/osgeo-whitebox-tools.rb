class OsgeoWhiteboxTools < Formula
  desc "An advanced geospatial data analysis platform"
  homepage "https://www.uoguelph.ca/~hydrogeo/WhiteboxTools"
  url "https://jblindsay.github.io/ghrg/WhiteboxTools/WhiteboxTools_darwin_amd64.zip"
  sha256 "c6bbd1bf8775ee778b11bb816f54dc50a93633b5f8480b512129d27cad346737"
  version "1.2.0"

  # revision 1

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    rebuild 1
    sha256 "fa1b845da9db1af548184ec857e83b29be824600f39d093ddbf5c06a2b50e06c" => :mojave
    sha256 "fa1b845da9db1af548184ec857e83b29be824600f39d093ddbf5c06a2b50e06c" => :high_sierra
    sha256 "8fbec938117405301c0de183331e42fcb4569fbc4a1279d57fa11833dabe7ac8" => :sierra
  end

  def install
    cp_r buildpath.to_s, prefix.to_s
    mkdir bin.to_s
    ln_s "#{prefix}/WBT/whitebox_tools", "#{bin}/whitebox_tools"
  end

  test do
    system "#{bin}/whitebox_tools", "--toolbox=Slope"
  end
end

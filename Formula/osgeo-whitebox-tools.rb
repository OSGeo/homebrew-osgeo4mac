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
    sha256 "24b5c05d0b058953e7a783f1a923be428ff1ffc27fc48a4a9bc7b120a6830809" => :catalina
    sha256 "24b5c05d0b058953e7a783f1a923be428ff1ffc27fc48a4a9bc7b120a6830809" => :mojave
    sha256 "24b5c05d0b058953e7a783f1a923be428ff1ffc27fc48a4a9bc7b120a6830809" => :high_sierra
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

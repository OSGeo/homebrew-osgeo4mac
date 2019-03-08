class WhiteboxTools < Formula
  desc "An advanced geospatial data analysis platform"
  homepage "https://www.uoguelph.ca/~hydrogeo/WhiteboxTools"
  url "https://github.com/jblindsay/whitebox-tools/releases/download/v0.14.1/WhiteboxTools_darwin_amd64.zip"
  sha256 "1a96a037a83f3c1b83eff03c586ae6783bd6abcf04d8b0f9f0724cbe348352a8"
  version "0.14.1"

  revision 30

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any_skip_relocation
    rebuild 1
    sha256 "a94aefc8e401992fc121d58ffa20c2380276db3a73f97596c92b92936a7215c6" => :mojave
    sha256 "a94aefc8e401992fc121d58ffa20c2380276db3a73f97596c92b92936a7215c6" => :high_sierra
    sha256 "906d1ecf493446f142c7f3528285b3683eb4ef4b64dc9138f5f591b386bfb7f4" => :sierra
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

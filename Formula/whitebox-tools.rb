class WhiteboxTools < Formula
  desc "An advanced geospatial data analysis platform"
  homepage "https://www.uoguelph.ca/~hydrogeo/WhiteboxTools"
  url "https://github.com/jblindsay/whitebox-tools/releases/download/v0.14.1/WhiteboxTools_darwin_amd64.zip"
  sha256 "1a96a037a83f3c1b83eff03c586ae6783bd6abcf04d8b0f9f0724cbe348352a8"
  version "0.14.1"

  revision 5

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any_skip_relocation
    rebuild 1
    sha256 "f1e1616d97bfb3ed17740a764cb14ad76e37e61045560942e114c71c85e14ae6" => :mojave
    sha256 "f1e1616d97bfb3ed17740a764cb14ad76e37e61045560942e114c71c85e14ae6" => :high_sierra
    sha256 "f1e1616d97bfb3ed17740a764cb14ad76e37e61045560942e114c71c85e14ae6" => :sierra
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

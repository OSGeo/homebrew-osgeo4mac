class WhiteboxTools < Formula
  desc "An advanced geospatial data analysis platform"
  homepage "https://www.uoguelph.ca/~hydrogeo/WhiteboxTools"
  url "https://github.com/jblindsay/whitebox-tools/releases/download/v0.14.1/WhiteboxTools_darwin_amd64.zip"
  sha256 "1a96a037a83f3c1b83eff03c586ae6783bd6abcf04d8b0f9f0724cbe348352a8"
  version "0.14.1"

  revision 26

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any_skip_relocation
    sha256 "39586f95a1a3d2b41372ef1b5c07fc7f74082c899adac04f27288438fb0fcaf7" => :mojave
    sha256 "39586f95a1a3d2b41372ef1b5c07fc7f74082c899adac04f27288438fb0fcaf7" => :high_sierra
    sha256 "fb0a2980391282c1c6b2ba35d5d804b974abddde4e4a533ef3221f1493d1a95a" => :sierra
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

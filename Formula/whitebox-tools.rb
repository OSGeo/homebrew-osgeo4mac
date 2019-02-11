class WhiteboxTools < Formula
  desc "An advanced geospatial data analysis platform"
  homepage "https://www.uoguelph.ca/~hydrogeo/WhiteboxTools" # https://github.com/jblindsay/whitebox-tools
  url "https://github.com/jblindsay/whitebox-tools/releases/download/v0.14.1/WhiteboxTools_darwin_amd64.zip"
  version "0.14.1"
  sha256 "1a96a037a83f3c1b83eff03c586ae6783bd6abcf04d8b0f9f0724cbe348352a8"

  revision 2

  def install
    cp_r buildpath.to_s, prefix.to_s
    mkdir bin.to_s
    ln_s "#{prefix}/WBT/whitebox_tools", "#{bin}/whitebox_tools"
  end

  test do
    system "#{bin}/whitebox_tools", "--toolbox=Slope"
  end
end

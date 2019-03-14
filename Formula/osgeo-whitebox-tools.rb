class OsgeoWhiteboxTools < Formula
  desc "An advanced geospatial data analysis platform"
  homepage "https://www.uoguelph.ca/~hydrogeo/WhiteboxTools"
  url "https://github.com/jblindsay/whitebox-tools/releases/download/v0.15/WhiteboxTools_darwin_amd64.zip"
  sha256 "6e425ddf43f1c9cdcd9f00c9766a66fd42f5477aac30a5bc9b96784f9fb4c026"
  version "0.14.1"

  revision 1

  def install
    cp_r buildpath.to_s, prefix.to_s
    mkdir bin.to_s
    ln_s "#{prefix}/WBT/whitebox_tools", "#{bin}/whitebox_tools"
  end

  test do
    system "#{bin}/whitebox_tools", "--toolbox=Slope"
  end
end

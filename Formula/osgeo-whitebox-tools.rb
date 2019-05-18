class OsgeoWhiteboxTools < Formula
  desc "An advanced geospatial data analysis platform"
  homepage "https://www.uoguelph.ca/~hydrogeo/WhiteboxTools"
  url "https://github.com/jblindsay/whitebox-tools/releases/download/v0.15/WhiteboxTools_darwin_amd64.zip"
  sha256 "6e425ddf43f1c9cdcd9f00c9766a66fd42f5477aac30a5bc9b96784f9fb4c026"
  version "0.15.0"

  # revision 1

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    sha256 "19507ae5828608c527399fa341cf10717816560afaa4a0baea8a2314e255ca03" => :mojave
    sha256 "19507ae5828608c527399fa341cf10717816560afaa4a0baea8a2314e255ca03" => :high_sierra
    sha256 "82095e47993400f30714aed1164c3a2e6fe2f286198dddf5708afbe5dd90d56a" => :sierra
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

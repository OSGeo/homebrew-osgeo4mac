class WhiteboxTools < Formula
  desc "An advanced geospatial data analysis platform"
  homepage "https://www.uoguelph.ca/~hydrogeo/WhiteboxTools"
  url "https://github.com/jblindsay/whitebox-tools/releases/download/v0.13/WhiteboxTools_darwin_amd64.zip"
  sha256 "fe79c3b797ba7ae23a525e11441b0d6406c339858b23271c143734c62af7ec27"
  # url "https://github.com/jblindsay/whitebox-tools.git",
  #   :branch => "master",
  #   :commit => "f0cf6af792de8f60dd8afb10e3f0a26df1c702c4"
  version "0.13.0"

  # revision 1

  # head "https://github.com/jblindsay/whitebox-tools.git", :branch => "master"

  def install
    cp_r "#{buildpath}", "#{prefix}"
    mkdir "#{bin}"
    ln_s "#{prefix}/WBT/whitebox_tools", "#{bin}/whitebox_tools"
  end

  test do
    system "#{bin}/whitebox_tools", "--toolbox=Slope"
  end
end

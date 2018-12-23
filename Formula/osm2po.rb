class CurlRefererDownloadStrategy < CurlDownloadStrategy
  def _fetch
    domain_url = @url.sub(/([^:]+:\/\/[^\/]+)(.*)/, "\\1")
    curl @url, "-e", domain_url, "-C", downloaded_size, "-o", temporary_path
  end
end

class Osm2po < Formula
  homepage "https://osm2po.de"
  url "https://osm2po.de/releases/osm2po-5.2.126.zip"
  sha256 "43987da8b65f8a8598d3f8aa56afe0e2d9b54b65db703c4c791e1e79a3ccabc9"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any_skip_relocation
    sha256 "c9ed9224e1ae4ba4081c9bfaaec13ea0546149e3471b173362294011c11f9e80" => :mojave
    sha256 "c9ed9224e1ae4ba4081c9bfaaec13ea0546149e3471b173362294011c11f9e80" => :high_sierra
    sha256 "c9ed9224e1ae4ba4081c9bfaaec13ea0546149e3471b173362294011c11f9e80" => :sierra
  end

  def install
    doc.install Dir["osm2po-doc/*"]
    rm "demo.bat"
    libexec.install Dir["*"]
    bin.write_jar_script libexec/"osm2po-core-#{version.to_s}-signed.jar", "osm2po"
    (libexec/"demo.sh").chmod 0755
  end

  def caveats; <<~EOS
      The generated executable:
        osm2po <my-params>
      executes:
        exec java -jar <path-to-osm2po.jar> <my-params>
    EOS
  end

  test do
    system "#{bin}/osm2po", "--help"
  end
end

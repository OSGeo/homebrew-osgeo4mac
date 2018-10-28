class CurlRefererDownloadStrategy < CurlDownloadStrategy
  def _fetch
    domain_url = @url.sub(/([^:]+:\/\/[^\/]+)(.*)/, "\\1")
    curl @url, "-e", domain_url, "-C", downloaded_size, "-o", temporary_path
  end
end

class Osm2po < Formula
  homepage "https://osm2po.de"
  url "https://osm2po.de/releases/osm2po-5.2.124.zip"
  sha256 "153f6f97e6b8ac0fb40cfb2e1b08221bec049352150458121d20ed26a973aef8"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any_skip_relocation
    sha256 "8f2b1f8cce3bc062ff56ea7dbda18788cc4fb7de08ff57a111000b2ce0c75ca4" => :high_sierra
    sha256 "8f2b1f8cce3bc062ff56ea7dbda18788cc4fb7de08ff57a111000b2ce0c75ca4" => :sierra
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

class CurlRefererDownloadStrategy < CurlDownloadStrategy
  def _fetch
    domain_url = @url.sub(/([^:]+:\/\/[^\/]+)(.*)/, "\\1")
    curl @url, "-e", domain_url, "-C", downloaded_size, "-o", temporary_path
  end
end

class OsgeoOsm2po < Formula
  desc "Openstreetmap converter and routing engine for java"
  homepage "https://osm2po.de"
  url "https://osm2po.de/releases/osm2po-5.2.127.zip"
  sha256 "607fc4c2007c713dd867fd51cc8b8f403aa8d6048f8eb7e15124d9786f39d165"

  revision 1

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    rebuild 1
    sha256 "b5721c5081b85ec5f045c631102c4e990818c42f50f56934712fa36f070d1546" => :mojave
    sha256 "b5721c5081b85ec5f045c631102c4e990818c42f50f56934712fa36f070d1546" => :high_sierra
    sha256 "b5721c5081b85ec5f045c631102c4e990818c42f50f56934712fa36f070d1546" => :sierra
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

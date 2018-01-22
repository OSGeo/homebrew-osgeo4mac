class CurlRefererDownloadStrategy < CurlDownloadStrategy
  def _fetch
    domain_url = @url.sub(/([^:]+:\/\/[^\/]+)(.*)/, "\\1")
    curl @url, "-e", domain_url, "-C", downloaded_size, "-o", temporary_path
  end
end

class Osm2po < Formula
  homepage "http://osm2po.de"
  url "http://osm2po.de/releases/osm2po-5.0.0.zip", :using => CurlRefererDownloadStrategy
  sha256 "b3cf06899dee97e80a40e4e15b81f7823ec467fd82d5c97c767e670850f9d6ac"

  def install
    doc.install Dir["osm2po-doc/*"]
    rm "demo.bat"
    libexec.install Dir["*"]
    bin.write_jar_script libexec/"osm2po-core-5.0.0-signed.jar", "osm2po"
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

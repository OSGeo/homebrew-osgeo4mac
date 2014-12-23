class CurlRefererDownloadStrategy < CurlDownloadStrategy
  def _fetch
    domain_url = @url.sub(/([^:]+:\/\/[^\/]+)(.*)/, "\\1")
    curl @url, "-e", domain_url, "-C", downloaded_size, "-o", temporary_path
  end
end

class Osm2po < Formula
  homepage "http://osm2po.de"
  url "http://osm2po.de/download.php?lnk=osm2po-4.8.8.zip", :using => CurlRefererDownloadStrategy
  sha1 "c12d7f5e2d90f64d807053350d7233a8a59b9006"

  def install
    doc.install Dir["osm2po-doc/*"]
    rm "demo.bat"
    libexec.install Dir["*"]
    bin.write_jar_script libexec/"osm2po-core-4.8.8-signed.jar", "osm2po"
    (libexec/"demo.sh").chmod 0755
  end

  def caveats; <<-EOS.undent
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

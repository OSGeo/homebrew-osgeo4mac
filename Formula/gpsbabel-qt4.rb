class GpsbabelQt4 < Formula
  desc "Converts/uploads GPS waypoints, tracks, and routes"
  homepage "https://www.gpsbabel.org/"
  url "https://github.com/gpsbabel/gpsbabel/archive/gpsbabel_1_5_3.tar.gz"
  sha256 "10b7aaca44ce557fa1175fec37297b8df55611ab2c51cb199753a22dbf2d3997"

  head "https://github.com/gpsbabel/gpsbabel.git"

  bottle do
    root_url "http://qgis.dakotacarto.com/bottles"
    sha256 "2a301096e4953b7efbf3646408224bee4d3a199ea53797a265bb0f18161155a0" => :sierra
  end

  keg_only "gpsbabel is in main tap and same-name bin utilities are installed"

  depends_on "libusb" => :optional
  depends_on "qt-4"

  def install
    args = ["--disable-debug", "--disable-dependency-tracking",
            "--prefix=#{prefix}"]
    args << "--without-libusb" if build.without? "libusb"
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.loc").write <<-EOS.undent
      <?xml version="1.0"?>
      <loc version="1.0">
        <waypoint>
          <name id="1 Infinite Loop"><![CDATA[Apple headquarters]]></name>
          <coord lat="37.331695" lon="-122.030091"/>
        </waypoint>
      </loc>
    EOS
    system bin/"gpsbabel", "-i", "geo", "-f", "test.loc", "-o", "gpx", "-F", "test.gpx"
    assert File.exist? "test.gpx"
  end
end

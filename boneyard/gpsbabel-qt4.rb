class GpsbabelQt4 < Formula
  desc "Converts/uploads GPS waypoints, tracks, and routes"
  homepage "https://www.gpsbabel.org/"
  url "https://github.com/gpsbabel/gpsbabel/archive/gpsbabel_1_5_3.tar.gz"
  sha256 "10b7aaca44ce557fa1175fec37297b8df55611ab2c51cb199753a22dbf2d3997"
  revision 1

  head "https://github.com/gpsbabel/gpsbabel.git"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    sha256 "6d25eda9d6eca9e834c56a2d05dc5049ede3a7ee8988422f145d7075664a470d" => :sierra
    sha256 "6d25eda9d6eca9e834c56a2d05dc5049ede3a7ee8988422f145d7075664a470d" => :high_sierra
  end

  keg_only "gpsbabel is in main tap and same-name bin utilities are installed"

  depends_on "libusb" => :optional
  depends_on "qt-4"

  # Fix build with Xcode 9, remove for next version
  patch do
    url "https://github.com/gpsbabel/gpsbabel/commit/b7365b93.patch?full_index=1"
    sha256 "e949182def36fef99889e43ba4bc4d61e36d6b95badc74188a8cd3da5156d341"
  end

  def install
    args = ["--disable-debug", "--disable-dependency-tracking",
            "--prefix=#{prefix}"]
    args << "--without-libusb" if build.without? "libusb"
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.loc").write <<~EOS
      <?xml version="1.0"?>
      <loc version="1.0">
        <waypoint>
          <name id="1 Infinite Loop"><![CDATA[Apple headquarters]]></name>
          <coord lat="37.331695" lon="-122.030091"/>
        </waypoint>
      </loc>
    EOS
    system bin/"gpsbabel", "-i", "geo", "-f", "test.loc", "-o", "gpx", "-F", "test.gpx"
    assert_predicate testpath/"test.gpx", :exist?
  end
end

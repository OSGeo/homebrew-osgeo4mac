class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_proj_linked }

  def core_proj_linked
    Formula["proj"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink proj\e[0m or remove with \e[32mbrew uninstall --ignore-dependencies proj\e[0m\n\n" if core_proj_linked
    s
  end
end

class OsgeoProj < Formula
  desc "Cartographic Projections Library"
  homepage "https://proj4.org/"
  url "https://github.com/OSGeo/proj.4/archive/6.0.0.tar.gz"
  sha256 "8c2bc0b31ba266d59771bac14b589814a8e38b23822210b4dc038be737d61d7d"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    sha256 "858d97a47173a71cbc3f3f82997c560e2b433b4ffdf084482220c9078298b98b" => :mojave
    sha256 "858d97a47173a71cbc3f3f82997c560e2b433b4ffdf084482220c9078298b98b" => :high_sierra
    sha256 "d9fc1a48f875e94b9be3e59241615320a8e05fa6968c733daccb7d6e0227a6f5" => :sierra
  end

  revision 3

  head "https://github.com/OSGeo/proj.4.git", :branch => "master"

  # keg_only "proj is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  conflicts_with "blast", :because => "both install a `libproj.a` library"

  skip_clean :la

  # The datum grid files are required to support datum shifting
  resource "datumgrid" do
    url "https://download.osgeo.org/proj/proj-datumgrid-1.8.zip"
    sha256 "b9838ae7e5f27ee732fb0bfed618f85b36e8bb56d7afb287d506338e9f33861e"
  end

  def install
    (buildpath/"nad").install resource("datumgrid")

    system "./autogen.sh"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test").write <<~EOS
      45d15n 71d07w Boston, United States
      40d40n 73d58w New York, United States
      48d51n 2d20e Paris, France
      51d30n 7'w London, England
    EOS
    match = <<~EOS
      -4887590.49\t7317961.48 Boston, United States
      -5542524.55\t6982689.05 New York, United States
      171224.94\t5415352.81 Paris, France
      -8101.66\t5707500.23 London, England
    EOS

    output = shell_output("#{bin}/proj +proj=poly +ellps=clrk66 -r #{testpath}/test")
    assert_equal match, output
  end
end

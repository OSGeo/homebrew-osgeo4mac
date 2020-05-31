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

class OsgeoProjAT5 < Formula
  desc "Cartographic Projections Library"
  homepage "https://proj4.org/"
  url "https://github.com/OSGeo/proj.4/archive/5.2.0.tar.gz"
  sha256 "d784d51a8e56282123eb5918a2c685ed7da5097595afcacf5fa0246337a44361"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "623b42fc026ca183a93ecc14e7db9ecc1cf30a729e15cad255d025268088d5d7" => :mojave
    sha256 "623b42fc026ca183a93ecc14e7db9ecc1cf30a729e15cad255d025268088d5d7" => :high_sierra
    sha256 "bd9c8607cc813b32b7c956b349ff1235519323deb710fb0d8a1232eab83b6d6b" => :sierra
  end

  # revision 1

  head "https://github.com/OSGeo/proj.4.git", :branch => "master"

  keg_only :versioned_formula
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

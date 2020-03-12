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
  homepage "https://proj.org/"
  url "https://github.com/OSGeo/PROJ/releases/download/7.0.0/proj-7.0.0.tar.gz"
  sha256 "ee0e14c1bd2f9429b1a28999240304c0342ed739ebaea3d4ff44c585b1097be8"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "df22aae62d205aab3dd7afeb17111bcd3934aec98b306b69ef622a3bc70bf9c7" => :catalina
    sha256 "df22aae62d205aab3dd7afeb17111bcd3934aec98b306b69ef622a3bc70bf9c7" => :mojave
    sha256 "df22aae62d205aab3dd7afeb17111bcd3934aec98b306b69ef622a3bc70bf9c7" => :high_sierra
  end

  # revision 1

  # keg_only "proj is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  head do
    url "https://github.com/OSGeo/PROJ.git", :branch => "master"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build

  conflicts_with "blast", :because => "both install a `libproj.a` library"

  skip_clean :la

  # The datum grid files are required to support datum shifting
  resource "datumgrid" do
    url "https://download.osgeo.org/proj/proj-datumgrid-1.8.zip"
    sha256 "b9838ae7e5f27ee732fb0bfed618f85b36e8bb56d7afb287d506338e9f33861e"
  end

  def install
    (buildpath/"nad").install resource("datumgrid")

    system "./autogen.sh" if build.head?
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

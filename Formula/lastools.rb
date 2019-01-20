class Lastools < Formula
  desc "Efficient tools for LiDAR processing. Contains LASlib, a C++ programming API for reading / writing LIDAR data stored in standard LAS format"
  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any_skip_relocation
    sha256 "323cb55abbc4494c3d9c08ce12610caf0d8dbd4a74f9d9dfb02d64a3955ef476" => :mojave
    sha256 "323cb55abbc4494c3d9c08ce12610caf0d8dbd4a74f9d9dfb02d64a3955ef476" => :high_sierra
    sha256 "323cb55abbc4494c3d9c08ce12610caf0d8dbd4a74f9d9dfb02d64a3955ef476" => :sierra
  end

  homepage "https://rapidlasso.com/lastools" # http://lastools.org
  # url "http://lastools.org/download/LAStools.zip" # wine
  # sha256 "2d7a7b6a232c953dd73505e25c33f2cb6b7765342eb2522e9b0dc8bed62d0890"
  url "https://github.com/LAStools/LAStools.git",
    :branch => "master",
    :commit => "e2a8973ac27432c6e5d09bb3aadf2e1a5c797c9c"
  version "19.01.14"

  # revision 1

  head "https://github.com/LAStools/LAStools.git", :branch => "master"

  option "with-wine", "Use Wine to have more support"

  depends_on "cmake" => :build

  if build.with? "wine"
    depends_on "wine"
    depends_on :x11
  end

  def install
    mkdir "build" do
       system "cmake", "..", *std_cmake_args
       system "make", "install"
     end

     ln_s "#{bin}/las2las64", "#{bin}/las2las"
     ln_s "#{bin}/las2txt64", "#{bin}/las2txt"
     ln_s "#{bin}/lasdiff64", "#{bin}/lasdiff"
     ln_s "#{bin}/lasindex64", "#{bin}/lasindex"
     ln_s "#{bin}/lasinfo64", "#{bin}/lasinfo"
     ln_s "#{bin}/lasmerge64", "#{bin}/lasmerge"
     ln_s "#{bin}/lasprecision64", "#{bin}/lasprecision"
     ln_s "#{bin}/laszip64", "#{bin}/laszip"
     ln_s "#{bin}/txt2las64", "#{bin}/txt2las"

     # Pkg-Config file
     mkdir "#{lib}/pkgconfig"
     File.open("#{lib}/pkgconfig/laslib.pc", "w") { |file|
       file << "Name: laslib\n"
       file << "Description: C++ programming API for reading / writing LIDAR data\n"
       file << "Version: #{version}\n"
       file << "Libs: -L\${libdir} -llas\n"
       file << "Cflags: -I${includedir}\n"
       # file << "Requires:"
     }
  end

  def caveats
    if build.with? "wine"
      <<~EOS
        \n1 - \e[32mDownload and unzip LASTools. Remember where you unzipped it.\e[0m\n

        2 - \e[32mYou’re almost done. Start QGIS. Select Processing/Options.\e[0m\n
            \e[32mIn the Providers section scroll to “LASTools”. Fill out the blanks:\e[0m\n

            \033[31mLASTools folder:\e[0m LASTools directory\n

            \033[31mWine Folder:\e[0m #{HOMEBREW_PREFIX}/bin\n

          https://rapidlasso.com/2014/10/04/using-lastools-on-mac-os-x-with-wine/\n
          https://rapidlasso.com/2013/09/29/how-to-install-lastools-toolbox-in-qgis/\n
          http://gis.ubc.ca/2018/02/installing-lastools-for-lidar-data-in-qgis-for-mac/\n
      EOS
    else
      <<~EOS

      You can use the \e[32m--with-wine\e[0m version for more support.\n

      EOS
    end
  end

  test do
    # TODO
  end
end

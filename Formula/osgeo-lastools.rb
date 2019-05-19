class OsgeoLastools < Formula
  desc "Efficient tools for LiDAR processing. Contains LASlib, a C++ programming API for reading / writing LIDAR data stored in standard LAS format"
  homepage "https://rapidlasso.com/lastools"
  url "https://github.com/LAStools/LAStools/archive/25fe552719970baf15b5c1b233174cc70190eb67.tar.gz"
  sha256 "1718456d7a8d223877498d4fcee6f7b2dd9b1ce203c9fb5ace5f33088c478d1f"
  version "19.05.10"

  # evision 1

  head "https://github.com/LAStools/LAStools.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    rebuild 1
    sha256 "d716dda8ec8ede2cf07517190456e6e3f5407d7ff5e5dbf190e6b7b310eaf1a2" => :mojave
    sha256 "d716dda8ec8ede2cf07517190456e6e3f5407d7ff5e5dbf190e6b7b310eaf1a2" => :high_sierra
    sha256 "d6c319e04e9c03e3ce7dfaf110e187164e8f6398c82dd71f63ed892792328a19" => :sierra
  end

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
     }
  end

  def caveats
    if build.with? "wine"
      <<~EOS
        \n1 - Download \e[32mhttp://lastools.org/download/LAStools.zip\e[0m and unzip LASTools.\n
            Remember where you unzipped it.\n

        2 - Start QGIS. Select \e[32mProcessing/Options.\e[0m\n
            In the Providers section scroll to “LASTools”. Fill out the blanks:\n

            \033[31mLASTools folder:\e[0m \e[32mLASTools directory\e[0m (unzipped)\n
            \033[31mWine Folder:\e[0m \e[32m#{Formula["wine"].opt_bin}\e[0m\n

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

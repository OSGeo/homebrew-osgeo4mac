class Lastools < Formula
  desc "Efficient tools for LiDAR processing. Contains LASlib, a C++ programming API for reading / writing LIDAR data stored in standard LAS format"
  homepage "https://rapidlasso.com/lastools"
  url "https://github.com/LAStools/LAStools.git",
    :branch => "master",
    :commit => "18471441333cc84aa9f7a8c0ae6537286714f909"
  version "19.01.27"

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
        \n1 - Download \e[32mhttp://lastools.org/download/LAStools.zip\e[0m and unzip LASTools.\n
            Remember where you unzipped it.\n

        2 - Start QGIS. Select \e[32mProcessing/Options.\e[0m\n
            In the Providers section scroll to “LASTools”. Fill out the blanks:\n

            \033[31mLASTools folder:\e[0m \e[32mLASTools directory\e[0m (unzipped)\n
            \033[31mWine Folder:\e[0m \e[32m#{Formula["wine"].opt_bin}\e[0m\n

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

require File.expand_path("../../Strategies/cache-download", Pathname.new(__FILE__).realpath)

class OsgeoMrsidSdk < Formula
  desc "MrSID format decoder libs for MG4 (raster and LiDAR), MG3, MG2, JP2"
  homepage "https://www.lizardtech.com/developer/"
  url "file://#{HOMEBREW_CACHE}/MrSID_DSDK-9.5.1.4427-darwin14.universal.clang60.tar.gz",
      :using => CacheDownloadStrategy
  version "9.5.1.4427"
  sha256 "286843f4a22845835a06626327eed67216e403a54e17d8b10a675663d41b9829"

  revision 2

  option "with-bindings", "Include Lidar Python and Ruby bindings"
  option "with-docs", "Intall documentation and examples for SDKs"

  # this is an odd one: only needs the share/gdal components
  depends_on "osgeo-gdal" => :build

  def install
    # first strip unnecessary installs
    rm_r "Raster_DSDK/3rd-party" # already part of gdal install
    if build.without? "docs"
      rm_r "examples"
      cd "Lidar_DSDK" do
        %w[doc examples].each { |f| rm_r f }
      end
      cd "Raster_DSDK" do
        %w[doc examples].each { |f| rm_r f }
      end
    end
    rm_r "Lidar_DSDK/contributions" if build.without? "bindings"

    prefix.install Dir["*"]
    lidar_dsdk = prefix/"Lidar_DSDK"
    raster_dsdk = prefix/"Raster_DSDK"
    libtbb_old_name = "@rpath/libtbb.dylib"
    libtbb_new_name = opt_libexec/"libtbb.dylib"
    # vendor to libexec possibly version-specific common supporting libs
    liblas_old_name = "/data/builds/buildbot/darwin14/darwin14/build/"\
                      "xt_lib_lastools/lib/darwin14.universal.clang60/"\
                      "Release/liblaslib.dylib"
    liblas_new_name = opt_libexec/"liblaslib.dylib"
    libgeos_c_old_name = "@rpath/libgeos_c.1.dylib"
    libgeos_c_new_name = opt_libexec/"libgeos_c.1.dylib"
    libgeos_old_name = "@rpath/libgeos.2.dylib"
    libgeos_new_name = opt_libexec/"libgeos.2.dylib"

    # install binary executables
    [lidar_dsdk, raster_dsdk].each { |f| bin.install Dir[f/"bin/*"] }

    # install headers
    include.install lidar_dsdk/"include/lidar"
    # Raster into subdirectory (some headers are too commonly named)
    (include/"mrsid").install Dir[raster_dsdk/"include/*"]

    # update libs
    cd lidar_dsdk/"lib" do
      # reset vendored lib ids
      set_install_name("liblaslib.dylib", opt_libexec)

      # reset install lib ids
      set_install_name("liblti_lidar_dsdk.1.dylib", opt_lib)

      # reset install lib names
      install_change("liblti_lidar_dsdk.1.dylib",
                     libtbb_old_name,
                     libtbb_new_name)

      # install vendored; libtbb.dylib installed with raster libs
      libexec.install "liblaslib.dylib"

      # install SDK lib
      lib.install Dir["liblti*"]
    end
    cd raster_dsdk/"lib" do
      # reset vendored lib ids
      %w[libgeos_c.1.dylib libgeos.2.dylib libtbb.dylib].each do |f|
        set_install_name(f, opt_libexec)
      end

      # reset install lib ids
      set_install_name("libltidsdk.dylib", opt_lib)

      # reset vendored lib names
      install_change("libgeos_c.1.dylib",
                     libgeos_old_name,
                     libgeos_new_name)

      # reset install lib names
      install_change("libltidsdk.dylib",
                     libtbb_old_name,
                     libtbb_new_name)

      # install vendored
      libexec.install "libtbb.dylib", Dir["libgeos*"]

      # install SDK lib
      lib.install Dir["liblti*"]
    end

    # cleanup
    rm_r lidar_dsdk/"lib"
    rm_r raster_dsdk/"lib"

    # update executables
    cd bin do
      Dir["*"].each do |exe|
        install_change(exe,
                       libtbb_old_name,
                       libtbb_new_name)
        install_change(exe,
                       libgeos_c_old_name,
                       libgeos_c_new_name)
        install_change(exe,
                       liblas_old_name,
                       liblas_new_name)
      end
    end
  end

  def install_change(dylib, old, new)
    if MachO::Tools.dylibs(dylib).include?(old)
      puts "install_change: from #{old} to #{new} in #{dylib}" if ARGV.debug?
      MachO::Tools.change_install_name(dylib.to_s, old.to_s, new.to_s, :strict => false)
    elsif ARGV.debug?
      puts "install_change: #{old} name not found in #{dylib}"
    end
  end

  def set_install_name(dylib, dir)
    puts "set_install_name to #{dir}/#{dylib}" if ARGV.debug?
    MachO::Tools.change_dylib_id(dylib.to_s, "#{dir}/#{dylib}", :strict => false)
  end

  def caveats; <<~EOS
        To build software with the Raster and LiDAR SDKs, add to the following
        environment variables to find the headers:

          CPPFLAGS: -I#{opt_prefix}/include/mrsid
          CPPFLAGS: -I#{opt_prefix}/include/lidar
    EOS
  end

  test do
    #
  end
end

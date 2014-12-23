require File.expand_path("../../Strategies/cache-download", Pathname.new(__FILE__).realpath)

class MrsidSdk < Formula
  homepage "https://www.lizardtech.com/developer/"
  url "file://#{HOMEBREW_CACHE}/MrSID_DSDK-9.0.0.3864-darwin12.universal.gccA42.tar.gz",
      :using => CacheDownloadStrategy
  sha1 "8a693cc71dbb8638f34e35efb8086f29b08fa764"
  version "9.0.0.3864"

  option "with-bindings", "Build with Lidar Python and Ruby bindings"
  option "with-docs", "Intall documentation and examples for SDKs"

  # this is an odd one: only needs the share/gdal components
  depends_on "gdal" => :build

  def install
    # first strip unnecessary installs
    rm_r "Raster_DSDK/3rd-party" # already part of gdal install
    if build.without? "docs"
      rm_r "examples"
      cd "Lidar_DSDK" do
        %W[doc examples].each {|f| rm_r f}
      end
      cd "Raster_DSDK" do
        %W[doc examples].each {|f| rm_r f}
      end
    end
    rm_r "Lidar_DSDK/contributions" if build.without? "bindings"

    prefix.install Dir["*"]
    lidar_dsdk = prefix/"Lidar_DSDK"
    raster_dsdk = prefix/"Raster_DSDK"
    raster_opt_dsdk = opt_prefix/"Raster_DSDK"

    # link to binary executables
    [lidar_dsdk, raster_dsdk].each {|f| bin.install Dir[f/"bin/*"]}

    # install headers
    include.install lidar_dsdk/"include/lidar"
    # Raster into subdirectory (some headers are too commonly named)
    (include/"mrsid").install Dir[raster_dsdk/"include/*"]

    # update libs
    cd lidar_dsdk/"lib" do
      # convert base version to symlink again
      rm "liblti_lidar_dsdk.dylib"
      ln_s "liblti_lidar_dsdk.1.dylib", "liblti_lidar_dsdk.dylib"
    end
    cd raster_dsdk/"lib" do
      # convert base versions to symlinks again
      rm "libltidsdk.dylib"
      ln_s "libltidsdk.9.dylib", "libltidsdk.dylib"
      %W[libgeos_c.1.dylib libgeos_c.dylib].each do |f|
        rm f
        ln_s "libgeos_c.1.1.1.dylib", f
      end
      %W[libgeos.2.dylib libgeos.dylib].each do |f|
        rm f
        ln_s "libgeos.2.2.3.dylib", f
      end

      # reset install ids
      %W[libgeos_c.1.dylib libgeos.2.dylib libtbb.dylib].each do |f|
        quiet_system "install_name_tool", "-id",
                     "#{raster_opt_dsdk}/lib/#{f}", f
      end

      # reset install lib paths
      install_change("libltidsdk.dylib",
                   "libtbb.dylib",
                   "#{raster_opt_dsdk}/lib/libtbb.dylib")
      install_change("libltidsdk.dylib",
                   libgeos_c_old_path,
                   "#{raster_opt_dsdk}/lib/libgeos_c.1.dylib")
      install_change("libgeos_c.dylib",
                   libgeos_old_path,
                   "#{raster_opt_dsdk}/lib/libgeos.2.dylib")
    end

    # link SDK libs, which will be fixed up by Homebrew
    [lidar_dsdk, raster_dsdk].each {|f| lib.install Dir[f/"lib/liblti*"]}

    # update executables
    cd bin do
      Dir["mrsid*"].each do |exe|
        install_change(exe,
                     "libtbb.dylib",
                     "#{raster_opt_dsdk}/lib/libtbb.dylib")
        install_change(exe,
                     libgeos_c_old_path,
                     "#{raster_opt_dsdk}/lib/libgeos_c.1.dylib")
      end
    end
  end

  def install_change(dylib, old, new)
    quiet_system "install_name_tool", "-change", old, new, dylib
  end

  def libgeos_c_old_path
    "/data/builds/Bob/darwin12.universal.gccA42__default/xt_lib_geos/"\
      "darwin12.universal.gccA42/Release/src/geos-2.2.3/../../../../dist/"\
      "darwin12.universal.gccA42/Release/lib/libgeos_c.1.dylib"
  end

  def libgeos_old_path
    "/data/builds/Bob/darwin12.universal.gccA42__default/xt_lib_geos/"\
      "darwin12.universal.gccA42/Release/src/geos-2.2.3/../../../../dist/"\
      "darwin12.universal.gccA42/Release/lib/libgeos.2.dylib"
  end

  def caveats; <<-EOS.undent
        To build software with the Raster SDK, add to the following environment
        variable to find the headers:

          CPPFLAGS: -I#{opt_prefix}/include/mrsid

        ============================== IMPORTANT ==================================
        If linking with other software built on 10.9+, clang links to libc++, whereas
        MrSID libs/binaries link to libstdc++. This may lead to build failures or
        issues during usage, including crashes.

    EOS
  end
end

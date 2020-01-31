class OsgeoGdalSosi < Formula
  desc "GDAL/OGR 2.x plugin for SOSI driver"
  homepage "https://trac.osgeo.org/gdal/wiki/SOSI"
  url "https://github.com/OSGeo/gdal/releases/download/v3.0.4/gdal-3.0.4.tar.gz"
  sha256 "fc15d2b9107b250305a1e0bd8421dd9ec1ba7ac73421e4509267052995af5e83"

  # revision 1

  head "https://github.com/OSGeo/gdal.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "b6ec7222fee7f54af9fe509183ee96dc093b1de65719d2794eb7cc03d88ec9fa" => :mojave
    sha256 "b6ec7222fee7f54af9fe509183ee96dc093b1de65719d2794eb7cc03d88ec9fa" => :high_sierra
    sha256 "30dfd513e92c7159220e0bedfd061da89618c84d16b78bfafea8032be0581971" => :sierra
  end

  depends_on "osgeo-fyba"
  depends_on "osgeo-gdal"

  def gdal_majmin_ver
    gdal_ver_list = Formula["osgeo-gdal"].version.to_s.split(".")
    "#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def gdal_plugins_subdirectory
    "gdalplugins/#{gdal_majmin_ver}"
  end

  def install
    ENV.cxx11
    fyba_opt = Formula["osgeo-fyba"].opt_prefix

    gdal_plugins = lib/gdal_plugins_subdirectory
    gdal_plugins.mkpath

    # cxx flags
    args = %W[-DLINUX -DUNIX -Iport -Igcore -Iogr
              -Iogr/ogrsf_frmts -Iogr/ogrsf_frmts/generic
              -Iogr/ogrsf_frmts/sosi -I#{fyba_opt}/include/fyba]

    # source files
    Dir["ogr/ogrsf_frmts/sosi/ogrsosi*.c*"].each do |src|
      args.concat %W[#{src}]
    end

    # plugin dylib
    dylib_name = "ogr_SOSI.dylib"
    args.concat %W[
      -dynamiclib
      -install_name #{opt_lib}/#{gdal_plugins_subdirectory}/#{dylib_name}
      -current_version #{version}
      -compatibility_version #{gdal_majmin_ver}.0
      -o #{gdal_plugins}/#{dylib_name}
      -undefined dynamic_lookup
    ]

    # ld flags
    args.concat %W[-L#{fyba_opt}/lib -lfyba -lfygm -lfyut]

    # build and install shared plugin
    system ENV.cxx, *args
  end

  def caveats; <<~EOS
      This formula provides a plugin that allows GDAL or OGR to access geospatial
      data stored in its format. In order to use the shared plugin, you may need
      to set the following enviroment variable:

        export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins
    EOS
  end

  test do
    ENV["GDAL_DRIVER_PATH"] = "#{HOMEBREW_PREFIX}/lib/gdalplugins"
    gdal_opt_bin = Formula["osgeo-gdal"].opt_bin
    out = shell_output("#{gdal_opt_bin}/ogrinfo --formats")
    assert_match "SOSI -vector- (ro)", out
  end
end

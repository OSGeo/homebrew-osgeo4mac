class OsgeoGdalMysql < Formula
  desc "GDAL/OGR 2 plugin for MySQL driver"
  homepage "http://www.gdal.org/drv_mysql.html"
  url "https://github.com/OSGeo/gdal/releases/download/v3.0.4/gdal-3.0.4.tar.gz"
  sha256 "fc15d2b9107b250305a1e0bd8421dd9ec1ba7ac73421e4509267052995af5e83"

  # revision 1

  head "https://github.com/OSGeo/gdal.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    rebuild 1
    sha256 "a4c39f772b7ffafcdec5eed0c39922ed96e8af72c2ecab5d1bedf749cb7021b2" => :mojave
    sha256 "a4c39f772b7ffafcdec5eed0c39922ed96e8af72c2ecab5d1bedf749cb7021b2" => :high_sierra
    sha256 "a07cb1183e909e96fdac52b1a0d16cf38db3f3d6775c07ae521ad6315776aa43" => :sierra
  end

  depends_on "mysql" => :build # adds openssl
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
    mysql = Formula["mysql"]

    gdal_plugins = lib/gdal_plugins_subdirectory
    gdal_plugins.mkpath

    # cxx flags
    args = %W[-Iport -Igcore -Iogr -Iogr/ogrsf_frmts -Iogr/ogrsf_frmts/generic
              -Iogr/ogrsf_frmts/mysql -I#{mysql.opt_include}/mysql]

    # source files
    Dir["ogr/ogrsf_frmts/mysql/*.c*"].each do |src|
      args.concat %W[#{src}]
    end

    # plugin dylib
    dylib_name = "ogr_MySQL.dylib"
    args.concat %W[
      -dynamiclib
      -install_name #{opt_lib}/#{gdal_plugins_subdirectory}/#{dylib_name}
      -current_version #{version}
      -compatibility_version #{gdal_majmin_ver}.0
      -o #{gdal_plugins}/#{dylib_name}
      -undefined dynamic_lookup
    ]

    # ld flags
    args.concat %W[
      #{mysql.opt_lib}/libmysqlclient.a
      -L#{Formula["openssl"].opt_lib}
      -lssl
      -lcrypto
    ]

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
    assert_match "MySQL -vector- (rw+)", out
  end
end

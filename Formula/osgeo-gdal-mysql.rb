class OsgeoGdalMysql < Formula
  desc "GDAL/OGR 2 plugin for MySQL driver"
  homepage "http://www.gdal.org/drv_mysql.html"
  url "https://download.osgeo.org/gdal/2.4.1/gdal-2.4.1.tar.gz"
  sha256 "f1a11d1982205b9e4cc10e16f016a5559bfc9fa9a9ea69015e99ccd6a738ea4c"

  # revision 1

  head "https://github.com/OSGeo/gdal.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    rebuild 1
    sha256 "7f5b6728f2b67b4e29c006d8fa0a1cbf1ffa7664d470acf66033a03e6301763c" => :mojave
    sha256 "7f5b6728f2b67b4e29c006d8fa0a1cbf1ffa7664d470acf66033a03e6301763c" => :high_sierra
    sha256 "939bc990f00b9fcb22c0ca3aa71038fd54bd1cfcb6769c41da12d3e33cb61e0d" => :sierra
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

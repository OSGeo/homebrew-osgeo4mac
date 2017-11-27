class Gdal2Mysql < Formula
  desc "GDAL/OGR 2 plugin for MySQL driver"
  homepage "http://www.gdal.org/drv_mysql.html"
  url "http://download.osgeo.org/gdal/2.2.3/gdal-2.2.3.tar.gz"
  sha256 "52f01bda8968643633016769607e6082a8ba1c746fadc2c1abe12cf7dc8f61dd"

  # bottle do
  #   root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
  #   sha256 "826b07db55496e75732db8edfa65524a4edffd446d8dc71f31bd9daaf5721169" => :sierra
  #   sha256 "826b07db55496e75732db8edfa65524a4edffd446d8dc71f31bd9daaf5721169" => :high_sierra
  # end

  depends_on "mysql" => :build # adds openssl
  depends_on "gdal2"

  def gdal_majmin_ver
    gdal_ver_list = Formula["gdal2"].version.to_s.split(".")
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

  def caveats; <<-EOS.undent
      This formula provides a plugin that allows GDAL or OGR to access geospatial
      data stored in its format. In order to use the shared plugin, you may need
      to set the following enviroment variable:

        export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins
    EOS
  end

  test do
    ENV["GDAL_DRIVER_PATH"] = "#{HOMEBREW_PREFIX}/lib/gdalplugins"
    gdal_opt_bin = Formula["gdal2"].opt_bin
    out = shell_output("#{gdal_opt_bin}/ogrinfo --formats")
    assert_match "MySQL -vector- (rw+)", out
  end
end

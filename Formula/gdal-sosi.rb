class GdalSosi < Formula
  homepage "http://trac.osgeo.org/gdal/wiki/SOSI"
  url "http://download.osgeo.org/gdal/1.11.0/gdal-1.11.0.tar.gz"
  sha256 "989db33ff411e2c888348e71edec5ad06c74ed68781ebfbc4e85179b9d65aafe"

  depends_on "fyba"
  depends_on "gdal"

  def install
    fyba_opt = Formula["fyba"].opt_prefix
    (lib/"gdalplugins").mkpath

    # cxx flags
    args = %W[-DLINUX -DUNIX -Iport -Igcore -Iogr
              -Iogr/ogrsf_frmts -Iogr/ogrsf_frmts/generic
              -Iogr/ogrsf_frmts/sosi -I#{fyba_opt}/include/fyba]

    # source files
    Dir['ogr/ogrsf_frmts/sosi/ogrsosi*.c*'].each do |src|
      args.concat %W[#{src}]
    end

    # plugin dylib
    args.concat %W[
      -dynamiclib
      -install_name #{HOMEBREW_PREFIX}/lib/gdalplugins/ogr_SOSI.dylib
      -current_version #{version}
      -compatibility_version #{version}
      -o #{lib}/gdalplugins/ogr_SOSI.dylib
      -undefined dynamic_lookup
    ]

    # ld flags
    args.concat %W[-L#{fyba_opt}/lib -lfyba -lfygm -lfyut]

    # build and install shared plugin
    system ENV.cxx, *args

  end

  def caveats; <<~EOS
    This formula provides a plugin that allows GDAL or OGR to access geospatial
    data stored in its format. In order to use the shared plugin, you will need
    to set the following enviroment variable:

      export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins

    EOS
  end
end

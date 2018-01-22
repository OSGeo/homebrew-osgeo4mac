class GdalOracle < Formula
  homepage "http://www.gdal.org/ogr/drv_oci.html"
  url 'http://download.osgeo.org/gdal/1.11.0/gdal-1.11.0.tar.gz'
  sha256 '989db33ff411e2c888348e71edec5ad06c74ed68781ebfbc4e85179b9d65aafe'

  depends_on "oracle-client-sdk"
  depends_on "gdal"

  def install
    oracle_opt = Formula['oracle-client-sdk'].opt_prefix
    (lib/"gdalplugins").mkpath
    args = []

    # source files
    args.concat %W[ogr/ogrsf_frmts/oci/oci_utils.cpp]
    Dir["ogr/ogrsf_frmts/oci/ogr*.c*"].each { |src| args.concat %W[#{src}] }

    # plugin dylib
    # TODO: can the compatibility_version be 1.10.0?
    args.concat %W[
      -dynamiclib
      -install_name #{HOMEBREW_PREFIX}/lib/gdalplugins/ogr_OCI.dylib
      -current_version #{version}
      -compatibility_version #{version}
      -o #{lib}/gdalplugins/ogr_OCI.dylib
      -undefined dynamic_lookup
    ]

    # cxx flags
    args.concat %W[-Iport -Igcore -Iogr -Iogr/ogrsf_frmts
                   -Iogr/ogrsf_frmts/oci -I#{oracle_opt}/sdk/include]

    # ld flags
    args.concat %W[-L#{oracle_opt}/lib -lclntsh]

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

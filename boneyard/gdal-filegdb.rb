require 'formula'

class GdalFilegdb < Formula
  homepage 'http://www.gdal.org/ogr/drv_filegdb.html'
  url 'http://download.osgeo.org/gdal/1.11.0/gdal-1.11.0.tar.gz'
  sha256 '989db33ff411e2c888348e71edec5ad06c74ed68781ebfbc4e85179b9d65aafe'

  depends_on "filegdb-api"
  depends_on 'gdal'

  def install
    filegdb_opt = Formula['filegdb-api'].opt_prefix
    (lib/'gdalplugins').mkpath

    # cxx flags
    args = %W[-Iport -Igcore -Iogr -Iogr/ogrsf_frmts -Iogr/ogrsf_frmts/generic
               -Iogr/ogrsf_frmts/filegdb -I#{filegdb_opt}/include/filegdb]

    # source files
    Dir['ogr/ogrsf_frmts/filegdb/*.c*'].each do |src|
      args.concat %W[#{src}]
    end

    # plugin dylib
    args.concat %W[
      -dynamiclib
      -install_name #{HOMEBREW_PREFIX}/lib/gdalplugins/ogr_FileGDB.dylib
      -current_version #{version}
      -compatibility_version #{version}
      -o #{lib}/gdalplugins/ogr_FileGDB.dylib
      -undefined dynamic_lookup
    ]

    # ld flags
    args.concat %W[-L#{filegdb_opt}/lib -lFileGDBAPI]

    # build and install shared plugin
    if ENV.compiler == :clang && MacOS.version >= :mavericks
      # fixes to make plugin work with gdal possibly built against libc++
      # NOTE: works, but I don't know if it is a sane fix
      # see: http://forums.arcgis.com/threads/95958-OS-X-Mavericks
      #      https://gist.github.com/jctull/f4d620cd5f1560577d17
      # TODO: needs removed as soon as ESRI updates filegdb binaries for libc++
      cxxstdlib_check :skip
      args.unshift "-mmacosx-version-min=10.8" # better than -stdlib=libstdc++ ?
    end
    system ENV.cxx, *args

  end

  def caveats; <<~EOS
    This formula provides a plugin that allows GDAL or OGR to access geospatial
    data stored in its format. In order to use the shared plugin, you will need
    to set the following enviroment variable:

      export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins

    ============================== IMPORTANT ==============================
    If compiled using clang (default) on 10.9+ this plugin was built against
    libstdc++ (like filegdb binaries), which may load into your GDAL, but
    possibly be incompatible. Please report any issues to:
        https://github.com/osgeo/homebrew-osgeo4mac/issues

    EOS
  end
end

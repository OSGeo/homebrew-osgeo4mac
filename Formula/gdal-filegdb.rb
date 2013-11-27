require 'formula'

class GdalThirdParty < Requirement
  fatal true

  satisfy do
    envar = ENV['GDAL_THIRD_PARTY']
    envar && File.exists?(envar)
  end

  def message; <<-EOS.undent
    Define GDAL_THIRD_PARTY environment variable that points to a directory,
    which contains the unaltered download archive of the third-party library:

      `export GDAL_THIRD_PARTY=path/to/gdal/third-party/directory`

    EOS
  end
end

class GdalFilegdb < Formula
  homepage 'http://www.gdal.org/ogr/drv_filegdb.html'
  url 'http://download.osgeo.org/gdal/1.10.1/gdal-1.10.1.tar.gz'
  sha1 'b4df76e2c0854625d2bedce70cc1eaf4205594ae'

  option 'with-docs', 'Intall third-party library documentation and examples'

  depends_on GdalThirdParty
  depends_on 'gdal'

  resource 'filegdb' do
    url "file://#{ENV['GDAL_THIRD_PARTY']}/FileGDB_API_1_3-64.zip"
    sha1 '95ba7e3da555508c8be10b8dbb6ad88a71b03f49'
    version '1.3'
  end

  def install

    # stage third-party libs in prefix
    fgdb = prefix/'filegdb'
    fgdb.mkpath
    fgdb_opt = opt_prefix/'filegdb'

    resource('filegdb').stage do
      docs = %W[doc samples xmlResources]
      Dir['*'].each do |rsc|
        fgdb.install rsc unless build.without? 'docs' and docs.include? rsc
      end
    end

    # update third-party libs
    cd fgdb/'lib' do
      system "install_name_tool", "-id",
                                  "#{fgdb_opt}/lib/libFileGDBAPI.dylib",
                                  "libFileGDBAPI.dylib"
      system "install_name_tool", "-id",
                                  "#{fgdb_opt}/lib/libfgdbunixrtl.dylib",
                                  "libfgdbunixrtl.dylib"
      system "install_name_tool", "-change",
                                  "@rpath/libfgdbunixrtl.dylib",
                                  "#{fgdb_opt}/lib/libfgdbunixrtl.dylib",
                                  "libFileGDBAPI.dylib"
    end

    gdal = Formula.factory('gdal')
    (lib/'gdalplugins').mkpath

    # cxx flags
    args = %W[-Iport -Igcore -Iogr -Iogr/ogrsf_frmts
               -Iogr/ogrsf_frmts/filegdb -I#{fgdb}/include]

    # source files
    Dir["ogr/ogrsf_frmts/filegdb/*.c*"].each do |src|
      args.concat %W[#{src}]
    end

    # plugin dylib
    # TODO: can the compatibility_version be 1.10.0?
    args.concat %W[
      -dynamiclib
      -install_name #{HOMEBREW_PREFIX}/lib/gdalplugins/ogr_FileGDB.dylib
      -current_version #{version}
      -compatibility_version #{version}
      -o #{lib}/gdalplugins/ogr_FileGDB.dylib
      -undefined dynamic_lookup
    ]

    # ld flags
    args.concat %W[-L#{gdal.lib} -lgdal -L#{fgdb}/lib -lFileGDBAPI]

    # build and install shared plugin
    system ENV.cxx, *args

  end

  def caveats; <<-EOS.undent
    This formula provides a plugin that allows GDAL or OGR to access geospatial
    data stored in its format. In order to use the shared plugin, you will need
    to set the following enviroment variable:

      export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins

    The FileGDB libraries are `keg-only`. To build software that uses them, add
    to the following environment variables:

      CPPFLAGS: -I#{opt_prefix}/filegdb/include
      LDFLAGS:  -L#{opt_prefix}/filegdb/lib

    EOS
  end
end

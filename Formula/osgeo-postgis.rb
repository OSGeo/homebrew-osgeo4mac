class OsgeoPostgis < Formula
  desc "Adds support for geographic objects to PostgreSQL"
  homepage "https://postgis.net/"
  url "https://github.com/postgis/postgis/archive/2.5.2.tar.gz"
  sha256 "225aeaece00a1a6a9af15526af81bef2af27f4c198de820af1367a792ee1d1a9"

  # revision 1

  head "https://github.com/postgis/postgis.git", :branch => "master"

  option "with-gui", "Build shp2pgsql-gui in addition to command line tools"
  option "with-html-docs", "Generate multi-file HTML documentation"
  option "with-api-docs", "Generate developer API documentation (long process)"
  option "with-postgresql10", "Build with PostgreSQL 10 client"

  # if build.head?
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  # end

  depends_on "gpp" => :build
  depends_on "pkg-config" => :build
  depends_on "geos"
  depends_on "json-c" # for GeoJSON and raster handling
  depends_on "libiconv"
  depends_on "libxml2"
  depends_on "libxslt"
  depends_on "pcre"
  depends_on "proj"
  depends_on "sfcgal" # for advanced 2D/3D functions
  depends_on "protobuf-c" #  Geobuf and Mapbox Vector Tile support
  depends_on "osgeo-gdal" # for GeoJSON and raster handling

  if build.with?("postgresql10")
    depends_on "postgresql@10"
  else
    depends_on "postgresql"
  end

  depends_on "gtk+" # if build.with? "gui"

  if build.with? "html-docs"
    depends_on "imagemagick"
    depends_on "docbook-xsl" # docbook-xsl-nons
  end

  if build.with? "api-docs"
    depends_on "graphviz"
    depends_on "doxygen"
  end

  def install
    # Follow the PostgreSQL linked keg back to the active Postgres installation
    # as it is common for people to avoid upgrading Postgres.
    # postgres_realpath = Formula["postgresql"].opt_prefix.realpath

    ENV.append "CFLAGS", "-Diconv=libiconv -Diconv_open=libiconv_open -Diconv_close=libiconv_close"

    ENV.append "ICONV_LDFLAGS", "-L#{Formula["libiconv"].opt_lib} -liconv"

    ENV.deparallelize

    args = [
      "--with-projdir=#{Formula["proj"].opt_prefix}",
      "--with-json",
      "--with-jsondir=#{Formula["json-c"].opt_prefix}",
      "--with-raster",
      "--with-topology",
      "--datadir=${prefix}/share/${name}",
      "--with-address-standardizer",
      "--with-gdalconfig=#{Formula["osgeo-gdal"].opt_bin}/gdal-config",
      # Unfortunately, NLS support causes all kinds of headaches because
      # PostGIS gets all of its compiler flags from the PGXS makefiles. This
      # makes it nigh impossible to tell the buildsystem where our keg-only
      # gettext installations are.
      "--disable-nls",
    ]

    if build.with?("postgresql10")
      args << "--with-pgconfig=#{Formula["postgresql@10"].opt_bin}/pg_config"
    else
      args << "--with-pgconfig=#{Formula["postgresql"].opt_bin}/pg_config"
    end

    args << "--with-xsldir=#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl" if build.with? "html-docs"

    args << "--with-gui" # if build.with? "gui"

    args << "--with-sfcgal=#{Formula["sfcgal"].opt_bin}/sfcgal-config"

    args << "--with-protobuf"
    args << "--with-protobufdir=#{Formula["protobuf-c"].opt_bin}"

    system "./autogen.sh"
    system "./configure", *args
    system "make"

    if build.with? "html-docs"
      cd "doc" do
        ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"
        system "make", "chunked-html"
        doc.install "html"
      end
    end

    if build.with? "api-docs"
      cd "doc" do
        system "make", "doxygen"
        doc.install "doxygen/html" => "api"
      end
    end

    # PostGIS includes the PGXS makefiles and so will install __everything__
    # into the Postgres keg instead of the PostGIS keg. Unfortunately, some
    # things have to be inside the Postgres keg in order to be function. So, we
    # install everything to a staging directory and manually move the pieces
    # into the appropriate prefixes.
    mkdir "stage"
    system "make", "install", "DESTDIR=#{buildpath}/stage"

    # Install PostGIS plugin libraries into the Postgres keg so that they can
    # be loaded and so PostGIS databases will continue to function even if
    # PostGIS is removed.
    # (postgres_realpath/"lib").install Dir["stage/**/*.so"]

    # Install extension scripts to the Postgres keg.
    # `CREATE EXTENSION postgis;` won't work if these are located elsewhere.
    # (postgres_realpath/"share/postgresql/extension").install Dir["stage/**/extension/*"]

    bin.install Dir["stage/**/bin/*"]
    lib.install Dir["stage/**/lib/*"]
    include.install Dir["stage/**/include/*"]
    (doc/"postgresql/extension").install Dir["stage/**/share/doc/postgresql/extension/*"]
    (share/"postgresql/extension").install Dir["stage/**/share/postgresql/extension/*"]
    # Stand-alone SQL files will be installed the share folder
    # (share/"postgis").install Dir["stage/**/contrib/postgis-2.1/*"]
    pkgshare.install Dir["stage/**/contrib/postgis-*/*"]
    (share/"postgis_topology").install Dir["stage/**/contrib/postgis_topology-*/*"]

    # Extension scripts
    bin.install %w[
      utils/create_undef.pl
      utils/postgis_proc_upgrade.pl
      utils/postgis_restore.pl
      utils/profile_intersects.pl
      utils/test_estimation.pl
      utils/test_geography_estimation.pl
      utils/test_geography_joinestimation.pl
      utils/test_joinestimation.pl
    ]

    man1.install Dir["doc/**/*.1"]
  end

  def caveats
    <<~EOS
      To create a spatially-enabled database, see the documentation:
        https://postgis.net/docs/manual-2.4/postgis_installation.html#create_new_db_extensions
      If you are currently using PostGIS 2.0+, you can go the soft upgrade path:
        ALTER EXTENSION postgis UPDATE TO "#{version}";
      Users of 1.5 and below will need to go the hard-upgrade path, see here:
        https://postgis.net/docs/manual-2.4/postgis_installation.html#upgrading

      PostGIS SQL scripts installed to:
        #{opt_pkgshare}
      PostGIS plugin libraries installed to:
        #{HOMEBREW_PREFIX}/lib
      PostGIS extension modules installed to:
        #{HOMEBREW_PREFIX}/share/postgresql/extension
    EOS
  end

  test do
    require "base64"
    (testpath/"brew.shp").write ::Base64.decode64 <<~EOS
      AAAnCgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAoOgDAAALAAAAAAAAAAAAAAAA
      AAAAAADwPwAAAAAAABBAAAAAAAAAFEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
      AAAAAAAAAAAAAAAAAAEAAAASCwAAAAAAAAAAAPA/AAAAAAAA8D8AAAAAAAAA
      AAAAAAAAAAAAAAAAAgAAABILAAAAAAAAAAAACEAAAAAAAADwPwAAAAAAAAAA
      AAAAAAAAAAAAAAADAAAAEgsAAAAAAAAAAAAQQAAAAAAAAAhAAAAAAAAAAAAA
      AAAAAAAAAAAAAAQAAAASCwAAAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAAAAA
      AAAAAAAAAAAABQAAABILAAAAAAAAAAAAAAAAAAAAAAAUQAAAAAAAACJAAAAA
      AAAAAEA=
    EOS
    (testpath/"brew.dbf").write ::Base64.decode64 <<~EOS
      A3IJGgUAAABhAFsAAAAAAAAAAAAAAAAAAAAAAAAAAABGSVJTVF9GTEQAAEMA
      AAAAMgAAAAAAAAAAAAAAAAAAAFNFQ09ORF9GTEQAQwAAAAAoAAAAAAAAAAAA
      AAAAAAAADSBGaXJzdCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
      ICAgICAgICAgICAgIFBvaW50ICAgICAgICAgICAgICAgICAgICAgICAgICAg
      ICAgICAgICAgU2Vjb25kICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
      ICAgICAgICAgICAgICBQb2ludCAgICAgICAgICAgICAgICAgICAgICAgICAg
      ICAgICAgICAgIFRoaXJkICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
      ICAgICAgICAgICAgICAgUG9pbnQgICAgICAgICAgICAgICAgICAgICAgICAg
      ICAgICAgICAgICBGb3VydGggICAgICAgICAgICAgICAgICAgICAgICAgICAg
      ICAgICAgICAgICAgICAgIFBvaW50ICAgICAgICAgICAgICAgICAgICAgICAg
      ICAgICAgICAgICAgQXBwZW5kZWQgICAgICAgICAgICAgICAgICAgICAgICAg
      ICAgICAgICAgICAgICAgICBQb2ludCAgICAgICAgICAgICAgICAgICAgICAg
      ICAgICAgICAgICAg
    EOS
    (testpath/"brew.shx").write ::Base64.decode64 <<~EOS
      AAAnCgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARugDAAALAAAAAAAAAAAAAAAA
      AAAAAADwPwAAAAAAABBAAAAAAAAAFEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
      AAAAAAAAAAAAAAAAADIAAAASAAAASAAAABIAAABeAAAAEgAAAHQAAAASAAAA
      igAAABI=
    EOS
    result = shell_output("#{bin}/shp2pgsql #{testpath}/brew.shp")
    assert_match /Point/, result
    assert_match /AddGeometryColumn/, result
  end
end

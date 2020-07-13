class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !osgeo_postgis_linked && !core_postgis_linked }

  def osgeo_postgis_linked
    Formula["osgeo-postgis"].linked_keg.exist?
  rescue
    return false
  end

  def core_postgis_linked
    Formula["postgis"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink osgeo-postgis\e[0m or remove with \e[32mbrew uninstall --ignore-dependencies osgeo-postgis\e[0m\n\n" if osgeo_postgis_linked
    s += "Unlink with \e[32mbrew unlink postgis\e[0m or remove with brew \e[32muninstall --ignore-dependencies postgis\e[0m\n\n" if core_postgis_linked
    s
  end
end

class OsgeoPostgisAT24 < Formula
  desc "Adds support for geographic objects to PostgreSQL"
  homepage "https://postgis.net/"
  url "https://github.com/postgis/postgis/archive/2.4.8.tar.gz"
  sha256 "d81f36abc4dc7235de65e4e58b00dee33d1ca14e9b70a3a2b888be90544b3cb5"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "d2e66dff4c2d875fa6c55bf02bcb6e0ebf60495c9388d27fd5c8ee7927da9e83" => :catalina
    sha256 "d2e66dff4c2d875fa6c55bf02bcb6e0ebf60495c9388d27fd5c8ee7927da9e83" => :mojave
    sha256 "d2e66dff4c2d875fa6c55bf02bcb6e0ebf60495c9388d27fd5c8ee7927da9e83" => :high_sierra
  end

  revision 1

  head "https://github.com/postgis/postgis.git", :branch => "svn-2.4"

  option "with-html-docs", "Generate multi-file HTML documentation"
  option "with-api-docs", "Generate developer API documentation (long process)"
  option "with-pg10", "Build with PostgreSQL 10 client"

  # keg_only :versioned_formula
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gpp" => :build
  depends_on "pkg-config" => :build
  depends_on "geos"
  depends_on "json-c" # for GeoJSON and raster handling
  depends_on "libiconv"
  depends_on "libxml2"
  depends_on "libxslt"
  depends_on "pcre"
  depends_on "osgeo-proj"
  depends_on "sfcgal" # for advanced 2D/3D functions
  depends_on "protobuf-c" #  Geobuf and Mapbox Vector Tile support
  depends_on "osgeo-gdal" # for GeoJSON and raster handling

  if build.with?("pg10")
    depends_on "osgeo-postgresql@10"
  else
    depends_on "osgeo-postgresql"
  end

  depends_on "gtk+" # for gui

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
    # postgres_realpath = Formula["osgeo-postgresql@10"].opt_prefix.realpath
    ENV.append "CFLAGS", "-Diconv=libiconv -Diconv_open=libiconv_open -Diconv_close=libiconv_close"
    ENV.append "LDFLAGS", "-L#{Formula["libiconv"].opt_lib} -liconv" # ICONV_LDFLAGS

    ENV.deparallelize

    args = [
      "--with-libiconv=#{Formula["libiconv"].opt_prefix}",
      "--with-xml2config=#{Formula["libxml2"].opt_bin}/xml2-config",
      "--with-geosconfig=#{Formula["geos"].opt_bin}/geos-config",
      "--with-sfcgal=#{Formula["sfcgal"].opt_bin}/sfcgal-config",
      "--with-projdir=#{Formula["osgeo-proj"].opt_prefix}",
      "--with-jsondir=#{Formula["json-c"].opt_prefix}",
      "--with-protobufdir=#{Formula["protobuf-c"].opt_prefix}",
      "--with-pcredir=#{Formula["pcre"].opt_prefix}",
      "--with-gdalconfig=#{Formula["osgeo-gdal"].opt_bin}/gdal-config",
      "--with-gui",
      "--with-raster",
    ]

    # By default PostGIS will try to detect gettext support and compile with it,
    # how ever if your un into incompatibility issues that cause breakage of loader,
    # you can disable it entirely with this command. Refer to ticket
    # http://trac.osgeo.org/postgis/ticket/748 for an example issue solved by
    # configuring with this. NOTE: that you aren’t missing much by turning this off.
    # This is used for international help/label support for the GUI loader which is not
    # yet documented and still experimental.
    args << "--with-gettext=no" # or PATH

    # Unfortunately, NLS support causes all kinds of headaches because
    # PostGIS gets all of its compiler flags from the PGXS makefiles. This
    # makes it nigh impossible to tell the buildsystem where our keg-only
    # gettext installations are.
    args << "--disable-nls"

    # Wagyu will only be necessary if protobuf is present to build MVTs
    # args << "--with-wagyu"

    # Disable topology support.
    # There is no corresponding library as all logic needed for
    # topology is in postgis- 2.4.8 library.
    # args << "--without-topology"

    # Disable the address_standardizer extension
    # args << "--without-address-standardizer"

    # specify the dtd path for mathml2.dtd
    # args << "--with-mathmldtd=PATH"

    args << "--with-xsldir=#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl" if build.with? "html-docs" # /docbook-xsl-nons

    if build.with?("pg10")
      args << "--with-pgconfig=#{Formula["osgeo-postgresql@10"].opt_bin}/pg_config"
    else
      args << "--with-pgconfig=#{Formula["osgeo-postgresql"].opt_bin}/pg_config"
    end

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
    (share/"doc/postgresql/extension").install Dir["stage/**/share/doc/postgresql/extension/*"]
    (share/"postgresql/extension").install Dir["stage/**/share/postgresql/extension/*"]
    (share/"postgresql/contrib/postgis-2.4").install Dir["stage/**/contrib/postgis-*/*"]

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
        #{HOMEBREW_PREFIX}/share/postgresql/contrib/postgis-2.4
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

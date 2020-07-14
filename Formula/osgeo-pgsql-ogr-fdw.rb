class OsgeoPgsqlOgrFdw < Formula
  desc "PostgreSQL foreign data wrapper for OGR"
  homepage "https://github.com/pramsey/pgsql-ogr-fdw"
  #url "https://github.com/pramsey/pgsql-ogr-fdw/archive/v1.0.8.tar.gz"
  #sha256 "4ab0c303006bfd83dcd40af4d53c48e7d8ec7835bb98491bc6640686da788a8b"
  url "https://github.com/pramsey/pgsql-ogr-fdw.git",
    :branch => "master",
    :commit => "6b0f4690e49ef4e0203252b2a87d25a173afc1ad"
  version "1.0.12"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "329908858b691a160db41b1655641a865a831284193732520b462e9318086351" => :catalina
    sha256 "329908858b691a160db41b1655641a865a831284193732520b462e9318086351" => :mojave
    sha256 "329908858b691a160db41b1655641a865a831284193732520b462e9318086351" => :high_sierra
  end

  #revision 1

  head "https://github.com/pramsey/pgsql-ogr-fdw.git", :branch => "master"

  def pour_bottle?
    # Postgres extensions must live in the Postgres prefix, which precludes
    # bottling: https://github.com/Homebrew/homebrew/issues/10247
    # Overcoming this will likely require changes in Postgres itself.
    false
  end

  option "with-pg11", "Build with PostgreSQL 11 client"

  depends_on "osgeo-postgis"
  depends_on "osgeo-gdal"

  if build.with?("pg11")
    depends_on "osgeo-postgresql@11"
  else
    depends_on "osgeo-postgresql"
  end

  def install
    ENV.deparallelize

    ENV.append "CFLAGS", "-Wl,-z,relro,-z,now"

    # This includes PGXS makefiles and so will install __everything__
    # into the Postgres keg instead of the this formula's keg.
    # Right now, no items installed to Postgres keg need to be installed to `prefix`.
    # In the future, if `make install` installs things that should be in `prefix`
    # consult postgis formula to see how to split it up.

    rm "#{buildpath}/Makefile"

    if build.with?("pg11")
      postgresql_ver = "#{Formula["osgeo-postgresql@11"].opt_bin}"
    else
      postgresql_ver = "#{Formula["osgeo-postgresql"].opt_bin}"
    end

    # Fix bin install path
    # Use CFLAGS from environment
    config = <<~EOS
      # ogr_fdw/Makefile

      MODULE_big = ogr_fdw
      OBJS = ogr_fdw.o ogr_fdw_deparse.o ogr_fdw_common.o stringbuffer_pg.o
      EXTENSION = ogr_fdw
      DATA = ogr_fdw--1.0.sql

      REGRESS = ogr_fdw

      EXTRA_CLEAN = sql/*.sql expected/*.out

      GDAL_CONFIG = #{Formula["osgeo-gdal"].opt_bin}/gdal-config
      GDAL_CFLAGS = $(shell $(GDAL_CONFIG) --cflags)
      GDAL_LIBS = $(shell $(GDAL_CONFIG) --libs)

      PG_CONFIG = #{postgresql_ver}/pg_config
      REGRESS_OPTS = --encoding=UTF8

      PG_CPPFLAGS += $(GDAL_CFLAGS)
      LIBS += $(GDAL_LIBS)
      SHLIB_LINK := $(LIBS)

      PGXS := $(shell $(PG_CONFIG) --pgxs)
      include $(PGXS)

      PG_VERSION_NUM = $(shell awk '/PG_VERSION_NUM/ { print $$3 }' $(shell $(PG_CONFIG) --includedir-server)/pg_config.h)
      HAS_IMPORT_SCHEMA = $(shell [ $(PG_VERSION_NUM) -ge 90500 ] && echo yes)

      # order matters, file first, import last
      REGRESS = file pgsql
      ifeq ($(HAS_IMPORT_SCHEMA),yes)
      REGRESS += import
      endif

      ###############################################################
      # Build the utility program after PGXS to override the
      # PGXS environment

      CFLAGS = $(GDAL_CFLAGS) $(CFLAGS)
      LIBS = $(GDAL_LIBS)

      ogr_fdw_info$(X): ogr_fdw_info.o ogr_fdw_common.o stringbuffer.o
      	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

      clean-exe:
      	rm -f ogr_fdw_info$(X) ogr_fdw_info.o stringbuffer.o

      install-exe: all
      	# $(INSTALL_PROGRAM) ogr_fdw_info$(X) '$(DESTDIR)$(bindir)'
        # or $(INSTALL_PROGRAM) -D ogr_fdw_info$(X) '$(DESTDIR)$(bindir)/ogr_fdw_info$(X)'

      all: ogr_fdw_info$(X)

      clean: clean-exe

      install: install-exe
    EOS

    (buildpath/"Makefile").write config

    system "make"
    system "make", "DESTDIR=#{prefix}", "install"

    mv "#{prefix}/usr/local/lib", "#{lib}"
    mv "#{prefix}/usr/local/share", "#{share}"
    rm_f "#{prefix}/usr"

    bin.install "ogr_fdw_info"
    prefix.install "data"

  end

  def caveats;
    <<~EOS
      For info on using extension, read the included REAMDE.md or visit:
        https://github.com/pramsey/pgsql-ogr-fdw

      PostGIS plugin libraries installed to:
        /usr/local/lib/postgresql
      PostGIS extension modules installed to:
       /usr/local/share/postgresql/extension
    EOS
  end

  test do
    # test the sql generator for the extension
    data_sub = "data".upcase # or brew audit thinks there is a D A T A section
    sql_out = <<~EOS

      CREATE SERVER myserver
        FOREIGN #{data_sub} WRAPPER ogr_fdw
        OPTIONS (
        	datasource '#{prefix}/data',
        	format 'ESRI Shapefile' );

      CREATE FOREIGN TABLE pt_two (
        fid bigint,
        geom Geometry(Point,4326),
        name varchar(50),
        age integer,
        height doubleprecision,
        birthdate date
      ) SERVER "myserver"
      OPTIONS (layer 'pt_two');

    EOS

    result = shell_output("ogr_fdw_info -s #{prefix}/data -l pt_two")
    assert_equal sql_out.gsub(' ',''), result.gsub(' ','')
  end
end

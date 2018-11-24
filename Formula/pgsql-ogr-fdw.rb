class PgsqlOgrFdw < Formula
  desc "PostgreSQL foreign data wrapper for OGR"
  homepage "https://github.com/pramsey/pgsql-ogr-fdw"
  url "https://github.com/pramsey/pgsql-ogr-fdw/archive/v1.0.7.tar.gz"
  sha256 "c776d9ad108818bae33336ca8d2219837e04d2c25c9086928e4bb6e06947b6e9"

  # revision 1

  head "https://github.com/pramsey/pgsql-ogr-fdw.git", :branch => "master"

  # Fix bin install path
  # Use CFLAGS from environment
  patch :DATA

  def pour_bottle?
    # Postgres extensions must live in the Postgres prefix, which precludes
    # bottling: https://github.com/Homebrew/homebrew/issues/10247
    # Overcoming this will likely require changes in Postgres itself.
    false
  end

  depends_on "postgis2"
  depends_on "gdal2"

  def install
    ENV.deparallelize

    ENV.append "CFLAGS", "-Wl,-z,relro,-z,now"

    # This includes PGXS makefiles and so will install __everything__
    # into the Postgres keg instead of the this formula's keg.
    # Right now, no items installed to Postgres keg need to be installed to `prefix`.
    # In the future, if `make install` installs things that should be in `prefix`
    # consult postgis formula to see how to split it up.

    system "make"
    system "make", "DESTDIR=#{prefix}", "install"

    mv "#{prefix}/usr/local/lib", "#{lib}"
    mv "#{prefix}/usr/local/share", "#{share}"
    rm_f "#{prefix}/usr/local"

    bin.install "ogr_fdw_info"
    prefix.install "data"
  end

  def caveats;
    pg = Formula["postgresql"].opt_prefix
    <<~EOS
      For info on using extension, read the included REAMDE.md or visit:
        https://github.com/pramsey/pgsql-ogr-fdw

      PostGIS plugin libraries installed to:
        #{pg}/lib
      PostGIS extension modules installed to:
        #{pg}/share/postgresql/extension
    EOS
  end

  test do
    ogr_fdw_info -s "#{prefix}/data"
    # # test the sql generator for the extension
    # data_sub = "data".upcase # or brew audit thinks there is a D A T A section
    # sql_out = <<~EOS
    #   CREATE SERVER myserver
    #     FOREIGN #{data_sub} WRAPPER ogr_fdw
    #     OPTIONS (
    #           datasource '#{prefix}/data',
    #           format 'ESRI Shapefile' );
    #
    #   CREATE FOREIGN TABLE pt_two (
    #     fid bigint,
    #     geom Geometry(Point,4326),
    #     name varchar,
    #     age integer,
    #     height real,
    #     birthdate date
    #   ) SERVER myserver
    #   OPTIONS (layer 'pt_two');
    # EOS
    #
    # result = shell_output("ogr_fdw_info -s #{prefix}/data -l pt_two")
    # assert_equal sql_out.strip, result.strip
  end
end

__END__

--- a/Makefile
+++ b/Makefile
@@ -9,11 +9,11 @@

 EXTRA_CLEAN = sql/*.sql expected/*.out

-GDAL_CONFIG = gdal-config
+GDAL_CONFIG = /usr/local/opt/gdal2/bin/gdal-config
 GDAL_CFLAGS = $(shell $(GDAL_CONFIG) --cflags)
 GDAL_LIBS = $(shell $(GDAL_CONFIG) --libs)

-PG_CONFIG = pg_config
+PG_CONFIG = /usr/local/opt/postgresql/bin/pg_config
 REGRESS_OPTS = --encoding=UTF8

 PG_CPPFLAGS += $(GDAL_CFLAGS)
@@ -36,7 +36,7 @@
 # Build the utility program after PGXS to override the
 # PGXS environment

-CFLAGS = $(GDAL_CFLAGS)
+CFLAGS = $(GDAL_CFLAGS) $(CFLAGS)
 LIBS = $(GDAL_LIBS)

 ogr_fdw_info$(X): ogr_fdw_info.o ogr_fdw_common.o stringbuffer.o
@@ -46,7 +46,7 @@
 	rm -f ogr_fdw_info$(X) ogr_fdw_info.o stringbuffer.o

 install-exe: all
-	$(INSTALL_PROGRAM) ogr_fdw_info$(X) '$(DESTDIR)$(bindir)'
+	# $(INSTALL_PROGRAM) ogr_fdw_info$(X) '$(DESTDIR)$(bindir)'

 all: ogr_fdw_info$(X)

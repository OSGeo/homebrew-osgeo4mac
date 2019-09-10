class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_libspatialite_linked }

  def core_libspatialite_linked
    Formula["libspatialite"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink libspatialite\e[0m or remove with brew \e[32muninstall --ignore-dependencies libspatialite\e[0m\n\n" if core_libspatialite_linked
    s
  end
end

class OsgeoLibspatialite < Formula
  desc "Adds spatial SQL capabilities to SQLite"
  homepage "https://www.gaia-gis.it/fossil/libspatialite/index"
  # proj6
  url "https://www.gaia-gis.it/fossil/libspatialite", :using => :fossil
  version "4.3.0a"

  revision 3

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "60c373eacb0e0786d860495678f3be8bf993008ecdac878e10be042446af1647" => :mojave
    sha256 "60c373eacb0e0786d860495678f3be8bf993008ecdac878e10be042446af1647" => :high_sierra
    sha256 "92ab0f182815f349661841dc412700d95bb01cb6104334c892810c4acc27158b" => :sierra
  end

  head do
    url "https://www.gaia-gis.it/fossil/libspatialite", :using => :fossil
  end

  # keg_only "libspatialite" is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "freexl"
  depends_on "geos"
  depends_on "libxml2"
  depends_on "osgeo-proj"
  # Needs SQLite > 3.7.3 which rules out system SQLite on Snow Leopard and
  # below. Also needs dynamic extension support which rules out system SQLite
  # on Lion. Finally, RTree index support is required as well.
  depends_on "sqlite"

  def install
    system "autoreconf", "-fi"

    # New SQLite3 extension won't load via SELECT load_extension("mod_spatialite");
    # unless named mod_spatialite.dylib (should actually be mod_spatialite.bundle)
    # See: https://groups.google.com/forum/#!topic/spatialite-users/EqJAB8FYRdI
    #      needs upstream fixes in both SQLite and libtool
    inreplace "configure",
              "shrext_cmds='`test .$module = .yes && echo .so || echo .dylib`'",
              "shrext_cmds='.dylib'"
    chmod 0755, "configure"

    # Ensure Homebrew's libsqlite is found before the system version.
    sqlite = Formula["sqlite"]
    ENV.append "LDFLAGS", "-L#{sqlite.opt_lib}"
    ENV.append "CFLAGS", "-I#{sqlite.opt_include}"

    # Use Proj 6.0.0 compatibility headers.
    # Remove in libspatialite 5.0.0
    ENV.append_to_cflags "-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --with-sysroot=#{HOMEBREW_PREFIX}
      --enable-geocallbacks
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    # Verify mod_spatialite extension can be loaded using Homebrew's SQLite
    pipe_output("#{Formula["sqlite"].opt_bin}/sqlite3",
      "SELECT load_extension('#{opt_lib}/mod_spatialite');")
  end
end

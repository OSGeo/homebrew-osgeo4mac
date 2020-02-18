class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_psqlodbc_linked }

  def core_psqlodbc_linked
    Formula["psqlodbc"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink psqlodbc\e[0m or remove with \e[32mbrew uninstall --ignore-dependencies psqlodbc\e[0m\n\n" if core_psqlodbc_linked
    s
  end
end

class OsgeoPsqlodbc < Formula
  desc "Official PostgreSQL ODBC driver"
  homepage "https://odbc.postgresql.org"
  url "https://ftp.postgresql.org/pub/odbc/versions/src/psqlodbc-12.01.0000.tar.gz"
  sha256 "fdbb3edfcc9730787bb84d76e61fcf7584ced1913d7bfccea0bcbf5a150a5f74"

  # revision 1

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "9184542ccf288784794bd6c3ec4d13127771166c7619ff305d7c56816984c89f" => :mojave
    sha256 "9184542ccf288784794bd6c3ec4d13127771166c7619ff305d7c56816984c89f" => :high_sierra
    sha256 "ec4d537d87495060b8084da9f79e01ad3408d07c5d1161add9bd46a77130fe98" => :sierra
  end

  # revision 1

  head do
    url "https://git.postgresql.org/git/psqlodbc.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  # keg_only "psqlodbc is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "openssl"
  depends_on "unixodbc"

  if build.with?("pg10")
    depends_on "osgeo-postgresql@10"
  else
    depends_on "osgeo-postgresql"
  end

  def install
    system "./bootstrap" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--with-unixodbc=#{Formula["unixodbc"].opt_prefix}"
    system "make"
    system "make", "install"
  end

  test do
    output = shell_output("#{Formula["unixodbc"].bin}/dltest #{lib}/psqlodbcw.so")
    assert_equal "SUCCESS: Loaded #{lib}/psqlodbcw.so\n", output
  end
end

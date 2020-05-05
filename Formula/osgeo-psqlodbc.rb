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

  revision 2

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "49e9d451801d23d81f2e3c87654f325f1e84e2723604e7668369e04d692343c8" => :catalina
    sha256 "49e9d451801d23d81f2e3c87654f325f1e84e2723604e7668369e04d692343c8" => :mojave
    sha256 "49e9d451801d23d81f2e3c87654f325f1e84e2723604e7668369e04d692343c8" => :high_sierra
  end

  # revision 1

  head do
    url "https://git.postgresql.org/git/psqlodbc.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-pg11", "Build with PostgreSQL 11 client"

  # keg_only "psqlodbc is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "openssl"
  depends_on "unixodbc"

  if build.with?("pg11")
    depends_on "osgeo-postgresql@11"
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

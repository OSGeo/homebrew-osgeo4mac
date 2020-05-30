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
  url "https://ftp.postgresql.org/pub/odbc/versions/src/psqlodbc-12.02.0000.tar.gz"
  sha256 "7b00d99ee729c06cfc784ab43deb7dee77761b667dd62122c2cb0cd7b043ba67"

  #revision 3

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "a9085711555601a64b30ee356643a2dfbecc7ff9ccd254c477d7977b66e0d365" => :catalina
    sha256 "a9085711555601a64b30ee356643a2dfbecc7ff9ccd254c477d7977b66e0d365" => :mojave
    sha256 "a9085711555601a64b30ee356643a2dfbecc7ff9ccd254c477d7977b66e0d365" => :high_sierra
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

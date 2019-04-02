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
  url "https://ftp.postgresql.org/pub/odbc/versions/src/psqlodbc-11.00.0000.tar.gz"
  sha256 "703e6b87022f95ffa00d9f86c8f0a877f8a55b9b3be0942081f382e794112a86"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "b642f5e73bec11c2c21566a219a9cbdd4f72e7a85084ba87af0e4f810de1da71" => :mojave
    sha256 "b642f5e73bec11c2c21566a219a9cbdd4f72e7a85084ba87af0e4f810de1da71" => :high_sierra
    sha256 "415b4efb68a0461bc104856568b28a2c4971202f222a9491cd90365140d0bf74" => :sierra
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

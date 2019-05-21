class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_libpqxx_linked }

  def core_libpqxx_linked
    Formula["libpqxx"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink libpqxx\e[0m or remove with brew \e[32muninstall --ignore-dependencies libpqxx\e[0m\n\n" if core_libpqxx_linked
    s
  end
end

class OsgeoLibpqxx < Formula
  desc "C++ connector for PostgreSQL"
  homepage "http://pqxx.org/development/libpqxx"
  url "https://github.com/jtv/libpqxx/archive/6.4.4.tar.gz"
  sha256 "6ae3a0113a242db6bb9d998943b7cc23699652d843dab702aa06a8b9330c171a"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "d7db2314a607f3be0e513eb1bed2f89f580b0d7e89bd340d468c42acbff5ea7a" => :mojave
    sha256 "d7db2314a607f3be0e513eb1bed2f89f580b0d7e89bd340d468c42acbff5ea7a" => :high_sierra
    sha256 "5e1ef8a7f952c5395cef979f23d729d51af6ecd5f75909338c8f74094c201d2b" => :sierra
  end

  # revision 1

  head "https://github.com/jtv/libpqxx.git", :branch => "master"

  option "with-pg10", "Build with PostgreSQL 10 client"

  # keg_only "libpqxx is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "pkg-config" => :build
  depends_on "xmlto" => :build

  depends_on "python@2"
  depends_on "doxygen"
  depends_on "graphviz"

  if build.with?("pg10")
    depends_on "osgeo-postgresql@10"
  else
    depends_on "osgeo-postgresql"
  end

  def install
    ENV.cxx11

    ENV.append "CXXFLAGS", "-std=c++11"

    inreplace "tools/splitconfig", "python", "python2"

    system "./configure", "--prefix=#{prefix}", "--enable-shared"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <pqxx/pqxx>
      int main(int argc, char** argv) {
        pqxx::connection con;
        return 0;
      }
    EOS

    # system "initdb", "/usr/local/var/postgresql", "-E", "utf8", "--locale=en_US.UTF-8"
    # system "psql", "-h", "localhost", "-d", "postgres"
    # system "createdb", "circleci"
    system ENV.cxx, "-std=c++11", "test.cpp", "-L#{lib}", "-lpqxx", "-I#{include}", "-o", "test"

    # Running ./test will fail because there is no runnning postgresql server
    # system "./test"

    # `pg_config` uses Cellar paths not opt paths
    # postgresql_include = Formula["osgeo-postgresql"].opt_include.realpath.to_s
    # assert_match postgresql_include, (lib/"pkgconfig/libpqxx.pc").read,
    #              "Please revision bump libpqxx."
  end
end

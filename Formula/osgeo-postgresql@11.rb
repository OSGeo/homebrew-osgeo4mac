class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !osgeo_postgresql_linked && !osgeo_postgresql10_linked && !core_postgresql_linked && !core_postgresql11_linked && !core_postgresql10_linked }

  def osgeo_postgresql_linked
    Formula["osgeo-postgresql"].linked_keg.exist?
  rescue
    return false
  end

  def osgeo_postgresql10_linked
    Formula["osgeo-postgresql@10"].linked_keg.exist?
  rescue
    return false
  end

  def core_postgresql_linked
    Formula["postgresql"].linked_keg.exist?
  rescue
    return false
  end

  def core_postgresql11_linked
    Formula["postgresql@11"].linked_keg.exist?
  rescue
    return false
  end

  def core_postgresql10_linked
    Formula["postgresql@10"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink osgeo-postgresql\e[0m or remove with \e[32mbrew uninstall --ignore-dependencies osgeo-postgresql\e[0m\n\n" if osgeo_postgresql_linked
    s += "Unlink with \e[32mbrew unlink osgeo-postgresql@10\e[0m or remove with \e[32mbrew uninstall --ignore-dependencies osgeo-postgresql@10\e[0m\n\n" if osgeo_postgresql10_linked
    s += "Unlink with \e[32mbrew unlink postgresql\e[0m or remove with brew \e[32muninstall --ignore-dependencies postgresql\e[0m\n\n" if core_postgresql_linked
    s += "Unlink with \e[32mbrew unlink postgresql@11\e[0m or remove with brew \e[32muninstall --ignore-dependencies postgresq@11\e[0m\n\n" if core_postgresql11_linked
    s += "Unlink with \e[32mbrew unlink postgresql@10\e[0m or remove with brew \e[32muninstall --ignore-dependencies postgresq@10\e[0m\n\n" if core_postgresql10_linked
    s
  end
end

class OsgeoPostgresqlAT11 < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  url "https://github.com/postgres/postgres/archive/REL_11_8.tar.gz"
  sha256 "f5a35594fbe448ecb10a2d53e0737a872751ff51805e1f86ddccb922e564cdbb"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "439b6521642aefbf2b8d54940234850d07a993b7624b3c70f033d29f1aa08546" => :catalina
    sha256 "439b6521642aefbf2b8d54940234850d07a993b7624b3c70f033d29f1aa08546" => :mojave
    sha256 "439b6521642aefbf2b8d54940234850d07a993b7624b3c70f033d29f1aa08546" => :high_sierra
  end

  revision 2

  head "https://github.com/postgres/postgres.git", :branch => "master"

  option "with-cellar", "Use /Cellar in the path configuration (necessary for migration)"

  # keg_only "postgresql is already provided by homebrew/core"
  # we will verify that other versions are not linked
  #depends_on Unlinked

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "icu4c"
  depends_on "openldap" # libldap
  depends_on "openssl"
  depends_on "readline"
  depends_on "tcl-tk"
  depends_on "krb5"
  depends_on "libxml2"
  depends_on "python"
  depends_on "perl"
  depends_on "zlib"
  # depends_on "e2fsprogs"

  # others: pam

  def install
    # avoid adding the SDK library directory to the linker search path
    # XML2_CONFIG=:
    ENV["XML2_CONFIG"] = "xml2-config --exec-prefix=/usr"

    # As of Xcode/CLT 10.x the Perl headers were moved from /System
    # to inside the SDK, so we need to use `-iwithsysroot` instead
    # of `-I` to point to the correct location.
    # https://www.postgresql.org/message-id/153558865647.1483.573481613491501077%40wrigleys.postgresql.org
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl"].opt_lib} -L#{Formula["readline"].opt_lib} -R#{lib}/postgresql"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl"].opt_include} -I#{Formula["readline"].opt_include}"

    # ENV["PYTHON"] = which("python3")
    ENV["PYTHON"] = "#{Formula["python"].opt_bin}/python3"

    args = %W[
      --disable-debug
      --enable-thread-safety
      --with-bonjour
      --with-gssapi
      --with-icu
      --with-ldap
      --with-libxml
      --with-libxslt
      --with-openssl
      --with-pam
      --with-perl
      --with-uuid=e2fs
      --enable-dtrace
      --enable-nls
      --with-python
    ]

    if build.with? "cellar"
      args += [
        "--prefix=#{prefix}",
        # "bindir=#{bin}", # if define this, will refer to /Cellar
        "--datadir=#{share}/postgresql",
        "--libdir=#{lib}/postgresql",
        "--sysconfdir=#{etc}",
        "--docdir=#{doc}/postgresql",
        "--includedir=#{include}/postgresql"
      ]
    else
      # this is to not have the reference to /Cellar in the files
      args += [
        "--prefix=#{prefix}",
        # "--bindir=#{HOMEBREW_PREFIX}/bin",
        "--sysconfdir=#{HOMEBREW_PREFIX}/etc",
        "--libdir=#{HOMEBREW_PREFIX}/lib",
        "--datadir=#{HOMEBREW_PREFIX}/share/postgresql",
        "--docdir=#{HOMEBREW_PREFIX}/share/doc/postgresql",
        "--localstatedir=#{HOMEBREW_PREFIX}/var",
        "--includedir=#{HOMEBREW_PREFIX}/include",
        "--datarootdir=#{HOMEBREW_PREFIX}/share",
        "--localedir=#{HOMEBREW_PREFIX}/share/locale",
        "--mandir=#{HOMEBREW_PREFIX}/share/man",
      ]

      # args << "--with-system-tzdata=#{HOMEBREW_PREFIX}/share/zoneinfo" # use system time zone data in DIR
    end

    dirs = [
      # "bindir=#{bin}",
      "datadir=#{share}/postgresql", # #{pkgshare}
      "libdir=#{lib}",
      "pkglibdir=#{lib}/postgresql", # #{lib}
      "pkgincludedir=#{include}/postgresql",
      "sysconfdir=#{etc}",
      "includedir=#{include}",
      "localedir=#{share}/locale",
      "mandir=#{man}",
      "docdir=#{share}/doc/postgresql",
    ]

    # The CLT is required to build Tcl support on 10.7 and 10.8 because
    # tclConfig.sh is not part of the SDK
    args << "--with-tcl"
    if File.exist?("#{MacOS.sdk_path}/System/Library/Frameworks/Tcl.framework/tclConfig.sh")
      args << "--with-tclconfig=#{MacOS.sdk_path}/System/Library/Frameworks/Tcl.framework"
    end

    # Add include and library directories of dependencies, so that
    # they can be used for compiling extensions.  Superenv does this
    # when compiling this package, but won't record it for pg_config.
    deps = %w[gettext icu4c openldap openssl readline tcl-tk]
    with_includes = deps.map { |f| Formula[f].opt_include }.join(":")
    with_libraries = deps.map { |f| Formula[f].opt_lib }.join(":")
    args << "--with-includes=#{with_includes}"
    args << "--with-libraries=#{with_libraries}"

    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    system "./configure", *args
    system "make"

    # Temporarily disable building/installing the documentation.
    # Postgresql seems to "know" the build system has been altered and
    # tries to regenerate the documentation when using `install-world`.
    # This results in the build failing:
    #  `ERROR: `osx' is missing on your system.`
    # Attempting to fix that by adding a dependency on `open-sp` doesn't
    # work and the build errors out on generating the documentation, so
    # for now let's simply omit it so we can package Postgresql for Mojave.
    # if DevelopmentTools.clang_build_version >= 1000
    system "make", "all"
    system "make", "-C", "contrib", "install", "all", *dirs
    system "make", "install", "all", *dirs
    # else
    #   system "make", "install-world", *dirs
    # end
  end

  def post_install
    # (var/"log").mkpath
    # (var/"postgresql").mkpath
    # unless File.exist? "#{var}/postgresql/PG_VERSION"
    #   system "#{bin}/initdb", "#{var}/postgresql"
    # end

    if build.with? "cellar"
      if File.exists?(File.join("#{HOMEBREW_PREFIX}/Cellar", "osgeo-postgis@2.5"))
        unless File.exists?("#{HOMEBREW_PREFIX}/opt/osgeo-postgresql/lib/postgresql/postgis-2.5.so")
          # copy postgis 2.5.x to postgresql 11.x
          FileUtils.cp_r "#{Formula["osgeo-postgis@2.5"].opt_share}/postgresql/.", "#{share}/postgresql/"
          FileUtils.cp_r "#{Formula["osgeo-postgis@2.5"].opt_lib}/postgresql/.", "#{lib}/postgresql/"
          # FileUtils.cp_r "#{Formula["osgeo-postgis@2.5"].opt_lib}/postgresql/rtpostgis-2.5.so", "#{lib}/postgresql/"
          # FileUtils.cp_r "#{Formula["osgeo-postgis@2.5"].opt_lib}/postgresql/postgis-2.5.so", "#{lib}/postgresql/"
          # FileUtils.cp_r "#{Formula["osgeo-postgis@2.5"].opt_lib}/postgresql/postgis_topology-2.5.so", "#{lib}/postgresql/"
        end
      end

      # if File.exists?(File.join("#{HOMEBREW_PREFIX}/Cellar", "osgeo-postgis"))
      #   unless File.exists?("#{HOMEBREW_PREFIX}/opt/osgeo-postgresql/lib/postgresql/postgis-2.5.so")
      #     # install postgis 2.5.x to postgresql 11.x
      #     FileUtils.cp_r "#{Formula["osgeo-postgis"].opt_share}/postgresql/.", "#{share}/postgresql/"
      #     # FileUtils.cp_r "#{Formula["osgeo-postgis"].opt_lib}/postgresql/.", "#{lib}/postgresql/"
      #     FileUtils.cp_r "#{Formula["osgeo-postgis"].opt_lib}/postgresql/rtpostgis-2.5.so", "#{lib}/postgresql/"
      #     FileUtils.cp_r "#{Formula["osgeo-postgis"].opt_lib}/postgresql/postgis-2.5.so", "#{lib}/postgresql/"
      #     FileUtils.cp_r "#{Formula["osgeo-postgis"].opt_lib}/postgresql/postgis_topology-2.5.so", "#{lib}/postgresql/"
      #   end
      # end
    end
  end

  def caveats; <<~EOS

    1 - If you need to link "#{name}":

          \e[32m$ brew link #{name} --force\e[0m

        Previously unlink any other version that you have installed.

    2 - If you need to init postgresql just execute the following command:

          \e[32m$ initdb #{HOMEBREW_PREFIX}/var/postgresql -E utf8 --locale=en_US.UTF-8\e[0m

        If the file "#{HOMEBREW_PREFIX}/var/postgresql/PG_VERSION" exists,
        it is because you already created this in postinstall or a previous installation.

    3 - Start using:

          \e[32m$ pg_ctl start -D /usr/local/var/postgresql\e[0m

    4 - Connecting to our new database

          \e[32m$ psql -h localhost -d postgres\e[0m

    Note:

      - Services doesn't start properly, add to \e[32mhomebrew.mxcl.osgeo-postgresql.plist\e[0m:

          \e[32m<key>EnvironmentVariables</key>\e[0m
          \e[32m<dict>\e[0m
            \e[32m<key>LC_ALL</key>\e[0m
            \e[32m<string>en_US.UTF-8</string>\e[0m
          \e[32m</dict>\e[0m

          issue: \e[32mhttps://github.com/OSGeo/homebrew-osgeo4mac/issues/1075#issuecomment-490052517\e[0m

      - Could not bind ipv6 address database system was not properly shut:

          \e[32m$ sudo lsof -i :5432\e[0m (search PID)

          \e[32m$ kill PID\e[0m

      - To migrate existing data from a previous major version of PostgreSQL run:

          \e[32m$ brew postgresql-upgrade-database\e[0m

      - For more information see our page with documentation:

          \e[32mhttps://osgeo.github.io/homebrew-osgeo4mac\e[0m
    EOS
  end

  plist_options :manual => "pg_ctl -D #{HOMEBREW_PREFIX}/var/postgresql start"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/postgres</string>
        <string>-D</string>
        <string>#{var}/postgresql</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/postgresql.log</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/postgresql.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    ENV["LC_ALL"]="en_US.UTF-8"
    ENV["LC_CTYPE"]="en_US.UTF-8"
    system "#{bin}/initdb", testpath/"test"
    if build.with? "cellar"
      assert_equal (share/"postgresql").to_s, shell_output("#{bin}/pg_config --sharedir").chomp
      assert_equal (lib/"postgresql").to_s, shell_output("#{bin}/pg_config --libdir").chomp
      assert_equal (lib/"postgresql").to_s, shell_output("#{bin}/pg_config --pkglibdir").chomp
    else
      assert_equal "#{HOMEBREW_PREFIX}/share/postgresql", shell_output("#{bin}/pg_config --sharedir").chomp
      assert_equal "#{HOMEBREW_PREFIX}/lib", shell_output("#{bin}/pg_config --libdir").chomp
      assert_equal "#{HOMEBREW_PREFIX}/lib/postgresql", shell_output("#{bin}/pg_config --pkglibdir").chomp
    end
  end
end

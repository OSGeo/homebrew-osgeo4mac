class OsgeoPostgresqlAT10 < Formula
  desc "Relational database management system"
  homepage "https://www.postgresql.org/"
  url "https://github.com/postgres/postgres/archive/REL_10_7.tar.gz"
  sha256 "83104a340b5eae7892776c36641be9deb790a52dd1b325bec8509bec65efbe4f"
  version "10.7"

  revision 1

  head "https://github.com/postgres/postgres.git", :branch => "REL_10_STABLE"

  keg_only :versioned_formula

  depends_on "pkg-config" => :build
  depends_on "e2fsprogs"
  depends_on "gettext"
  depends_on "icu4c"
  depends_on "openldap" # libldap
  depends_on "openssl"
  depends_on "readline"
  depends_on "tcl-tk"
  depends_on "krb5"
  depends_on "libxml2"
  depends_on "python"
  depends_on "python2"
  depends_on "perl"
  depends_on "zlib"

  # others: pam

  def install
    args = %W[
      --disable-debug
      --enable-thread-safety
      --enable-dtrace
      --enable-nls
      --with-bonjour
      --with-gssapi
      --with-icu
      --with-ldap
      --with-libxml
      --with-libxslt
      --with-openssl
      --with-uuid=e2fs
      --with-pam
      --with-perl
      --with-python
      --with-tcl
    ]

    args << "--prefix=#{prefix}"
    args << "--datadir=#{HOMEBREW_PREFIX}/share/postgresql"
    args << "--libdir=#{HOMEBREW_PREFIX}/lib"
    args << "--sysconfdir=#{HOMEBREW_PREFIX}/etc"
    args << "--docdir=#{HOMEBREW_PREFIX}/doc"
    args << "--mandir=#{HOMEBREW_PREFIX}/share/man"
    # args << "--with-system-tzdata=#{HOMEBREW_PREFIX}/share/zoneinfo"

    # avoid adding the SDK library directory to the linker search path
    # XML2_CONFIG=:
    ENV["XML2_CONFIG"] = "xml2-config --exec-prefix=/usr"

    ENV.prepend "LDFLAGS", "-L#{Formula["openssl"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl"].opt_include} -I#{Formula["readline"].opt_include}"

    # The CLT is required to build Tcl support on 10.7 and 10.8 because
    # tclConfig.sh is not part of the SDK
    args << "--with-tcl"
    if File.exist?("#{MacOS.sdk_path}/System/Library/Frameworks/Tcl.framework/tclConfig.sh")
      args << "--with-tclconfig=#{MacOS.sdk_path}/System/Library/Frameworks/Tcl.framework"
    end

    # As of Xcode/CLT 10.x the Perl headers were moved from /System
    # to inside the SDK, so we need to use `-iwithsysroot` instead
    # of `-I` to point to the correct location.
    # https://www.postgresql.org/message-id/153558865647.1483.573481613491501077%40wrigleys.postgresql.org
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl"].opt_lib} -L#{Formula["readline"].opt_lib} -R#{lib}/postgresql"

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

    # pkglibdir=#{lib}/postgresql
    # dirs = %W[datadir=#{pkgshare} libdir=#{lib} pkglibdir=#{lib}]

    # Temporarily disable building/installing the documentation.
    # Postgresql seems to "know" the build system has been altered and
    # tries to regenerate the documentation when using `install-world`.
    # This results in the build failing:
    #  `ERROR: `osx' is missing on your system.`
    # Attempting to fix that by adding a dependency on `open-sp` doesn't
    # work and the build errors out on generating the documentation, so
    # for now let's simply omit it so we can package Postgresql for Mojave.
    if DevelopmentTools.clang_build_version >= 1000
      system "make", "all"
      # system "make", "-C", "contrib", "install", "all", *args
      system "make", "-C", "contrib", "install", "all", "datadir=#{share}/postgresql",
                                                        "libdir=#{lib}",
                                                        "pkglibdir=#{lib}/postgresql",
                                                        "docdir=#{doc}",
                                                        "mandir=#{man}"
      # system "make", "install", "all", *args
      system "make", "install", "all", "datadir=#{share}/postgresql",
                                       "libdir=#{lib}",
                                       "pkglibdir=#{lib}/postgresql",
                                       "docdir=#{doc}",
                                       "mandir=#{man}"
    else
      # system "make", "install-world", *args
      system "make", "install-world", "datadir=#{share}/postgresql",
                                      "libdir=#{lib}",
                                      "pkglibdir=#{lib}/postgresql",
                                      "docdir=#{doc}",
                                      "mandir=#{man}"
    end
  end

  def post_install
    (var/"log").mkpath
    (var/name).mkpath
    unless File.exist? "#{var}/#{name}/PG_VERSION"
      system "#{bin}/initdb", "#{var}/#{name}"
    end
  end

  def caveats; <<~EOS
    To migrate existing data from a previous major version of PostgreSQL run:
      brew postgresql-upgrade-database
  EOS
  end

  plist_options :manual => "pg_ctl -D #{HOMEBREW_PREFIX}/var/postgresql@10 start"

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
        <string>#{var}/#{name}</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/#{name}.log</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/#{name}.log</string>
    </dict>
    </plist>
  EOS
  end

  def caveats; <<~EOS
    To migrate existing data from a previous major version of PostgreSQL run:
      brew postgresql-upgrade-database
    EOS
  end

  test do
    # this was tested and it works
    ENV["LC_ALL"]="en_US.UTF-8"
    ENV["LC_CTYPE"]="en_US.UTF-8"
    # system "#{bin}/initdb", "pgdata"
    # system "#{bin}/initdb", testpath/"test"
    # assert_equal ("#{HOMEBREW_PREFIX}/share/postgresql").to_s, shell_output("#{bin}/pg_config --sharedir").chomp
    # assert_equal ("#{HOMEBREW_PREFIX}/lib").to_s, shell_output("#{bin}/pg_config --libdir").chomp
    # assert_equal ("#{HOMEBREW_PREFIX}/lib/postgresql").to_s, shell_output("#{bin}/pg_config --pkglibdir").chomp
  end
end

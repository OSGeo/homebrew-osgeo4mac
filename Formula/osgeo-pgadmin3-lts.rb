class OsgeoPgadmin3Lts < Formula
  # include Language::Python::Virtualenv
  desc "Comprehensive design and management interface for PostgreSQL (LTS)"
  homepage "https://www.pgadmin.org"
  url "https://github.com/pgcentral/pgadmin3-lts/archive/7f3915ce4ccd5da7758ef6d2993cc8480e4aad3b.tar.gz"
  sha256 "65de9fb0d2bc43bfa0931832c344cfb894ae862acefefc64fbc8cd7d0f6cb7ff"
  version "1.22.3"

  revision 2

  head "https://github.com/pgcentral/pgadmin3-lts.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "52a1ede0df8e5cadd152cb3066b7948d8a40a8ede53b9175b4c0e55f8445daaa" => :mojave
    sha256 "52a1ede0df8e5cadd152cb3066b7948d8a40a8ede53b9175b4c0e55f8445daaa" => :high_sierra
    sha256 "581f3d4725d6f45892ed4fb168340da23cf0b0078bb35ff9c14051174e96a1c8" => :sierra
  end

  patch :DATA

  option "with-app", "Build pgAdmin.app Package"
  option "with-pg10", "Build with PostgreSQL 10 client"

  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "wxmac"
  depends_on "libxslt"
  depends_on "libxml2"
  depends_on "libgcrypt"
  depends_on "openssl"
  depends_on "libssh2"
  depends_on "zlib"
  depends_on "osgeo-libpqxx"
  depends_on "imagemagick"
  depends_on "krb5"
  # depends_on "python@2" # for Sphinx

  if build.with?("pg10")
    depends_on "osgeo-postgresql@10"
  else
    depends_on "osgeo-postgresql"
  end

  # resource "Sphinx" do
  #   url "https://files.pythonhosted.org/packages/2a/86/8e1e8400bb6eca5ed960917952600fce90599e1cb0d20ddedd81ba163370/Sphinx-1.8.5.tar.gz"
  #   sha256 "c7658aab75c920288a8cf6f09f244c6cfdae30d82d803ac1634d9f223a80ca08"
  # end

  if build.with?("pg10")
    # PG 10 support, adapted from:
    # https://bitbucket.org/openscg/pgadmin3-lts/commits/ea8a31af779b101248fc13242cb7a34e252cf49e/raw
    # https://bitbucket.org/openscg/pgadmin3-lts/commits/1d65e012f7bb88d3b6c5a08946a2456617213c35/raw
    resource "pg10" do
      url "https://gist.githubusercontent.com/fjperini/204ec325671a30e9ddb46d77ea8e1289/raw/f383173056b93731d3e2e8a90614373948274ca6/pgadmin3-pg10.diff"
      sha256 "74e127952d9674f4c09bbf8805f43f6a85821133fd9a84db094e8aab837c7d03"
    end
  else
    # PG 11 support, adapted from:
    # https://abdulyadi.wordpress.com/2018/11/03/pgadmin3-adjustment-for-postgresql-11-0/
    resource "pg11" do
      url "https://gist.githubusercontent.com/fjperini/9b22ecd9bda767e51a446749472f8e94/raw/7bed1afe383d915c408c3cc735a25b192b3e0108/pgadmin3-pg11.diff"
      sha256 "7dc526b80eb61540e9bf6d46a329f45eac683646caaa68dec90f9743723dd7d3"
    end
  end

  # 1.14.2-cflags
  # resource "cflags" do
  #   url "https://gist.githubusercontent.com/fjperini/5e9c519e88dd1aebd975edb89f2bd680/raw/03679e513f0ca67d5283d2560b0338d15730c0aa/pgadmin3-1.14.2-cflags.diff"
  #   sha256 "1ab6db05896684cac42b4a29a422a3cd29d12b98f8f7d092c7f7647ea0fffc76"
  # end

  # Move this == null check to a static function.  This works, but I opted
  # for the compiler flag since it "fixes" all cases, and pgadmin4 is on the
  # way.
  resource "nullthis" do
    url "https://gist.githubusercontent.com/fjperini/d5b129bad455a6d945ff80d17b91887a/raw/96531fd54ee7a67b7fd42eac97fedf6c8c27bb07/pgadmin3-nullthis.diff"
    sha256 "3b785ee8a2857f02b7d1983a3b8d699032494438096f3321576a8267c823b0c8"
  end

  # Fix failure to use EVP_CIPHER_CTX_new()
  # resource "ssh2" do
  #   url "https://gist.githubusercontent.com/fjperini/2bc12464cc37c0c324cc2a6a61a1f3af/raw/b28e587dc265f0094f0ed23d7ff210bb24f77128/pgadmin3-ssh2.diff"
  #   sha256 "71a7b90989ab35793b4435d6bc1ad54581f47649a5265021622fddb61ee83054"
  # end

  def install
    # venv = virtualenv_create(libexec, "#{Formula["python@2"].opt_bin}/python2")
    # res = resources.map(&:name).to_set - %w[pg11]
    # res.each do |r|
    #   venv.pip_install resource(r)
    # end

    if build.with?("pg10")
      resource("pg10").stage do
        cp_r "./pgadmin3-pg10.diff", "#{buildpath}"
      end
      system "patch", "-p1", "-i", "#{buildpath}/pgadmin3-pg10.diff"
    else
      resource("pg11").stage do
        cp_r "./pgadmin3-pg11.diff", "#{buildpath}"
      end
      system "patch", "-p1", "-i", "#{buildpath}/pgadmin3-pg11.diff"
    end

    # resource("cflags").stage do
    #   cp_r "./pgadmin3-1.14.2-cflags.diff", "#{buildpath}"
    # end
    # system "patch", "-p1", "-i", "#{buildpath}/pgadmin3-1.14.2-cflags.diff"

    resource("nullthis").stage do
      cp_r "./pgadmin3-nullthis.diff", "#{buildpath}"
    end
    # system "patch", "-p0", "-b", ".nullthis"
    system "patch", "-p1", "-i", "#{buildpath}/pgadmin3-nullthis.diff"

    # use the libssh2 embedded with pgadmin3
    # global use_embedded 1
    # remove embedded libssh2
    # system "rm", "-rf", "#{buildpath}/pgadmin/libssh2", "#{buildpath}/pgadmin/include/libssh2"
    # resource("ssh2").stage do
    #   cp_r "./pgadmin3-ssh2.diff", "#{buildpath}"
    # end
    # # system "patch", "-p0", "-b", ".ssh2f"
    # system "patch", "-p1", "-i", "#{buildpath}/pgadmin3-ssh2.diff"

    args = [
      "--with-wx=#{Formula["wxmac"].opt_prefix}", # #{HOMEBREW_PREFIX}
      "--with-wx-version=3.0", # #{Formula["wxmac"].version}
      "--with-libxml2=#{Formula["libxml2"].opt_prefix}",
      "--with-libxslt=#{Formula["libxslt"].opt_prefix}",
      "--prefix=#{prefix}",
      "--with-libgcrypt",
    ]

    args << "--with-arch-x86_64"

    # building SSH Tunnel
    args << "--with-libssl-prefix=#{Formula["openssl"].opt_prefix}" # or --with-libgcrypt-prefix=PATH

    # build docs
    # args << "--with-sphinx-build=#{libexec}/bin/sphinx-build"

    # statically linking pgAdmin
    # wxWidgets installation cannot support pgAdmin in the selected configuration
    # args << "--enable-static"

    # building database designer
    args << "--enable-databasedesigner"

    # building a Mac OS X appbundle
    # pgAdmin3.rsrc: No such file or directory
    # args << "--enable-appbundle"

    ENV.append "CXXFLAGS", "-fno-delete-null-pointer-checks -Wno-unused-local-typedefs"

    if build.with?("pg10")
      args << "--with-pgsql=#{Formula["osgeo-postgresql@10"].opt_prefix}"
    else
      args << "--with-pgsql=#{Formula["osgeo-postgresql"].opt_prefix}"
    end

    ENV.append "CPPFLAGS", "-fno-delete-null-pointer-checks"

    system "./bootstrap"
    # [ -f Makefile ] ||  ./configure --prefix=/usr --with-wx-version=3.0
    system "./configure", "--disable-debug", "--disable-dependency-tracking", *args
    system "make", "all"
    system "make", "install"

    if build.with? "app"
      (prefix/"pgAdmin3.app/Contents/PkgInfo").write "APPLPGADMIN3"
      mkdir "#{prefix}/pgAdmin3.app/Contents/Resources"
      cp_r "#{buildpath}/pkg/mac/pgAdmin3.icns", "#{prefix}/pgAdmin3.app/Contents/Resources/pgAdmin3.icns"
      cp_r "#{buildpath}/pkg/mac/sql.icns", "#{prefix}/pgAdmin3.app/Contents/Resources/sql.icns"

      config = <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
      	<key>CFBundleDevelopmentRegion</key>
      	<string>English</string>
      	<key>CFBundleDocumentTypes</key>
      	<array>
      		<dict>
      			<key>CFBundleTypeExtensions</key>
      			<array>
      				<string>sql</string>
      			</array>
      			<key>CFBundleTypeIconFile</key>
      			<string>sql.icns</string>
      			<key>CFBundleTypeName</key>
      			<string>pgAdmin3 SQL Query</string>
      			<key>CFBundleTypeRole</key>
      			<string>Editor</string>
      			<key>LSItemContentTypes</key>
      			<array>
      				<string>org.postgresql.pgadmin.sql</string>
      			</array>
      		</dict>
      	</array>
      	<key>CFBundleExecutable</key>
      	<string>pgadmin3</string>
      	<key>CFBundleGetInfoString</key>
      	<string>pgAdmin3 #{version}</string>
      	<key>CFBundleIconFile</key>
      	<string>pgAdmin3.icns</string>
      	<key>CFBundleIdentifier</key>
      	<string>org.postgresql.pgadmin</string>
      	<key>CFBundleInfoDictionaryVersion</key>
      	<string>6.0</string>
      	<key>CFBundlePackageType</key>
      	<string>APPL</string>
      	<key>CFBundleShortVersionString</key>
      	<string>#{version}</string>
      	<key>CFBundleSignature</key>
      	<string>????</string>
      	<key>CFBundleVersion</key>
      	<string>#{version}</string>
      	<key>CSResourcesFileMapped</key>
      	<true/>
      	<key>UTExportedTypeDeclarations</key>
      	<array>
      		<dict>
      			<key>UTTypeConformsTo</key>
      			<array>
      				<string>public.utf8-plain-text</string>
      			</array>
      			<key>UTTypeDescription</key>
      			<string>pgAdmin3 SQL Query</string>
      			<key>UTTypeIconFile</key>
      			<string>sql.icns</string>
      			<key>UTTypeIdentifier</key>
      			<string>org.postgresql.pgadmin.sql</string>
      			<key>UTTypeTagSpecification</key>
      			<dict>
      				<key>public.filename-extension</key>
      				<array>
      					<string>sql</string>
      				</array>
      			</dict>
      		</dict>
      	</array>
      </dict>
      </plist>
      EOS

      (prefix/"pgAdmin3.app/Contents/Info.plist").write config

      chdir "#{prefix}/pgAdmin3.app/Contents" do
        mkdir "MacOS" do
          ln_s "#{bin}/pgadmin3", "pgadmin3"
        end
      end
    end
  end

  def caveats
    if build.with? "app"
      <<~EOS
      pgAdmin.app was installed in:
        #{prefix}

      You may also symlink pgAdmin3.app into /Applications or ~/Applications:
        ln -Fs `find $(brew --prefix) -name "pgAdmin3.app"` /Applications/pgAdmin3.app

      EOS
    end
  end

  test do
    # TODO
  end
end

__END__

--- a/pgadmin/frm/plugins.cpp
+++ b/pgadmin/frm/plugins.cpp
@@ -380,7 +380,7 @@ bool pluginUtilityFactory::CheckEnable(p
 	{
 		// If we need a specific server type, we can't enable unless
 		// we have a connection.
-		if (!obj || !(obj->GetConnection()->GetStatus() == PGCONN_OK))
+		if (!obj || !obj->GetConnection() || !(obj->GetConnection()->GetStatus() == PGCONN_OK))
 			return false;

 		// Get the server type.

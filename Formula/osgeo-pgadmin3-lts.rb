class OsgeoPgadmin3Lts < Formula
  # include Language::Python::Virtualenv
  desc "Comprehensive design and management interface for PostgreSQL (LTS)"
  homepage "https://www.pgadmin.org"
  url "https://github.com/pgcentral/pgadmin3-lts/archive/7f3915ce4ccd5da7758ef6d2993cc8480e4aad3b.tar.gz"
  sha256 "65de9fb0d2bc43bfa0931832c344cfb894ae862acefefc64fbc8cd7d0f6cb7ff"
  version "1.22.3"

  revision 1

  head "https://github.com/pgcentral/pgadmin3-lts.git", :branch => "master"

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

  resource "pg11" do
    url "https://gist.githubusercontent.com/fjperini/712d8605f59590a8caefdb6e45b4b97e/raw/40cffed9c69802d861ae410ce299d72d61209e86/pgadmin3.diff"
    sha256 "eeafe9bb1f6aae02677a267af85a12a04d64a05fad544c55ca67044111a23f50"
  end

  def install
    # venv = virtualenv_create(libexec, "#{Formula["python@2"].opt_bin}/python2")
    # res = resources.map(&:name).to_set - %w[pg11]
    # res.each do |r|
    #   venv.pip_install resource(r)
    # end

    resource("pg11").stage do
      cp_r "./pgadmin3.diff", "#{buildpath}"
    end
    system "patch", "-p1", "-i", "#{buildpath}/pgadmin3.diff"

    args = [
      "--with-wx=#{Formula["wxmac"].opt_prefix}",
      "--with-wx-version=3.0",
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

    if build.with?("pg10")
      args << "--with-pgsql=#{Formula["osgeo-postgresql@10"].opt_prefix}"
    else
      args << "--with-pgsql=#{Formula["osgeo-postgresql"].opt_prefix}"
    end

    ENV.append "CPPFLAGS", "-fno-delete-null-pointer-checks"

    system "./bootstrap"
    # [ -f Makefile ] ||  ./configure --prefix=/usr --with-wx-version=3.0
    system "./configure", *args
    system "make"
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

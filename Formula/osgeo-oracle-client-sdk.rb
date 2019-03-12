require File.expand_path("../../Strategies/cache-download", Pathname.new(__FILE__).realpath)

class OsgeoOracleClientSdk < Formula
  desc "Oracle database C/C++ client libs, command-line tools and SDK"
  homepage "https://www.oracle.com/technetwork/topics/intel-macsoft-096467.html"
  url "https://osgeo4mac.s3.amazonaws.com/src/dummy.tar.gz"
  version (MacOS.version < :el_capitan) ? "12.1.0.2.0-2" : "12.2.0.1.0-2"
  sha256 "e7776e2ff278d6460300bd69a26d7383e6c5e2fbeb17ff12998255e7fc4c9511"

  # revision 1

  option "with-basic", "Install Oracle's Basic client, instead of Basic Lite"

  resource "basic" do
    if MacOS.version < :el_capitan
      url "file://#{HOMEBREW_CACHE}/instantclient-basic-macos.x64-12.1.0.2.0.zip",
          :using => CacheDownloadStrategy
      sha256 "71aa366c961166fb070eb6ee9e5905358c61d5ede9dffd5fb073301d32cbd20c"
      version "12.1.0.2.0-2"
    else
      url "file://#{HOMEBREW_CACHE}/instantclient-basic-macos.x64-12.2.0.1.0-2.zip",
          :using => CacheDownloadStrategy
      sha256 "04a84542b5bd0a04bc45445e220a67c959a8826ce987000270705f9a1d553157"
    end
  end

  resource "basic-lite" do
    if MacOS.version < :el_capitan
      url "file://#{HOMEBREW_CACHE}/instantclient-basiclite-macos.x64-12.1.0.2.0.zip",
          :using => CacheDownloadStrategy
      sha256 "c39d498fa6eb08d46014283a3a79bcaf63060cdbd0f58f97322da012350d4c39"
      version "12.1.0.2.0-2"
    else
      url "file://#{HOMEBREW_CACHE}/instantclient-basiclite-macos.x64-12.2.0.1.0-2.zip",
          :using => CacheDownloadStrategy
      sha256 "2997f753b61f8b445a241e99412c132feb76cf246dcca2e7837fe82b15c1efb8"
    end
  end

  resource "sdk" do
    if MacOS.version < :el_capitan
      url "file://#{HOMEBREW_CACHE}/instantclient-sdk-macos.x64-12.1.0.2.0.zip",
          :using => CacheDownloadStrategy
      sha256 "950153e53e1c163c51ef34eb8eb9b60b7f0da21120a86f7070c0baff44ef4ab9"
      version "12.1.0.2.0-2"
    else
      url "file://#{HOMEBREW_CACHE}/instantclient-sdk-macos.x64-12.2.0.1.0-2.zip",
          :using => CacheDownloadStrategy
      sha256 "e0befca9c4e71ebc9f444957ffa70f01aeeec5976ea27c40406471b04c34848b"
    end
  end

  resource "sqlplus" do
    if MacOS.version < :el_capitan
      url "file://#{HOMEBREW_CACHE}/instantclient-sqlplus-macos.x64-12.1.0.2.0.zip",
          :using => CacheDownloadStrategy
      sha256 "a663937e2e32c237bb03df1bda835f2a29bc311683087f2d82eac3a8ea569f81"
      version "12.1.0.2.0-2"
    else
      url "file://#{HOMEBREW_CACHE}/instantclient-sqlplus-macos.x64-12.2.0.1.0-2.zip",
          :using => CacheDownloadStrategy
      sha256 "d147cbb5b2a954fdcb4b642df4f0bd1153fd56e0f56e7fa301601b4f7e2abe0e"
    end
  end

  def fixup_rpaths(mach_bins)
    # mach_bins as [Pathname]
    mach_bins.each do |m|
      m = Pathname.new(m) if m.is_a?(String)
      next if m.symlink?
      m.ensure_writable do
        MachO::Tools.add_rpath(m.to_s, opt_lib.to_s, :strict => false)
        # will only affect dylibs
        MachO::Tools.change_dylib_id(m.to_s, (opt_lib/m.basename).to_s)
      end
    end
  end

  def oracle_env_vars
    {
      :ORACLE_HOME => opt_prefix,
      :OCI_LIB => opt_lib,
      :TNS_ADMIN => opt_prefix/"network/admin",
    }
  end

  def install
    resource(build.with?("basic") ? "basic" : "basic-lite").stage do
      oracle_exes = %w[adrci genezi uidrvci]
      ver_split = version.to_s.split(".")
      maj_ver = ver_split[0]
      min_ver = ver_split[1]

      # fix permissions
      chmod 0644, Dir["*"]
      chmod 0755, oracle_exes

      # fixup lib naming to macOS style with some symlinks
      if MacOS.version < :el_capitan
        %w[libclntsh libclntshcore libocci].each do |f|
          ln_sf "#{f}.dylib.#{maj_ver}.#{min_ver}", "#{f}.dylib"
        end
      end

      # install fixed-up libs and exes
      lib.install Dir["*.dylib*"]
      bin.install oracle_exes
    end

    # install headers in a logical subdirectory (since some are too generally named)
    resource("sdk").stage do
      cd "sdk" do
        Dir["**/*", "."].each do |f|
          chmod (File.directory?(f.to_s) ? 0755 : 0644), f
        end
        (include/"oci").install Dir["include/*"]
        rmdir "include"
        ln_sf "../include", "./"
      end
      prefix.install "sdk"
    end

    resource("sqlplus").stage do
      # fix permissions
      chmod 0644, Dir["*"]
      chmod 0755, "sqlplus"

      lib.install Dir["*.dylib"]
      bin.install "sqlplus"

      # Site Profile goes in $ORACLE_HOME/sqlplus/admin/glogin.sql
      (prefix/"sqlplus/admin").install "glogin.sql"
    end

    # fixup @rpath locations
    # update install names to opt_prefix (probably done by Homebrew as well)
    fixup_rpaths Dir[lib/"lib*", bin/"*"]

    # make any extra client paths
    (prefix/"network/admin").mkpath

    # wrap cmd line tools with Oracle env vars
    envvars = oracle_env_vars
    envvars[:NLS_LANG] = "AMERICAN_AMERICA.UTF8" if build.without? "basic"
    bin.env_script_all_files(libexec/"bin", envvars)
  end

  def caveats
    s = <<~EOS
      To build software with the Instant Client SDK, add to the following
      environment variable to find headers:

        [CFLAGS|CPPFLAGS]: -I#{opt_include}/oci

      Executables are wrapped with environ:
    EOS
    envvars = oracle_env_vars
    envvars[:NLS_LANG] = "AMERICAN_AMERICA.UTF8" if build.without? "basic"
    envvars.each { |k, v| s += "  #{k}=#{v}\n" }
    s += "\n"
  end

  test do
    # From GDAL 2.1.2's configure test
    (testpath/"test.cpp").write <<~EOS
    #include <oci.h>
    int main () {
      OCIEnv* envh = 0;
      OCIEnvCreate(&envh, OCI_DEFAULT, 0, 0, 0, 0, 0, 0);
      if (envh) OCIHandleFree(envh, OCI_HTYPE_ENV);
      return 0;
    }
    EOS
    system ENV.cxx, "test.cpp",
           "-I#{opt_include}/oci", "-L#{opt_lib}", "-lclntsh", "-o", "test"
    system "./test"
  end
end

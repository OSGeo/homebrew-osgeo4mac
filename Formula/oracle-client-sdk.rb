require "formula"
require File.expand_path("../../Strategies/cache-download", Pathname.new(__FILE__).realpath)

class OracleClientSdk < Formula
  homepage "http://www.oracle.com/technetwork/topics/intel-macsoft-096467.html"
  option "with-basic", "Intall Oracle's Basic client, instead of Basic Lite"
  revision 1

  if build.with? "basic"
    url "file://#{HOMEBREW_CACHE}/instantclient-basic-macos.x64-11.2.0.4.0.zip",
        :using => CacheDownloadStrategy
    sha1 "d9b5a1d13ecf2fca0317fc7b4964576a95990f08"
  else
    url "file://#{HOMEBREW_CACHE}/instantclient-basiclite-macos.x64-11.2.0.4.0.zip",
        :using => CacheDownloadStrategy
    sha1 "79f4b3090e15c392ef85626bb24793e57d02fe24"
  end

  resource "sdk" do
    url "file://#{HOMEBREW_CACHE}/instantclient-sdk-macos.x64-11.2.0.4.0.zip",
        :using => CacheDownloadStrategy
    sha1 "1c37a37e62d02bad7705d7e417810da7fda9bd0e"
  end

  def install
    # fix permissions
    quiet_system "chmod -R u+w,og-w ./*"

    # fixup libs
    mv "libclntsh.dylib.11.1", "libclntsh.dylib"
    mv "libocci.dylib.11.1", "libocci.dylib"
    %W[libclntsh.dylib libocci.dylib libnnz11.dylib].each do |f|
      quiet_system "install_name_tool", "-id", "#{f}", f
    end

    install_change("libclntsh.dylib",
                   "/ade/dosulliv_ldapmac/oracle/ldap/lib/libnnz11.dylib",
                   "@loader_path/libnnz11.dylib")

    lib.install %W[libclntsh.dylib libocci.dylib libnnz11.dylib]

    # fix exes
    oracle_exes = %W[adrci genezi uidrvci]
    oracle_exes.each do |b|
      install_change(b,
                     "/ade/b/3071542110/oracle/rdbms/lib/libclntsh.dylib.11.1",
                     "#{opt_lib}/libclntsh.dylib")
      install_change(b,
                     "/ade/dosulliv_ldapmac/oracle/ldap/lib/libnnz11.dylib",
                     "#{opt_lib}/libnnz11.dylib")
    end
    bin.install oracle_exes

    prefix.install Dir["*README"]
    resource("sdk").stage {prefix.install "sdk"}
  end

  def install_change(dylib, old, new)
    quiet_system "install_name_tool", "-change", old, new, dylib
  end

  def caveats; <<-EOS.undent
        To build software with the Instant Client SDK, add to the following
        environment variable to find headers:

          CPPFLAGS: -I#{opt_prefix}/sdk/include

        ============================== IMPORTANT ==================================
        If linking with other software built on 10.9+, clang links to libc++, whereas
        Instant Client libs/binaries link to libstdc++. This may lead to build
        failures or issues during usage, including crashes.

    EOS
  end
end

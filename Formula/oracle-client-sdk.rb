require File.expand_path("../../Strategies/cache-download", Pathname.new(__FILE__).realpath)

class OracleClientSdk < Formula
  homepage "http://www.oracle.com/technetwork/topics/intel-macsoft-096467.html"
  option "with-basic", "Intall Oracle's Basic client, instead of Basic Lite"
  revision 1

  if build.with? "basic"
    url "file://#{HOMEBREW_CACHE}/instantclient-basic-macos.x64-11.2.0.4.0.zip",
        :using => CacheDownloadStrategy
    sha256 "6c079713ab0a65193f7bfcbad6c90e7806fa6634a3828052f8428e1533bb89d3"
  else
    url "file://#{HOMEBREW_CACHE}/instantclient-basiclite-macos.x64-11.2.0.4.0.zip",
        :using => CacheDownloadStrategy
    sha256 "8ebc4baafb40a3b7145d48a4be86747766fdb3e1e0ac7cdd397e852164fa2189"
  end

  resource "sdk" do
    url "file://#{HOMEBREW_CACHE}/instantclient-sdk-macos.x64-11.2.0.4.0.zip",
        :using => CacheDownloadStrategy
    sha256 "da1aefeda37fcb06f45e7f1f6907448da2e861945109602e0af34c8d5f38acde"
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

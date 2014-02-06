require "formula"
require File.expand_path("../../Strategies/cache-download", Pathname.new(__FILE__).realpath)

class OracleClientSdk < Formula
  homepage "http://www.oracle.com/technetwork/topics/intel-macsoft-096467.html"
  option "with-basic", "Intall Oracle's Basic client, instead of Basic Lite"

  if build.with? "basic"
    url "file://#{HOMEBREW_CACHE}/instantclient-basic-macos.x64-11.2.0.3.0.zip",
        :using => CacheDownloadStrategy
    sha1 "451fe2e8b9e92ad45760880116792ae31a4f0174"
  else
    url "file://#{HOMEBREW_CACHE}/instantclient-basiclite-macos.x64-11.2.0.3.0.zip",
        :using => CacheDownloadStrategy
    sha1 "22794c7ee551ffc3a8b21fb7c151a3e1c14833a8"
  end

  resource "sdk" do
    url "file://#{HOMEBREW_CACHE}/instantclient-sdk-macos.x64-11.2.0.3.0.zip",
        :using => CacheDownloadStrategy
    sha1 "95875708dec52155aa6b6f66550b805fd0875c26"
  end

  def install
    oracle_opt_lib = opt_prefix/"lib"
    oracle_exes = %W[adrci genezi uidrvci]

    prefix.install Dir["*README"]
    lib.install "libclntsh.dylib.11.1" => "libclntsh.dylib"
    lib.install "libocci.dylib.11.1" => "libocci.dylib"
    lib.install "libnnz11.dylib"
    install_change(lib/"libclntsh.dylib",
                   "/ade/b/2649109290/oracle/ldap/lib/libnnz11.dylib",
                   "@loader_path/libnnz11.dylib")

    bin.install oracle_exes
    oracle_exes.each do |b|
      install_change(bin/"#{b}",
                   "/ade/b/2649109290/oracle/rdbms/lib/libclntsh.dylib.11.1",
                   "#{oracle_opt_lib}/libclntsh.dylib")
      install_change(bin/"#{b}",
                   "/ade/b/2649109290/oracle/ldap/lib/libnnz11.dylib",
                   "#{oracle_opt_lib}/libnnz11.dylib")
    end

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

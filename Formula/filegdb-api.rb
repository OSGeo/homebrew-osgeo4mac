require "formula"
require File.expand_path("../../Strategies/cache-download", Pathname.new(__FILE__).realpath)

class FilegdbApi < Formula
  homepage "http://www.esri.com/software/arcgis/geodatabase/interoperability"
  url "file://#{HOMEBREW_CACHE}/FileGDB_API_1_3-64.zip",
      :using => CacheDownloadStrategy
  sha1 "95ba7e3da555508c8be10b8dbb6ad88a71b03f49"
  version "1.3"

  option "with-docs", "Intall API documentation and examples"

  def install
    prefix.install %W[lib license]
    include.install "include" => "filegdb"
    if build.with? "docs"
      (share/"filegdb-api").install %W[samples xmlResources]
      (share/"filegdb-api").install "doc/html" => "html"
    end

    # update libs
    install_change lib/"libFileGDBAPI.dylib",
                   "@rpath/libfgdbunixrtl.dylib",
                   "@loader_path/libfgdbunixrtl.dylib"
  end

  def install_change(dylib, old, new)
    quiet_system "install_name_tool", "-change", old, new, dylib
  end

  def caveats; <<-EOS.undent
        To build software with the File GDB API, add to the following
        environment variable to find headers:

          CPPFLAGS: -I#{opt_prefix}/include/filegdb

        ============================== IMPORTANT ==================================
        If linking with other software built on 10.9+, clang links to libc++, whereas
        File GDB API libs/binaries link to libstdc++. This may lead to build
        failures or issues during usage, including crashes.

    EOS
  end
end

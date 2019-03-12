class OsgeoFilegdbApi < Formula
  desc "ESRI File Geodatabase C++ API libraries"
  homepage "https://github.com/Esri/file-geodatabase-api"
  url "https://github.com/Esri/file-geodatabase-api/raw/master/FileGDB_API_1.5.1/FileGDB_API_1_5_1-64clang.zip"
  sha256 "78b52650b3be72eacb985fd744f6766e8d57f60a3317055c5a23b1d181ae8ab2"
  version "1.5.1"

  revision 1

  head "https://github.com/Esri/file-geodatabase-api.git", :branch => "master"

  option "with-docs", "Intall API documentation and sample code"

  def install
    prefix.install %w[lib license]
    # update libs
    cd lib do
      install_change "libFileGDBAPI.dylib",
                     "@rpath/libfgdbunixrtl.dylib",
                     "@loader_path/libfgdbunixrtl.dylib"
      set_install_name("libFileGDBAPI.dylib", opt_lib)
    end

    # build a sample for testing libs
    # Note: Editing sample failed in test sandbox; worked in Terminal
    mkdir_p libexec/"test/bin"
    mkdir libexec/"test/data"
    cp_r "samples/data/Querying.gdb", libexec/"test/data/"
    cd "samples/Querying" do
      inreplace "Makefile", "../../lib", lib
      inreplace "Makefile", "../bin", "#{libexec}/test/bin"
      system "make"
    end

    # install headers (after building test binary)
    rm_f "include/make.include"
    include.install "include" => "filegdb"

    if build.with? "docs"
      pkgshare.install %w[samples xmlResources]
      pkgshare.install "doc/html" => "html"
    end
  end

  def install_change(dylib, old, new)
    quiet_system "install_name_tool", "-change", old, new, dylib
  end

  def set_install_name(dylib, dir)
    quiet_system "install_name_tool", "-id", "#{dir}/#{dylib}", dylib
  end

  def caveats; <<~EOS
      To build software with the File GDB API, add to the following
      environment variable to find headers:

        CPPFLAGS: -I#{opt_prefix}/include/filegdb

    EOS
  end

  test do
    cd libexec/"test/bin" do
      system "./Querying"
    end
  end
end

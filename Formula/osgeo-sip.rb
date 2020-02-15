class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_sip_linked }

  def core_sip_linked
    Formula["sip"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink sip\e[0m or remove with brew \e[32muninstall --ignore-dependencies sip\e[0m\n\n" if core_sip_linked
    s
  end
end


class OsgeoSip < Formula
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/sip/4.19.21/sip-4.19.21.tar.gz"
  sha256 "6af9979ab41590e8311b8cc94356718429ef96ba0e3592bdd630da01211200ae"

  revision 2

  head "https://www.riverbankcomputing.com/hg/sip", :using => :hg

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    sha256 "85c2a7a70ebeb3e4ebfaa97df2848bd04948d292bfe930dfc59a44ab6c3bcfc8" => :catalina
    sha256 "85c2a7a70ebeb3e4ebfaa97df2848bd04948d292bfe930dfc59a44ab6c3bcfc8" => :mojave
    sha256 "85c2a7a70ebeb3e4ebfaa97df2848bd04948d292bfe930dfc59a44ab6c3bcfc8" => :high_sierra
  end

  # keg_only "sip" is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "python"

  def install
    ENV.prepend_path "PATH", Formula["python"].opt_libexec/"bin"
    ENV.delete("SDKROOT") # Avoid picking up /Application/Xcode.app paths

    if build.head?
      # Link the Mercurial repository into the download directory so
      # build.py can use it to figure out a version number.
      ln_s cached_download/".hg", ".hg"
      # build.py doesn't run with python3
      system "python3", "build.py", "prepare"
    end

    version = Language::Python.major_minor_version "python3"
    system "python3", "configure.py",
                   "--deployment-target=#{MacOS.version}",
                   "--destdir=#{lib}/python#{version}/site-packages",
                   "--bindir=#{bin}",
                   "--incdir=#{include}",
                   "--sipdir=#{HOMEBREW_PREFIX}/share/sip",
                   "--sip-module=PyQt5.sip",
                   "--no-dist-info"
    system "make"
    system "make", "install"
    system "make", "clean"
  end

  def post_install
    (HOMEBREW_PREFIX/"share/sip").mkpath
  end

  def caveats; <<~EOS
    The sip-dir for Python is #{HOMEBREW_PREFIX}/share/sip.
  EOS
  end

  test do
    (testpath/"test.h").write <<~EOS
      #pragma once
      class Test {
      public:
        Test();
        void test();
      };
    EOS
    (testpath/"test.cpp").write <<~EOS
      #include "test.h"
      #include <iostream>
      Test::Test() {}
      void Test::test()
      {
        std::cout << "Hello World!" << std::endl;
      }
    EOS
    (testpath/"test.sip").write <<~EOS
      %Module test
      class Test {
      %TypeHeaderCode
      #include "test.h"
      %End
      public:
        Test();
        void test();
      };
    EOS

    system ENV.cxx, "-shared", "-Wl,-install_name,#{testpath}/libtest.dylib",
                    "-o", "libtest.dylib", "test.cpp"
    system bin/"sip", "-b", "test.build", "-c", ".", "test.sip"

    version = Language::Python.major_minor_version "python3"
    ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
    system "python3", "-c", '"import PyQt5.sip"'
  end
end

class SipQt4 < Formula
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://downloads.sourceforge.net/project/pyqt/sip/sip-4.18.1/sip-4.18.1.tar.gz"
  sha256 "9bce7a2dbf7f105bf68ad1bab58eebc0ce33087ec40396da756463f086ffa290"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    cellar :any_skip_relocation
    sha256 "4c95142a42599fb0b6668e50e49913f19d0462ee05590aa9844cbc41cba6e350" => :high_sierra
    sha256 "4c95142a42599fb0b6668e50e49913f19d0462ee05590aa9844cbc41cba6e350" => :sierra
  end

  depends_on "python@2" => :recommended

  def install
    if build.without? "python@2"
      # this is a flaw in Homebrew, where `depends on :python` alone does not work
      odie "Must be built with Python2"
    end

    Language::Python.each_python(build) do |python, version|
      # Note the binary `sip` is the same for python 2.x and 3.x
      system python, "configure.py",
                     "--deployment-target=#{MacOS.version}",
                     "--destdir=#{lib}/qt-4/python#{version}/site-packages",
                     "--bindir=#{libexec}/bin",
                     "--incdir=#{libexec}/include",
                     "--sipdir=#{HOMEBREW_PREFIX}/share/#{name}"
      system "make"
      system "make", "install"
      system "make", "clean"
    end
  end

  def post_install
    (HOMEBREW_PREFIX/"share/#{name}").mkpath
  end

  def caveats
    s = "sip executable installed in #{opt_libexec}/bin\n\n"
    s += "sip headers installed in #{opt_libexec}/include\n\n"
    s += "sip-dir for Python installed at #{HOMEBREW_PREFIX}/share/#{name}\n\n"
    s += "Python modules installed in:\n"
    Language::Python.each_python(build) do |_python, version|
      s += "  #{HOMEBREW_PREFIX}/lib/qt-4/python#{version}/site-packages/PyQt4"
    end
    s
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
    (testpath/"generate.py").write <<~EOS
      from sipconfig import SIPModuleMakefile, Configuration
      m = SIPModuleMakefile(Configuration(), "test.build")
      m.extra_libs = ["test"]
      m.extra_lib_dirs = ["."]
      m.generate()
    EOS
    (testpath/"run.py").write <<~EOS
      from test import Test
      t = Test()
      t.test()
    EOS
    system ENV.cxx, "-shared", "-Wl,-install_name,#{testpath}/libtest.dylib",
                    "-o", "libtest.dylib", "test.cpp"
    system libexec/"bin/sip", "-b", "test.build", "-c", ".", "test.sip"
    Language::Python.each_python(build) do |python, version|
      ENV["PYTHONPATH"] = lib/"qt-4/python#{version}/site-packages"
      system python, "generate.py"
      system "make", "-j1", "clean", "all"
      system python, "run.py"
    end
  end
end

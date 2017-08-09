class SipQt4 < Formula
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://downloads.sourceforge.net/project/pyqt/sip/sip-4.18.1/sip-4.18.1.tar.gz"
  sha256 "9bce7a2dbf7f105bf68ad1bab58eebc0ce33087ec40396da756463f086ffa290"
  revision 1

  bottle do
    root_url "http://qgis.dakotacarto.com/bottles"
    cellar :any_skip_relocation
    sha256 "89707434e7db3a26ff167bdae484388df20d41f1765a75471d6159eeb39b4be3" => :sierra
  end

  depends_on :python => :recommended

  def install
    if build.without? "python"
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
    (testpath/"test.h").write <<-EOS.undent
      #pragma once
      class Test {
      public:
        Test();
        void test();
      };
    EOS
    (testpath/"test.cpp").write <<-EOS.undent
      #include "test.h"
      #include <iostream>
      Test::Test() {}
      void Test::test()
      {
        std::cout << "Hello World!" << std::endl;
      }
    EOS
    (testpath/"test.sip").write <<-EOS.undent
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
    (testpath/"generate.py").write <<-EOS.undent
      from sipconfig import SIPModuleMakefile, Configuration
      m = SIPModuleMakefile(Configuration(), "test.build")
      m.extra_libs = ["test"]
      m.extra_lib_dirs = ["."]
      m.generate()
    EOS
    (testpath/"run.py").write <<-EOS.undent
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

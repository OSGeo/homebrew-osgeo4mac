class SipQt4 < Formula
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://downloads.sourceforge.net/project/pyqt/sip/sip-4.18.1/sip-4.18.1.tar.gz"
  sha256 "9bce7a2dbf7f105bf68ad1bab58eebc0ce33087ec40396da756463f086ffa290"

  bottle do
    root_url "http://qgis.dakotacarto.com/bottles"
    cellar :any_skip_relocation
    sha256 "1b92f95ef03f583560ca206321f3369ae04781b5e1b7770893f3ab43b367d52e" => :sierra
  end

  keg_only "Newer (possibly Qt5-only) version in homebrew-core"

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
                     "--bindir=#{bin}",
                     "--incdir=#{include}",
                     "--sipdir=#{HOMEBREW_PREFIX}/share/sip"
      system "make"
      system "make", "install"
      system "make", "clean"
    end

    post_install
  end

  def post_install
    (HOMEBREW_PREFIX/"share/sip").mkpath
    # do symlinking of keg-only here, since `brew doctor` complains about it
    # and user may need to re-link again after following suggestion to unlink
    Language::Python.each_python(build) do |_python, version|
      subpth = "qt-4/python#{version}/site-packages"
      hppth = HOMEBREW_PREFIX/"lib/#{subpth}"
      hppth.mkpath
      cd lib/subpth do
        Dir["sip*"].each { |f| ln_sf "#{opt_lib.relative_path_from(hppth)}/#{subpth}/#{f}", "#{hppth}/" }
      end
    end
  end

  def caveats
    s = "The sip-dir for Python is #{HOMEBREW_PREFIX}/share/sip.\n\n"
    s += "Python modules in:\n"
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
    system ENV.cxx, "-shared", "-Wl,-install_name,#{testpath}/libtest.dylib",
                    "-o", "libtest.dylib", "test.cpp"
    system bin/"sip", "-b", "test.build", "-c", ".", "test.sip"
    Language::Python.each_python(build) do |python, version|
      site_pkgs = "#{HOMEBREW_PREFIX}/lib/qt-4/python#{version}/site-packages"
      (testpath/"generate.py").write <<-EOS.undent
      import site; site.addsitedir("#{site_pkgs}")
      from sipconfig import SIPModuleMakefile, Configuration
      m = SIPModuleMakefile(Configuration(), "test.build")
      m.extra_libs = ["test"]
      m.extra_lib_dirs = ["."]
      m.generate()
      EOS
      system python, "generate.py"
      system "make", "-j1", "clean", "all"
      (testpath/"run.py").write <<-EOS.undent
      import site; site.addsitedir("#{site_pkgs}")
      from test import Test
      t = Test()
      t.test()
      EOS
      system python, "run.py"
    end
  end
end

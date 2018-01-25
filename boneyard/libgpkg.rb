require "formula"

class RubyVersion19 < Requirement
  fatal true
  satisfy(:build_env => false) { %x(ruby -e 'print RUBY_VERSION').strip.to_f >= 1.9 }

  def message; <<~EOS
      Ruby >= 1.9 is required to run tests, which utilize Encoding class.
      Install without `--with-tests` option.
  EOS
  end
end

class Libgpkg < Formula
  homepage "https://bitbucket.org/luciad/libgpkg"
  url "https://bitbucket.org/luciad/libgpkg/get/0.9.15.tar.gz"
  sha1 "1c42c36c0fd0b043b532efe11208652f581aa52c"

  head "https://bitbucket.org/luciad/libgpkg", :using => :hg, :branch => "default"

  option "with-tests", "Run unit tests after build, prior to install"

  depends_on "cmake" => :build
  depends_on "geos" => :recommended
  if build.with? "tests"
    depends_on RubyVersion19
    depends_on "ruby" => :build
    depends_on "bundler" => :ruby
  end

  def install
    args = std_cmake_args
    args << "-DGPKG_GEOS=ON" if build.with? "geos"
    args << "-DGPKG_TEST=ON" if build.with? "tests"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      IO.popen("make test") {|io| io.each {|s| print s}} if build.with? "tests"
      system "make", "install"
    end
  end

  def caveats; <<~EOS
      Custom SQLite command-line shell that autoloads static GeoPackage extension:
        #{opt_prefix}/bin/gpkg

      Make sure to review Usage (extension loading) and Function Reference docs:
        https://bitbucket.org/luciad/libgpkg/wiki/Home

  EOS
  end
end

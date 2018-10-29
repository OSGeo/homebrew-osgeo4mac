class NoGdal2Python < Requirement
  fatal true
  satisfy(:build_env => false) { !Gdal2Python.gdal2_py2_exist? && !Gdal2Python.gdal2_py3_exist? }

  def message
    s = "`gdal2` formula already installed with Python 2 or 3 bindings:\n"
    s += "  #{Gdal2Python.gdal2_python("python@2")}\n" if Gdal2Python.gdal2_py2_exist?
    s += "  #{Gdal2Python.gdal2_python("python")}\n" if Gdal2Python.gdal2_py3_exist?
    s += "`gdal2` install options:\n"
    s += "  gdal2 #{Gdal2Python.gdal2_opts.to_a.join(" ")}\n"
    s += "Install latest `gdal2`, which installs no Python bindings:\n"
    s + "  `brew reinstall gdal2` or `brew upgrade gdal2`"
  end
end

class Gdal2Python < Formula
  def self.gdal2
    Formula["gdal2"]
  end

  def gdal2
    self.class.gdal2
  end

  def self.gdal2_opts
    tab = Tab.for_formula(gdal2)
    tab.used_options
  end

  def gdal2_opts
    self.class.gdal2_opts
  end

  def self.gdal2_python(python)
    py_ver = Language::Python.major_minor_version(python)
    gdal2.opt_lib/"python#{py_ver}"
  end

  def self.gdal2_py2_exist?
    gdal2_python("python@2").exist?
  end

  def self.gdal2_py3_exist?
    gdal2_python("python").exist?
  end

  desc "Python bindings for GDAL: Geospatial Data Abstraction Library"
  homepage "https://pypi.python.org/pypi/GDAL"
  url "http://download.osgeo.org/gdal/2.3.2/gdal-2.3.2.tar.gz"
  sha256 "7808dd7ea7ee19700a133c82060ea614d4a72edbf299dfcb3713f5f79a909d64"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "7bb2bffc5fc8a5c8ff2320c94bea4ab11f39c0903f774d274b07be3cc5788563" => :mojave
    sha256 "7bb2bffc5fc8a5c8ff2320c94bea4ab11f39c0903f774d274b07be3cc5788563" => :high_sierra
    sha256 "7bb2bffc5fc8a5c8ff2320c94bea4ab11f39c0903f774d274b07be3cc5788563" => :sierra
  end
  
  head do
    url "https://svn.osgeo.org/gdal/trunk/gdal"
    depends_on "doxygen" => :build
  end

  keg_only "older version of gdal is in main tap and installs similar components"

  depends_on "swig" => :build
  depends_on "gdal2"
  depends_on NoGdal2Python
  depends_on "python@2" => :recommended
  depends_on "python" => :recommended
  depends_on "numpy"

  resource "autotest" do
    url "http://download.osgeo.org/gdal/2.3.2/gdalautotest-2.3.2.tar.gz"
    sha256 "e27e7ba2218e4202be66b4b4c4e012d005a03ff44db28d7c603a19da184e8c13"
  end

  def install
    if build.without?("python@2") && build.without?("python")
      odie "Must choose a version of Python bindings to build"
    end

    cd "swig/python" do
      # Customize to gdal2 install opt_prefix
      inreplace "setup.cfg" do |s|
        s.sub! "../../apps/gdal-config", "#{gdal2.opt_bin}/gdal-config"
      end
      ENV.prepend "LDFLAGS", "-L#{gdal2.opt_lib}" # or gdal1 lib will be found

      # Check for GNM support
      (Pathname.pwd/"setup_vars.ini").write "GNM_ENABLED=yes\n" unless gdal2_opts.include? "without-gnm"

      Language::Python.each_python(build) do |python, _python_version|
        system python, *Language::Python.setup_install_args(prefix)
        system "echo", "#{opt_prefix}/lib/python#{_python_version}/site-packages",
                ">", "#{lib}/python#{_python_version}/site-packages/#{name}.pth"
      end

      # Scripts compatible with Python3? Appear to be...
      bin.install Dir["scripts/*"]
      # Clean up any stray doxygen files.
      Dir.glob("#{bin}/*.dox") { |p| rm p }
      # Add sample Python scripts
      (libexec/"bin").install Dir["samples/*"]
      chmod 0555, Dir[libexec/"bin/*.py"] # some randomly have no exec bit set
    end
  end

  def caveats; <<~EOS
    Sample Python scripts installed to:
      #{opt_libexec}/bin

    To run full test suite use:
      `brew test -v #{name} --with-autotest`
    EOS
  end

  test do
    Language::Python.each_python(build) do |python, python_version|
      next unless (lib/"python#{python_version}/site-packages").exist?
      ENV["PYTHONPATH"] = lib/"python#{python_version}/site-packages"
      pkgs = %w[gdal ogr osr gdal_array gdalconst]
      pkgs << "gnm" unless gdal2_opts.include? "without-gnm"
      system python, "-c", "from osgeo import #{pkgs.join ","}"
    end

    if ENV["GDAL_AUTOTEST"]
      ENV.prepend_path "PATH", gdal2.opt_bin.to_s
      ENV["GDAL_DRIVER_PATH"] = "#{HOMEBREW_PREFIX}/lib/gdalplugins"
      ENV["GDAL_DATA"] = "#{gdal2.opt_share}/gdal"
      ENV["GDAL_DOWNLOAD_TEST_DATA"] = "YES"
      # These driver tests cause hard failures, stopping test output
      ENV["GDAL_SKIP"] = "GRASS"
      ENV["OGR_SKIP"] = "ElasticSearch,GFT,OGR_GRASS"
      Language::Python.each_python(build) do |python, python_version|
        ENV["PYTHONPATH"] = opt_lib/"python#{python_version}/site-packages"
        resource("autotest").stage do
          # Split up tests, to reduce chance of execution expiration
          # ogr gcore gdrivers osr alg gnm utilities pyscripts
          %w[ogr gcore gdrivers osr alg gnm utilities pyscripts].each do |t|
            begin
              system python, "run_all.py", t.to_s
            rescue
              next
            end
          end
        end
        # Run autotest just once, with first found binding
        break
      end
    else
      ohai "To run full test suite use:\n\n    `GDAL_AUTOTEST=1 brew test -v #{name}`\n"
    end
  end
end

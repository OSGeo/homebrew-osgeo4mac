class NoGdal2Python < Requirement
  fatal true
  satisfy(:build_env => false) { !Gdal2Python.gdal2_py2_exist? && !Gdal2Python.gdal2_py3_exist? }

  def message
    s = "`gdal2` formula already installed with Python 2 or 3 bindings:\n"
    s += "  #{Gdal2Python.gdal2_python("python")}\n" if Gdal2Python.gdal2_py2_exist?
    s += "  #{Gdal2Python.gdal2_python("python3")}\n" if Gdal2Python.gdal2_py3_exist?
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
    gdal2_python("python").exist?
  end

  def self.gdal2_py3_exist?
    gdal2_python("python3").exist?
  end

  desc "Python bindings for GDAL: Geospatial Data Abstraction Library"
  homepage "https://pypi.python.org/pypi/GDAL"
  url "http://download.osgeo.org/gdal/2.2.1/gdal-2.2.1.tar.gz"
  sha256 "61837706abfa3e493f3550236efc2c14bd6b24650232f9107db50a944abf8b2f"

  bottle do
    root_url "http://qgis.dakotacarto.com/bottles"
    sha256 "56e0414060ed93452c41528beaa646d4472e2a8ed8995bd8eee63c0697c2e94d" => :sierra
  end

  keg_only "older version of gdal is in main tap and installs similar components"

  option "without-python", "Build without Python2 support"
  option "with-python3", "Build with Python3 support"

  depends_on "swig" => :build
  depends_on "gdal2"
  depends_on NoGdal2Python
  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on "numpy" => :python if build.with? "python"
  depends_on "numpy" => :python3 if build.with? "python3"

  resource "autotest" do
    url "http://download.osgeo.org/gdal/2.2.1/gdalautotest-2.2.1.tar.gz"
    sha256 "c0ee73b5f6336def92305b0a350351e29dafe3e8f9fbd0607243eea77efb42ab"
  end

  def install
    if build.without?("python") && build.without?("python3")
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

  def caveats; <<-EOS.undent
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

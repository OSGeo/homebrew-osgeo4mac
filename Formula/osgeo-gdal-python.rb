class OsgeoGdalPython < Formula
  def self.gdal2
    Formula["osgeo-gdal"]
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
  url "https://github.com/OSGeo/gdal/releases/download/v3.0.4/gdal-3.0.4.tar.gz"
  sha256 "fc15d2b9107b250305a1e0bd8421dd9ec1ba7ac73421e4509267052995af5e83"

  revision 1

  head "https://github.com/OSGeo/gdal.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "e2b33b60e28f1784e373a66e44d1d72c7b40ea3825e033b7a0f732ea69f31640" => :catalina
    sha256 "e2b33b60e28f1784e373a66e44d1d72c7b40ea3825e033b7a0f732ea69f31640" => :mojave
    sha256 "e2b33b60e28f1784e373a66e44d1d72c7b40ea3825e033b7a0f732ea69f31640" => :high_sierra
  end

  keg_only "older version of gdal is in main tap and installs similar components"

  depends_on "swig" => :build
  depends_on "python@3.8" => :recommended
  depends_on "numpy"
  depends_on "osgeo-gdal"

  resource "autotest" do
    url "https://download.osgeo.org/gdal/3.0.4/gdalautotest-3.0.4.tar.gz"
    sha256 "25378749513f849a5e3020cef34cf4188c2123b081712596e0d9a5b6de1fb3c5"
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

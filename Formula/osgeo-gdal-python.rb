class OsgeoGdalPython < Formula
  def self.gdal
    Formula["osgeo-gdal"]
  end

  def gdal
    self.class.gdal
  end

  def self.gdal_opts
    tab = Tab.for_formula(gdal)
    tab.used_options
  end

  def gdal_opts
    self.class.gdal_opts
  end

  def self.gdal_python(python)
    py_ver = Language::Python.major_minor_version(python)
    gdal.opt_lib/"python#{py_ver}"
  end

  def self.gdal_py3_exist?
    gdal_python("python").exist?
  end

  desc "Python bindings for GDAL: Geospatial Data Abstraction Library"
  homepage "https://pypi.python.org/pypi/GDAL"
  url "https://download.osgeo.org/gdal/3.1.1/gdal-3.1.1.tar.xz"
  sha256 "97154a606339a6c1d87c80fb354d7456fe49828b2ef9a3bc9ed91771a03d2a04"

  #revision 2 

  head "https://github.com/OSGeo/gdal.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "425b32cc4cbffc646d59c58bcf1c8fdb2fa997edd79726d54fe630b1788cd9f2" => :catalina
    sha256 "425b32cc4cbffc646d59c58bcf1c8fdb2fa997edd79726d54fe630b1788cd9f2" => :mojave
    sha256 "425b32cc4cbffc646d59c58bcf1c8fdb2fa997edd79726d54fe630b1788cd9f2" => :high_sierra
  end

  keg_only "older version of gdal is in main tap and installs similar components"

  depends_on "swig" => :build
  depends_on "python" => :recommended
  depends_on "numpy"
  depends_on "osgeo-gdal"

  resource "autotest" do
    url "https://download.osgeo.org/gdal/3.1.1/gdalautotest-3.1.1.tar.gz"
    sha256 "9b6571bdefbfb5f8326214cc7cae04399c1ddaeaccdb24ba77f91cf8282bd9a1"
  end

  def install

    cd "swig/python" do
      # Customize to gdal install opt_prefix
      inreplace "setup.cfg" do |s|
        s.sub! "../../apps/gdal-config", "#{gdal.opt_bin}/gdal-config"
      end
      ENV.prepend "LDFLAGS", "-L#{gdal.opt_lib}" # or gdal1 lib will be found

      # Check for GNM support
      (Pathname.pwd/"setup_vars.ini").write "GNM_ENABLED=yes\n" unless gdal_opts.include? "without-gnm"

      python_version = Language::Python.major_minor_version "python3"

      system "python3", *Language::Python.setup_install_args(prefix)
      system "echo", "#{opt_prefix}/lib/python#{python_version}/site-packages",
             ">", "#{lib}/python#{python_version}/site-packages/#{name}.pth"

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
    python_version = Language::Python.major_minor_version "python3"

    next unless (lib/"python#{python_version}/site-packages").exist?
    ENV["PYTHONPATH"] = lib/"python#{python_version}/site-packages"
    pkgs = %w[gdal ogr osr gdal_array gdalconst]
    pkgs << "gnm" unless gdal_opts.include? "without-gnm"
    system "python3", "-c", "from osgeo import #{pkgs.join ","}"

    if ENV["GDAL_AUTOTEST"]
      ENV.prepend_path "PATH", gdal.opt_bin.to_s
      ENV["GDAL_DRIVER_PATH"] = "#{HOMEBREW_PREFIX}/lib/gdalplugins"
      ENV["GDAL_DATA"] = "#{gdal.opt_share}/gdal"
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
              system "python3", "run_all.py", t.to_s
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

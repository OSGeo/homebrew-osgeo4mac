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
  url "https://download.osgeo.org/gdal/3.1.2/gdal-3.1.2.tar.xz"
  sha256 "767c8d0dfa20ba3283de05d23a1d1c03a7e805d0ce2936beaff0bb7d11450641"

  #revision 2 

  head "https://github.com/OSGeo/gdal.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "8e2ddaec0874f61df018c622cbf465985ae4dde2171d280464d15d02c72af192" => :catalina
    sha256 "8e2ddaec0874f61df018c622cbf465985ae4dde2171d280464d15d02c72af192" => :mojave
    sha256 "8e2ddaec0874f61df018c622cbf465985ae4dde2171d280464d15d02c72af192" => :high_sierra
  end

  keg_only "older version of gdal is in main tap and installs similar components"

  depends_on "swig" => :build
  depends_on "python" => :recommended
  depends_on "numpy"
  depends_on "osgeo-gdal"

  resource "autotest" do
    url "https://download.osgeo.org/gdal/3.1.2/gdalautotest-3.1.2.tar.gz"
    sha256 "bf2b87acc8db0d59a3e44302a0e3b749dcd50ee642843f96c3db35b7e9ccb215"
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

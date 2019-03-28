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
  url "https://download.osgeo.org/gdal/2.4.1/gdal-2.4.1.tar.gz"
  sha256 "f1a11d1982205b9e4cc10e16f016a5559bfc9fa9a9ea69015e99ccd6a738ea4c"

  # revision 1

  head "https://github.com/OSGeo/gdal.git", :branch => "master"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "a65ab22f08eec98532e8d9b08083910783c98470a3fc327795ab4d3854da6181" => :mojave
    sha256 "a65ab22f08eec98532e8d9b08083910783c98470a3fc327795ab4d3854da6181" => :high_sierra
    sha256 "84acfda7921258909a73d4251c875c81eba79862fa455f61afb8394bebea0da4" => :sierra
  end

  keg_only "older version of gdal is in main tap and installs similar components"

  depends_on "swig" => :build
  depends_on "python@2" => :recommended
  depends_on "python" => :recommended
  depends_on "numpy"
  depends_on "osgeo-gdal"

  resource "autotest" do
    url "https://download.osgeo.org/gdal/2.4.1/gdalautotest-2.4.1.tar.gz"
    sha256 "ce70807792f35f66f0f3dfa0e2d41071bf845d9b65cebd97279620cf90a30603"
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

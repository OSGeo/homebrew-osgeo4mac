class NoGdal2Python < Requirement
  fatal true
  satisfy(:build_env => false) { !Gdal2Python.gdal2_py2_exist? && !Gdal2Python.gdal2_py3_exist? }

  def message
    s = "`gdal2` formula already installed with Python 2 or 3 bindings:\n"
    s += "  #{gdal2_python("python")}\n" if Gdal2Python.gdal2_py2_exist?
    s += "  #{gdal2_python("python3")}\n" if Gdal2Python.gdal2_py3_exist?
    s += "`gdal2` install options:\n"
    s += "  gdal2 #{gdal2_opts.to_a.join(" ")}\n"
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
  url "https://pypi.python.org/packages/d1/98/27fff31ad298f3ec50db19dc3adfd8387279e158b1c6331c531c5fc7d830/GDAL-2.1.0.tar.gz"
  sha256 "eca0fb3b94168370e06dc32c8bc74b5383e73b65ca784180c434adbba35b70d9"

  keg_only "Older version of gdal is in main tap and installs similar components"

  option "without-python", "Build without Python2 support"
  option "with-python3", "Build with Python3 support"

  depends_on "swig" => :build
  depends_on "gdal2"
  depends_on NoGdal2Python
  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on "numpy" => :python if build.with? "python"
  depends_on "numpy" => :python3 if build.with? "python3"

  def install
    if build.without?("python") && build.without?("python3")
      odie "Must choose a version of Python bindings to build"
    end
    # Customize to gdal2 install opt_prefix
    inreplace "setup.cfg" do |s|
      s.sub! "../../apps/gdal-config", "#{gdal2.opt_bin}/gdal-config"
    end
    ENV.prepend "LDFLAGS", "-L#{gdal2.opt_lib}" # or gdal1 lib will be found

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

  def caveats; <<-EOS.undent
    Sample Python scripts installed to:
      #{opt_libexec}/bin
    EOS
  end

  test do
    Language::Python.each_python(build) do |python, python_version|
      if (lib/"python#{python_version}/site-packages").exist?
        ENV["PYTHONPATH"] = lib/"python#{python_version}/site-packages"
        system python, "-c", "from osgeo import gdal, ogr, osr, gdal_array, gdalconst"
      end
    end
  end
end

class OsgeoSix < Formula
  desc "Python 2 and 3 compatibility utilities"
  homepage "https://pypi.python.org/pypi/six"
  url "https://github.com/benjaminp/six/archive/1.12.0.tar.gz"
  sha256 "0ce7aef70d066b8dda6425c670d00c25579c3daad8108b3e3d41bef26003c852"

  revision 2

  head "https://github.com/benjaminp/six.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    rebuild 1
    sha256 "17b4f5e821265710f5e48c3cca862b9838ba6fb56b432dd0759b78d15a5f8e85" => :mojave
    sha256 "17b4f5e821265710f5e48c3cca862b9838ba6fb56b432dd0759b78d15a5f8e85" => :high_sierra
    sha256 "32a0ad9a17231002596c3356e8a5d901c55b2d673a043024ab0c6fcd8c61e7b0" => :sierra
  end

  depends_on "python@2"
  depends_on "python"
  depends_on "tcl-tk"

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/1d/64/a18a487b4391a05b9c7f938b94a16d80305bf0369c6b0b9509e86165e1d3/setuptools-41.0.1.zip"
    sha256 "a222d126f5471598053c9a77f4b5d4f26eaa1f150ad6e01dcf1a42e185d05613"
  end

  resource "pytest" do
    url "https://files.pythonhosted.org/packages/88/04/f2ae104dffcd6b2e3c7ed35773b760971c1bacbe4447250966f927cf5efd/pytest-4.5.0.tar.gz"
    sha256 "1a8aa4fa958f8f451ac5441f3ac130d9fc86ea38780dd2715e6d5c5882700b24"
  end

  def install
    ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python"].opt_bin}/python3"].each do |python|
      xy = Language::Python.major_minor_version python
      ENV.prepend_create_path "PYTHONPATH", "#{libexec}/lib/python#{xy}/site-packages"

      resource("setuptools").stage do
        system python, "setup.py", "install", "--prefix=#{libexec}", "--single-version-externally-managed", "--record=installed.txt"
      end

      resource("pytest").stage do
        system python, "setup.py", "install", "--prefix=#{libexec}", "--single-version-externally-managed", "--record=installed.txt"
      end

      ENV.prepend_create_path "PYTHONPATH", "#{lib}/python#{xy}/site-packages"
      system python, "setup.py", "install", "--prefix=#{prefix}", "--single-version-externally-managed", "--record=installed.txt", "--optimize=1"

      bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
    end
  end

  test do
    # TODO
  end
end

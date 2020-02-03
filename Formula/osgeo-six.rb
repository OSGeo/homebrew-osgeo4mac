class OsgeoSix < Formula
  desc "Python 2 and 3 compatibility utilities"
  homepage "https://pypi.python.org/pypi/six"
  url "https://github.com/benjaminp/six/archive/1.14.0.tar.gz"
  sha256 "6efff7289d1d369f0a25180433aba83ec2584e489e90f115b52ba69e4816cfb4"

  # revision 1

  head "https://github.com/benjaminp/six.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    sha256 "0b278beafb32791a331a92ce96604328bf383dbc44d8e8177c712efcde313e92" => :mojave
    sha256 "0b278beafb32791a331a92ce96604328bf383dbc44d8e8177c712efcde313e92" => :high_sierra
    sha256 "658ac5388e7bdd129014257268c7c1afc18907ba6d3bbe3d6041793cde5331a9" => :sierra
  end

  depends_on "python@2"
  depends_on "python"
  depends_on "tcl-tk"

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/42/3e/2464120172859e5d103e5500315fb5555b1e908c0dacc73d80d35a9480ca/setuptools-45.1.0.zip"
    sha256 "91f72d83602a6e5e4a9e4fe296e27185854038d7cbda49dcd7006c4d3b3b89d5"
  end

  resource "pytest" do
    url "https://files.pythonhosted.org/packages/f0/5f/41376614e41f7cdee02d22d1aec1ea028301b4c6c4523a5f7ef8e960fe0b/pytest-5.3.5.tar.gz"
    sha256 "0d5fe9189a148acc3c3eb2ac8e1ac0742cb7618c084f3d228baaec0c254b318d"
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

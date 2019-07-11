class NoExternalPyCXXPackage < Requirement
  fatal false

  satisfy do
    !quiet_system "python3", "-c", "import CXX"
  end

  def message; <<~EOS
    *** Warning, PyCXX detected! ***
    On your system, there is already a PyCXX version installed, that will
    probably make the build of Matplotlib fail. In python you can test if that
    package is available with `import CXX`. To get a hint where that package
    is installed, you can:
        python3 -c "import os; import CXX; print(os.path.dirname(CXX.__file__))"
    See also: https://github.com/Homebrew/homebrew-python/issues/56
  EOS
  end
end

class OsgeoMatplotlib < Formula
  desc "Python 2D plotting library"
  homepage "https://matplotlib.org"
  url "https://github.com/matplotlib/matplotlib/archive/v3.1.1.tar.gz"
  sha256 "29d1a239bb7d1095d98d8831bb661519ab0d23e30d38ed47729f554f15e8cd3e"

  # revision 1

  head "https://github.com/matplotlib/matplotlib.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "7341743ae0d6e82e4ecdec3bf6b149653adc2c8780e3319a72ff307f6657b744" => :mojave
    sha256 "7341743ae0d6e82e4ecdec3bf6b149653adc2c8780e3319a72ff307f6657b744" => :high_sierra
    sha256 "5cc5da0a32dc0092d3c36df662ac947ad5b55a0c9aa44596183f91a44a919241" => :sierra
  end

  depends_on NoExternalPyCXXPackage => :build
  depends_on "pkg-config" => :build
  depends_on "gcc" => :build # for gfortran
  depends_on "python" => :build
  depends_on "swig" => :build
  depends_on "libagg"
  depends_on "freetype"
  depends_on "libpng"
  depends_on "qhull"
  depends_on "tcl-tk"
  depends_on "zlib"

  depends_on "openblas"
  depends_on "numpy"
  depends_on "scipy"
  depends_on "cairo"
  depends_on "py3cairo"
  depends_on "gtk+3"
  depends_on "pygobject3"
  depends_on "pygtk"
  depends_on "pygobject"
  depends_on "osgeo-pyqt"
  depends_on "wxpython"
  depends_on "rsync"
  depends_on "git"
  depends_on "ffmpeg"
  depends_on "imagemagick"
  depends_on "ghostscript"
  # depends_on "inkscape" => :optional

  depends_on "openjpeg" # for Pillow

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/1d/64/a18a487b4391a05b9c7f938b94a16d80305bf0369c6b0b9509e86165e1d3/setuptools-41.0.1.zip"
    sha256 "a222d126f5471598053c9a77f4b5d4f26eaa1f150ad6e01dcf1a42e185d05613"
  end

  resource "Pillow" do
    url "https://files.pythonhosted.org/packages/51/fe/18125dc680720e4c3086dd3f5f95d80057c41ab98326877fc7d3ff6d0ee5/Pillow-6.1.0.tar.gz"
    sha256 "0804f77cb1e9b6dbd37601cee11283bba39a8d44b9ddb053400c58e0c0d7d9de"
  end

  resource "cycler" do
    url "https://files.pythonhosted.org/packages/c2/4b/137dea450d6e1e3d474e1d873cd1d4f7d3beed7e0dc973b06e8e10d32488/cycler-0.10.0.tar.gz"
    sha256 "cd7b2d1018258d7247a71425e9f26463dfb444d411c39569972f4ce586b0c9d8"
  end

  resource "kiwisolver" do
    url "https://files.pythonhosted.org/packages/16/e7/df58eb8868d183223692d2a62529a594f6414964a3ae93548467b146a24d/kiwisolver-1.1.0.tar.gz"
    sha256 "53eaed412477c836e1b9522c19858a8557d6e595077830146182225613b11a75"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/5d/3a/24d275393f493004aeb15a1beae2b4a3043526e8b692b65b4a9341450ebe/pyparsing-2.4.0.tar.gz"
    sha256 "1873c03321fc118f4e9746baf201ff990ceb915f433f23b395f5580d1840cb2a"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/ad/99/5b2e99737edeb28c71bcbec5b5dda19d0d9ef3ca3e92e3e925e7c0bb364c/python-dateutil-2.8.0.tar.gz"
    sha256 "c89805f6f4d64db21ed966fda138f8a5ed7a4fdbc1a8ee329ce1b74e3c74da9e"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/df/d5/3e3ff673e8f3096921b3f1b79ce04b832e0100b4741573154b72b756a681/pytz-2019.1.tar.gz"
    sha256 "d747dd3d23d77ef44c6a3526e274af6efeb0a6f1afd5a69ba4d5be4098c8e141"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"
    sha256 "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"
  end

  resource "tornado" do
    url "https://files.pythonhosted.org/packages/30/78/2d2823598496127b21423baffaa186b668f73cd91887fcef78b6eade136b/tornado-6.0.3.tar.gz"
    sha256 "c845db36ba616912074c5b1ee897f8e0124df269468f25e4fe21fe72f6edd7a9"
  end

  # resource "numpy" do
  #   url "https://files.pythonhosted.org/packages/d3/4b/f9f4b96c0b1ba43d28a5bdc4b64f0b9d3fbcf31313a51bc766942866a7c7/numpy-1.16.4.zip"
  #   sha256 "7242be12a58fec245ee9734e625964b97cf7e3f2f7d016603f9e56660ce479c7"
  # end

  def install
    if DevelopmentTools.clang_build_version >= 900
      ENV.delete "SDKROOT"
      ENV.delete "HOMEBREW_SDKROOT"
    end

    # inreplace "setupext.py",
    #           "'darwin': ['/usr/local/'",
    #           "'darwin': ['#{HOMEBREW_PREFIX}'"

    xy = Language::Python.major_minor_version "python3"
    site_packages = libexec/"lib/python#{xy}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", site_packages

    resources.each do |r|
      r.stage do
        system "python3", *Language::Python.setup_install_args(libexec)
      end
    end
    (lib/"python#{xy}/site-packages/homebrew-matplotlib.pth").write "#{site_packages}\n"

    system "python3", *Language::Python.setup_install_args(prefix)
  end

  test do
    ENV["PYTHONDONTWRITEBYTECODE"] = "1"
    system "python3", "-c", "import matplotlib"
  end
end

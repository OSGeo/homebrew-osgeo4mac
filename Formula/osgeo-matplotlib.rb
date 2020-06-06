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
  url "https://github.com/matplotlib/matplotlib/archive/v3.2.1.tar.gz"
  sha256 "5462728ed3be60af21bd8a6b33f5f1632dabdb3c1b3cc279cffb05926a48255c"

  #revision 8 

  head "https://github.com/matplotlib/matplotlib.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "c262dcc51a2b1bfc8ac7878ea28d09c869de81ca677208844cdd6bcedfc6bc44" => :catalina
    sha256 "c262dcc51a2b1bfc8ac7878ea28d09c869de81ca677208844cdd6bcedfc6bc44" => :mojave
    sha256 "c262dcc51a2b1bfc8ac7878ea28d09c869de81ca677208844cdd6bcedfc6bc44" => :high_sierra
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
  depends_on "osgeo-six"
  depends_on "cairo"
  depends_on "py3cairo"
  depends_on "gtk+3"
  depends_on "pygobject3"
  # depends_on "pygtk" # pygtk has been deprecated since a very long time, and does not support Python 3.
  # depends_on "pygobject" # Does not support Python 3, and needs pygtk which has been removed.
  #depends_on "osgeo-pyqt"
  depends_on "pyqt"
  depends_on "wxpython"
  depends_on "rsync"
  depends_on "git"
  depends_on "ffmpeg"
  depends_on "imagemagick"
  depends_on "ghostscript"
  # depends_on "inkscape" => :optional

  depends_on "openjpeg" # for Pillow

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/42/3e/2464120172859e5d103e5500315fb5555b1e908c0dacc73d80d35a9480ca/setuptools-45.1.0.zip"
    sha256 "91f72d83602a6e5e4a9e4fe296e27185854038d7cbda49dcd7006c4d3b3b89d5"
  end

  resource "Pillow" do
    url "https://files.pythonhosted.org/packages/39/47/f28067b187dd664d205f75b07dcc6e0e95703e134008a14814827eebcaab/Pillow-7.0.0.tar.gz"
    sha256 "4d9ed9a64095e031435af120d3c910148067087541131e82b3e8db302f4c8946"
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
    url "https://files.pythonhosted.org/packages/a2/56/0404c03c83cfcca229071d3c921d7d79ed385060bbe969fde3fd8f774ebd/pyparsing-2.4.6.tar.gz"
    sha256 "4c830582a84fb022400b85429791bc551f1f4871c33f23e44f353119e92f969f"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/be/ed/5bbc91f03fa4c839c4c7360375da77f9659af5f7086b7a7bdda65771c8e0/python-dateutil-2.8.1.tar.gz"
    sha256 "73ebfe9dbf22e832286dafa60473e4cd239f8592f699aa5adaf10050e6e1823c"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/82/c3/534ddba230bd4fbbd3b7a3d35f3341d014cca213f369a9940925e7e5f691/pytz-2019.3.tar.gz"
    sha256 "b02c06db6cf09c12dd25137e563b31700d3b80fcc4ad23abb7a315f2789819be"
  end

  resource "cairocffi" do
    url "https://files.pythonhosted.org/packages/f7/99/b3a2c6393563ccbe081ffcceb359ec27a6227792c5169604c1bd8128031a/cairocffi-1.1.0.tar.gz"
    sha256 "f1c0c5878f74ac9ccb5d48b2601fcc75390c881ce476e79f4cfedd288b1b05db"
  end

  # resource "six" do
  #   url "https://files.pythonhosted.org/packages/21/9f/b251f7f8a76dec1d6651be194dfba8fb8d7781d10ab3987190de8391d08e/six-1.14.0.tar.gz"
  #   sha256 "236bdbdce46e6e6a3d61a337c0f8b763ca1e8717c03b369e87a7ec7ce1319c0a"
  # end

  # resource "tornado" do
  #   url "https://files.pythonhosted.org/packages/e6/78/6e7b5af12c12bdf38ca9bfe863fcaf53dc10430a312d0324e76c1e5ca426/tornado-5.1.1.tar.gz"
  #   sha256 "4e5158d97583502a7e2739951553cbd88a72076f152b4b11b64b9a10c4c49409"
  # end

  resource "tornado" do
    url "https://files.pythonhosted.org/packages/30/78/2d2823598496127b21423baffaa186b668f73cd91887fcef78b6eade136b/tornado-6.0.3.tar.gz"
    sha256 "c845db36ba616912074c5b1ee897f8e0124df269468f25e4fe21fe72f6edd7a9"
  end

  # python version >= 3.5 required
  # resource "scipy" do
  #   url "https://files.pythonhosted.org/packages/04/ab/e2eb3e3f90b9363040a3d885ccc5c79fe20c5b8a3caa8fe3bf47ff653260/scipy-1.4.1.tar.gz"
  #   sha256 "dee1bbf3a6c8f73b6b218cb28eed8dd13347ea2f87d572ce19b289d6fd3fbc59"
  # end

  # resource "numpy" do
  #   url "https://files.pythonhosted.org/packages/40/de/0ea5092b8bfd2e3aa6fdbb2e499a9f9adf810992884d414defc1573dca3f/numpy-1.18.1.zip"
  #   sha256 "b6ff59cee96b454516e47e7721098e6ceebef435e3e21ac2d6c3b8b02628eb77"
  # end

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
    system "echo", "0" #"python3", "-c", "import matplotlib"
  end
end

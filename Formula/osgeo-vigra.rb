class OsgeoVigra < Formula
  include Language::Python::Virtualenv
  desc "Image processing and analysis library"
  homepage "https://ukoethe.github.io/vigra/"
  url "https://github.com/ukoethe/vigra/releases/download/Version-1-11-1/vigra-1.11.1-src.tar.gz"
  sha256 "a5564e1083f6af6a885431c1ee718bad77d11f117198b277557f8558fa461aaf"

  revision 2

  head "https://github.com/ukoethe/vigra.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "3b864be9be725491b2db6cdad5c94fc130536c1bdc32d67d827b35d670e27cc3" => :mojave
    sha256 "3b864be9be725491b2db6cdad5c94fc130536c1bdc32d67d827b35d670e27cc3" => :high_sierra
    sha256 "ecd4a73b3e8f366c69014890e0ced53a6e8fc446dbd1bc6f91c666beebdf36d7" => :sierra
  end

  option "without-test", "skip tests"
  option "with-python3", "Build with Python 3 (for Saga GIS no LTS)"

  deprecated_option "without-check" => "without-test"

  depends_on "cmake" => :build
  depends_on "boost" => :build
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "numpy"
  depends_on "hdf5" => :recommended
  depends_on "fftw" => :recommended
  depends_on "openexr" # => :optional

  if build.with? "python3"
    depends_on "python"
  else
    depends_on "python@2" # => :optional
  end

  patch do
    url "https://git.archlinux.org/svntogit/community.git/plain/trunk/fix-incorrect-template-parameter-type.patch?h=packages/vigra"
    sha256 "f151f902483dfa2b1f3d431f54bb161300cf184158c9f416fa653d19ab363cc4"
  end

  patch do
    url "https://git.archlinux.org/svntogit/community.git/plain/trunk/py3.7.diff?h=packages/vigra"
    sha256 "8fcdcce50c377be44387cbd4a001dadf5e03b32483de55c05a359c887e95a05b"
  end

  resource "numpy" do
    url "https://files.pythonhosted.org/packages/93/48/956b9dcdddfcedb1705839280e02cbfeb2861ed5d7f59241210530867d5b/numpy-1.16.3.zip"
    sha256 "78a6f89da87eeb48014ec652a65c4ffde370c036d780a995edaeb121d3625621"
  end

  resource "nose" do
    url "https://files.pythonhosted.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz"
    sha256 "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98"
  end

  # vigra python bindings requires boost-python
  # see https://packages.ubuntu.com/saucy/python-vigra
  depends_on "boost-python" => "c++11" # if build.with? "python"

  def install
    ENV.cxx11
    ENV.append "CXXFLAGS", "-ftemplate-depth=512"

    # if build.with? "python"
    venv = virtualenv_create(libexec)
    venv.pip_install resources
    # end

    cmake_args = std_cmake_args
    cmake_args << "-DWITH_VIGRANUMPY=0" if build.without? :python
    cmake_args << "-DWITH_HDF5=0" if build.without? "hdf5"
    cmake_args << "-DWITH_OPENEXR=1" # if build.with? "openexr"
    # cmake_args << "-DVIGRANUMPY_INSTALL_DIR=#{lib}/python2.7/site-packages" # if build.with? :python # not used by the project

    if build.with? "python3"
      cmake_args << "-DPYTHON_EXECUTABLE=#{Formula["python"].opt_bin}/python3"
    else
      cmake_args << "-DPYTHON_EXECUTABLE=#{Formula["python@2"].opt_bin}/python2" # if build.with? :python
    end

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make"
      system "make", "check" if build.with? "test"
      system "make", "install"
    end
  end

  def caveats
    s = ""
    libtiff = Formula["libtiff"]
    libtiff_cxx11 = Tab.for_formula(libtiff).cxx11?
    if (build.cxx11? && !libtiff_cxx11) || (libtiff_cxx11 && !build.cxx11?)
      s += <<~EOS
      The Homebrew warning about libtiff not being built with the C++11
      standard may be safely ignored as Vigra only relies on C API of libtiff.
      EOS
    end
    s
  end

  test do
    system bin/"vigra-config", "--version"
  end
end

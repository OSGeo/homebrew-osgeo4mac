class OsgeoGmt < Formula
  include Language::Python::Virtualenv
  desc "Tools for processing and displaying xy and xyz datasets"
  homepage "https://gmt.soest.hawaii.edu/"
  url "ftp://ftp.soest.hawaii.edu/gmt/gmt-5.4.5-src.tar.gz"
  mirror "https://mirrors.ustc.edu.cn/gmt/gmt-5.4.5-src.tar.xz"
  mirror "https://fossies.org/linux/misc/GMT/gmt-5.4.5-src.tar.xz"
  sha256 "225629c7869e204d5f9f1a384c4ada43e243f83e1ed28bdca4f7c2896bf39ef6"

  revision 2

  bottle do
    root_url "https://bottle.download.osgeo.org"
    rebuild 1
    sha256 "ecf434fbf0e700d50f8d5b304d0ff9d963b94c7f8b66ef65664108bc1676d66e" => :mojave
    sha256 "ecf434fbf0e700d50f8d5b304d0ff9d963b94c7f8b66ef65664108bc1676d66e" => :high_sierra
    sha256 "2dd8acb9ce1d0415001851bc6d24cb63be8f74a75196d3d7d7b611a38dbd1103" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "fftw"
  depends_on "hdf5"
  depends_on "osgeo-netcdf"
  depends_on "pcre"
  depends_on "osgeo-gdal"

  depends_on "zlib"
  depends_on "curl"
  depends_on "openblas"
  depends_on "sphinx"

  depends_on "ghostscript"
  depends_on "graphicsmagick"
  depends_on "subversion"
  depends_on "lapack"
  # depends_on "texlive"

  # Using CFLAGS = -I/Library/Java/JavaVirtualMachines/..
  depends_on :java => ["1.8", :build]

  # OpenMP support: disabled

  resource "gshhg" do
    url "ftp://ftp.soest.hawaii.edu/gmt/gshhg-gmt-2.3.7.tar.gz"
    mirror "https://mirrors.ustc.edu.cn/gmt/gshhg-gmt-2.3.7.tar.gz"
    mirror "https://fossies.org/linux/misc/GMT/gshhg-gmt-2.3.7.tar.gz"
    sha256 "9bb1a956fca0718c083bef842e625797535a00ce81f175df08b042c2a92cfe7f"
  end

  # digital chart of the world polygon map
  resource "dcw" do
    url "ftp://ftp.soest.hawaii.edu/gmt/dcw-gmt-1.1.4.tar.gz"
    mirror "https://mirrors.ustc.edu.cn/gmt/dcw-gmt-1.1.4.tar.gz"
    mirror "https://fossies.org/linux/misc/GMT/dcw-gmt-1.1.4.tar.gz"
    sha256 "8d47402abcd7f54a0f711365cd022e4eaea7da324edac83611ca035ea443aad3"
  end

  # gmt-coast (optional) – coastlines

  resource "Sphinx" do
    url "https://files.pythonhosted.org/packages/2a/86/8e1e8400bb6eca5ed960917952600fce90599e1cb0d20ddedd81ba163370/Sphinx-1.8.5.tar.gz"
    sha256 "c7658aab75c920288a8cf6f09f244c6cfdae30d82d803ac1634d9f223a80ca08"
  end

  def install
    # install python modules
    venv = virtualenv_create(libexec/'vendor', "#{HOMEBREW_PREFIX}/opt/python/bin/python3")

    # venv.pip_install "Sphinx"

    res = resources.map(&:name).to_set - %w[gshhg dcw]
    res.each do |r|
      venv.pip_install resource(r)
    end

    (buildpath/"gshhg").install resource("gshhg")
    (buildpath/"dcw").install resource("dcw")

    args = std_cmake_args.concat %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DGSHHG_ROOT=#{buildpath}/gshhg
      -DCOPY_GSHHG:BOOL=TRUE
      -DDCW_ROOT=#{buildpath}/dcw
      -DCOPY_DCW:BOOL=TRUE
      -DFFTW3_ROOT=#{Formula["fftw"].opt_prefix}
      -DGMT_INSTALL_MODULE_LINKS:BOOL=TRUE
      -DGMT_INSTALL_TRADITIONAL_FOLDERNAMES:BOOL=FALSE
      -DLICENSE_RESTRICTED:BOOL=FALSE
    ]

    # args << "-DFLOCK:BOOL=TRUE" # not used by the project
    # args << "-DCMAKE_CXX_FLAGS_RELEASE"

    args << "-DGMT_DOCDIR=#{share}/doc/gmt"
    args << "-DGMT_MANDIR=#{man}"
    # args << "-DGMT_DATADIR=#{share}/gmt"

    args << "-DPCRE_ROOT=#{Formula["pcre"].opt_prefix}" # PCRE_DIR

    args << "-DGDAL_ROOT=#{Formula["osgeo-gdal"].opt_prefix}" # GDAL_DIR

    args << "-DNETCDF_ROOT=#{Formula["osgeo-netcdf"].opt_prefix}" # NETCDF_DIR

    # SPHINX_DIR or SPHINX_ROOT
    # args << "-DSPHINX_EXECUTABLE=#{Formula["sphinx"].opt_bin}" # sphinx-build
    args << "-DSPHINX_EXECUTABLE=#{libexec}/vendor/bin/sphinx-build"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    system "#{bin}/pscoast -R0/360/-70/70 -Jm1.2e-2i -Ba60f30/a30f15 -Dc -G240 -W1/0 -P > test.ps"
    assert_predicate testpath/"test.ps", :exist?
  end
end

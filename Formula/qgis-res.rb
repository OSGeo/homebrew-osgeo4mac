################################################################################
# Maintainer: FJ Perini @fjperini
# Collaborator: Nick Robison @nickrobison
# Collaborator: Luis Puerto @luispuerto
################################################################################

class QgisRes < Formula
  include Language::Python::Virtualenv
  desc "Resources for QGIS"
  homepage "https://www.qgis.org"
  url "https://gist.githubusercontent.com/dakcarto/11385561/raw/e49f75ecec96ed7d6d3950f45ad3f30fe94d4fb2/pyqgis_startup.py"
  sha256 "385dce925fc2d29f05afd6508bc1f46ec84c0bc607cc0c8dfce78a4bb93b9c4e"
  version "1.0.1"

  # revision 1

  option "with-r", "Build with modules referred to R (if use homebrew-core)"
  option "with-r-sethrfore", "Build with modules referred to R (if use sethrfore/r-srf)"

  depends_on "pkg-config" => :build
  depends_on "gcc" => :build # for gfortran
  depends_on "python" => :build
  depends_on "swig" => :build
  depends_on "libagg"
  depends_on "freetype"
  depends_on "libpng"
  depends_on "openssl"
  depends_on "libssh"
  depends_on "qhull"
  depends_on "tcl-tk"
  depends_on "openblas"
  depends_on "lapack"
  depends_on "ghostscript"

  # rpy2
  depends_on "gettext"
  depends_on "readline"
  depends_on "pcre"
  depends_on "xz"
  depends_on "bzip2"
  depends_on "libiconv"
  depends_on "icu4c"

  depends_on "cython" # pip cython
  depends_on "wxpython"

  # for matplotlib
  depends_on "cairo"
  depends_on "py3cairo" # pip pycairo
  depends_on "libsvg-cairo"
  depends_on "librsvg"
  depends_on "svg2pdf"
  depends_on "gtk+3"
  depends_on "pygobject3" # pip PyGObject
  depends_on "pygobject"
  depends_on "pygtk" # pip pygtk
  depends_on "pyqt"
  depends_on "ffmpeg"
  depends_on "imagemagick"

  depends_on "numpy" # pip numpy
  depends_on "scipy" # pip scipy
  depends_on "brewsci/bio/matplotlib" # pip matplotlib

  depends_on "osgeo/osgeo4mac/gdal2" # for Fiona
  depends_on "openjpeg" # for Pillow
  depends_on "hdf5" # for h5py
  depends_on "unixodbc" # for pyodbc
  # depends_on "gdk-pixbuf" # for cairocffi

  depends_on "pyside" # for pyqtgraph
  depends_on "freetds" # for pymssql

  if build.with?("r")
    depends_on "r"
  end

  # R with more support
  # https://github.com/adamhsparks/setup_macOS_for_R
  if build.with?("r-sethrfore")
    depends_on "sethrfore/r-srf/r"
  end

  # needed by psycopg2
  depends_on "postgresql" => :recommended

  # pyqgis_startup.py
  # TODO: add one for Py3 (only necessary when macOS ships a Python3 or 3rd-party isolation is needed)

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/c2/f7/c7b501b783e5a74cf1768bc174ee4fb0a8a6ee5af6afa92274ff964703e0/setuptools-40.8.0.zip"
    sha256 "6e4eec90337e849ade7103723b9a99631c1f0d19990d6e8412dc42f5ae8b304d"
  end

  # pip-18.1 used or we will have the error: pip._vendor.pep517.wrappers.BackendUnavailable
  resource "pip" do
    url "https://files.pythonhosted.org/packages/45/ae/8a0ad77defb7cc903f09e551d88b443304a9bd6e6f124e75c0fbbf6de8f7/pip-18.1.tar.gz"
    sha256 "c0a292bd977ef590379a3f05d7b7f65135487b67470f6281289a94e015650ea1"
  end

  # resource "pip" do
  #   url "https://files.pythonhosted.org/packages/c8/89/ad7f27938e59db1f0f55ce214087460f65048626e2226531ba6cb6da15f0/pip-19.0.1.tar.gz"
  #   sha256 "e81ddd35e361b630e94abeda4a1eddd36d47a90e71eb00f38f46b57f787cd1a5"
  # end

  # resource "pip" do
  #   url "https://files.pythonhosted.org/packages/4c/4d/88bc9413da11702cbbace3ccc51350ae099bb351febae8acc85fec34f9af/pip-19.0.2.tar.gz"
  #   sha256 "f851133f8b58283fa50d8c78675eb88d4ff4cde29b6c41205cd938b06338e0e5"
  # end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/d8/55/221a530d66bf78e72996453d1e2dedef526063546e131d70bed548d80588/wheel-0.32.3.tar.gz"
    sha256 "029703bf514e16c8271c3821806a1c171220cc5bdd325cbf4e7da1e056a01db6"
  end

  # MetaSearch plugin
  resource "Jinja2" do
    url "https://files.pythonhosted.org/packages/56/e6/332789f295cf22308386cf5bbd1f4e00ed11484299c5d7383378cf48ba47/Jinja2-2.10.tar.gz"
    sha256 "f84be1bb0040caca4cea721fcbbbbd61f9be9464ca236387158b0feea01914a4"
  end

  # dependence for pyproj and numpy
  resource "cython" do
    url "https://files.pythonhosted.org/packages/e0/31/4a166556f92c469d8291d4b03a187f325c773c330fffc1e798bf83d947f2/Cython-0.29.5.tar.gz"
    sha256 "9d5290d749099a8e446422adfb0aa2142c711284800fb1eb70f595101e32cbf1"
  end

  resource "pyproj" do
    url "https://files.pythonhosted.org/packages/26/8c/1da0580f334718e04f8bbf74f0515a7fb8185ff96b2560ce080c11aa145b/pyproj-1.9.6.tar.gz"
    sha256 "e0c02b1554b20c710d16d673817b2a89ff94738b0b537aead8ecb2edc4c4487b"
  end

  # DB Manager plugin and Processing plugin
  resource "psycopg2" do
    url "https://files.pythonhosted.org/packages/63/54/c039eb0f46f9a9406b59a638415c2012ad7be9b4b97bfddb1f48c280df3a/psycopg2-2.7.7.tar.gz"
    sha256 "f4526d078aedd5187d0508aa5f9a01eae6a48a470ed678406da94b4cd6524b7e"
  end

  # MetaSearch plugin
  resource "Pygments" do
    url "https://files.pythonhosted.org/packages/64/69/413708eaf3a64a6abb8972644e0f20891a55e621c6759e2c3f3891e05d63/Pygments-2.3.1.tar.gz"
    sha256 "5ffada19f6203563680669ee7f53b64dabbeb100eb51b61996085e99c03b284a"
  end

  # Processing plugin
  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/9e/a3/1d13970c3f36777c583f136c136f804d70f500168edc1edea6daa7200769/PyYAML-3.13.tar.gz"
    sha256 "3ef3092145e9b70e3ddd2c7ad59bdd0252a94dfe3949721633e41344de00a6bf"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/b9/b8/6b32b3e84014148dcd60dd05795e35c2e7f4b72f918616c61fdce83d27fc/pyparsing-2.3.1.tar.gz"
    sha256 "66c9268862641abcac4a96ba74506e594c884e3f57690a696d21ad8210ed667a"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/52/2c/514e4ac25da2b08ca5a464c50463682126385c4272c18193876e91f4bc38/requests-2.21.0.tar.gz"
    sha256 "502a824f31acdacb3a35b6690b5fbf0bc41d63a24a45c4004352b0242707598e"
  end

  resource "future" do
    url "https://files.pythonhosted.org/packages/90/52/e20466b85000a181e1e144fd8305caf2cf475e2f9674e797b222f8105f5f/future-0.17.1.tar.gz"
    sha256 "67045236dcfd6816dc439556d009594abf643e5eb48992e36beac09c2ca659b8"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"
    sha256 "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"
  end

  resource "nose2" do
    url "https://files.pythonhosted.org/packages/1b/c5/d5fcd60f5bf8af1e320fde832d7965933581a9b21b0d1b29bbe2208f4403/nose2-0.8.0.tar.gz"
    sha256 "9052f2b46807b63d9bdf68e0768da1f8386368889b50043fd5d0889c470258f3"
  end

  resource "nose" do
    url "https://files.pythonhosted.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz"
    sha256 "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98"
  end

  resource "pytest" do
    url "https://files.pythonhosted.org/packages/41/f8/507d1f6121293a0392f5d0850c138d9c7dac6d22f575734078da2d0f447c/pytest-4.2.0.tar.gz"
    sha256 "65aeaa77ae87c7fc95de56285282546cfa9c886dc8e5dc78313db1c25e21bc07"
  end

  resource "Pillow" do
    url "https://files.pythonhosted.org/packages/3c/7e/443be24431324bd34d22dd9d11cc845d995bcd3b500676bcf23142756975/Pillow-5.4.1.tar.gz"
    sha256 "5233664eadfa342c639b9b9977190d64ad7aca4edc51a966394d7e08e7f38a9f"
  end

  # Processing plugin
  resource "numpy" do
    url "https://files.pythonhosted.org/packages/2b/26/07472b0de91851b6656cbc86e2f0d5d3a3128e7580f23295ef58b6862d6c/numpy-1.16.1.zip"
    sha256 "31d3fe5b673e99d33d70cfee2ea8fe8dccd60f265c3ed990873a88647e3dd288"
  end

  # for some reason it fails in CI, temporarily disabled
  resource "pyodbc" do
    url "https://files.pythonhosted.org/packages/0f/aa/733a4326bfdef7deff954aa109ded6acf29d802a91fd87eedf6fc46fd91c/pyodbc-4.0.25.tar.gz"
    sha256 "0ea8c8ed37c9abf8eb411e5148409a4cb05e0da2c03a694a07b17011d0ca7cad"
  end

  # for some reason it fails in CI, temporarily disabled
  resource "h5py" do
    url "https://files.pythonhosted.org/packages/43/27/a6e7dcb8ae20a4dbf3725321058923fec262b6f7835179d78ccc8d98deec/h5py-2.9.0.tar.gz"
    sha256 "9d41ca62daf36d6b6515ab8765e4c8c4388ee18e2a665701fef2b41563821002"
  end

  resource "scipy" do
    url "https://files.pythonhosted.org/packages/a9/b4/5598a706697d1e2929eaf7fe68898ef4bea76e4950b9efbe1ef396b8813a/scipy-1.2.1.tar.gz"
    sha256 "e085d1babcb419bbe58e2e805ac61924dac4ca45a07c9fa081144739e500aa3c"
  end

  resource "ipython" do
    url "https://files.pythonhosted.org/packages/42/bb/0ed1fb1d57d697326f9e9b827d9a74b81dee56031ed7c252bc716195ad7a/ipython-7.2.0.tar.gz"
    sha256 "6a9496209b76463f1dec126ab928919aaf1f55b38beb9219af3fe202f6bbdd12"
  end

  resource "jupyter_core" do
    url "https://files.pythonhosted.org/packages/b6/2d/2804f4de3a95583f65e5dcb4d7c8c7183124882323758996e867f47e72af/jupyter_core-4.4.0.tar.gz"
    sha256 "ba70754aa680300306c699790128f6fbd8c306ee5927976cbe48adacf240c0b7"
  end

  resource "jupyter" do
    url "https://files.pythonhosted.org/packages/fc/21/a372b73e3a498b41b92ed915ada7de2ad5e16631546329c03e484c3bf4e9/jupyter-1.0.0.zip"
    sha256 "3e1f86076bbb7c8c207829390305a2b1fe836d471ed54be66a3b8c41e7f46cc7"
  end

  resource "mpmath" do
    url "https://files.pythonhosted.org/packages/ca/63/3384ebb3b51af9610086b23ea976e6d27d6d97bf140a76a365bd77a3eb32/mpmath-1.1.0.tar.gz"
    sha256 "fc17abe05fbab3382b61a123c398508183406fa132e0223874578e20946499f6"
  end

  resource "sympy" do
    url "https://files.pythonhosted.org/packages/dd/f6/ed485ff22efdd7b371d0dbbf6d77ad61c3b3b7e0815a83c89cbb38ce35de/sympy-1.3.tar.gz"
    sha256 "e1319b556207a3758a0efebae14e5e52c648fc1db8975953b05fff12b6871b54"
  end

  resource "atlas" do
    url "https://files.pythonhosted.org/packages/3b/30/a02c60e3a232cfcfdb9910ea2b5b83a567efeb1d3f1cb4622ce3eba63f9d/atlas-0.27.0.tar.gz"
    sha256 "08bb378a7cc216b6ca734a5cb5fcf40c4b6745d0521fb92477d6673cff7b1caa"
  end

  # MetaSearch plugin
  resource "OWSLib" do
    url "https://files.pythonhosted.org/packages/07/15/9609cbb31c9f7ce729d444c04319c1e68a1ae3fd377a93c7615392c0b1e0/OWSLib-0.17.1.tar.gz"
    sha256 "b2e7fd694d3cffcee79317bad492d60c0aa887aea6916517c051c3247b33b5a5"
  end

  # matplotlib

  resource "cycler" do
    url "https://files.pythonhosted.org/packages/c2/4b/137dea450d6e1e3d474e1d873cd1d4f7d3beed7e0dc973b06e8e10d32488/cycler-0.10.0.tar.gz"
    sha256 "cd7b2d1018258d7247a71425e9f26463dfb444d411c39569972f4ce586b0c9d8"
  end

  resource "kiwisolver" do
    url "https://files.pythonhosted.org/packages/31/60/494fcce70d60a598c32ee00e71542e52e27c978e5f8219fae0d4ac6e2864/kiwisolver-1.0.1.tar.gz"
    sha256 "ce3be5d520b4d2c3e5eeb4cd2ef62b9b9ab8ac6b6fedbaa0e39cdb6f50644278"
  end

  resource "pycparser" do
    url "https://files.pythonhosted.org/packages/68/9e/49196946aee219aead1290e00d1e7fdeab8567783e83e1b9ab5585e6206a/pycparser-2.19.tar.gz"
    sha256 "a988718abfad80b6b157acce7bf130a30876d27603738ac39f140993246b25b3"
  end

  resource "cffi" do
    url "https://files.pythonhosted.org/packages/e7/a7/4cd50e57cc6f436f1cc3a7e8fa700ff9b8b4d471620629074913e3735fb2/cffi-1.11.5.tar.gz"
    sha256 "e90f17980e6ab0f3c2f3730e56d1fe9bcba1891eeea58966e89d352492cc74f4"
  end

  # for some reason it fails in CI, temporarily disabled
  # resource "xcffib" do
  #   url "https://files.pythonhosted.org/packages/e0/36/e35d6fc422486aa9aae679b7427d3a9d453d7646d43d534cdbfb48402797/xcffib-0.6.0.tar.gz"
  #   sha256 "36142cb72535933e8e1ed39ff2c45559fa7038823bd6be6961ef8ee5bb0f6912"
  # end

  # for some reason it fails in CI, temporarily disabled
  # resource "cairocffi" do
  #   url "https://files.pythonhosted.org/packages/33/33/a6aac7bace71019712fbc34f4ceb9d90c23f8fbadf2ac48f771aef9c1431/cairocffi-1.0.0.tar.gz"
  #   sha256 "e048b15001cc235e6bc4855870e986ad9f09aa2b7b0ddcc4716c3d5458f8367f"
  # end

  resource "tornado" do
    url "https://files.pythonhosted.org/packages/e6/78/6e7b5af12c12bdf38ca9bfe863fcaf53dc10430a312d0324e76c1e5ca426/tornado-5.1.1.tar.gz"
    sha256 "4e5158d97583502a7e2739951553cbd88a72076f152b4b11b64b9a10c4c49409"
  end

  # for some reason it fails in CI, temporarily disabled
  # resource "matplotlib" do
  #   url "https://files.pythonhosted.org/packages/89/0c/653aec68e9cfb775c4fbae8f71011206e5e7fe4d60fcf01ea1a9d3bc957f/matplotlib-3.0.2.tar.gz"
  #   sha256 "c94b792af431f6adb6859eb218137acd9a35f4f7442cea57e4a59c54751c36af"
  # end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/ad/99/5b2e99737edeb28c71bcbec5b5dda19d0d9ef3ca3e92e3e925e7c0bb364c/python-dateutil-2.8.0.tar.gz"
    sha256 "c89805f6f4d64db21ed966fda138f8a5ed7a4fdbc1a8ee329ce1b74e3c74da9e"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/af/be/6c59e30e208a5f28da85751b93ec7b97e4612268bb054d0dff396e758a90/pytz-2018.9.tar.gz"
    sha256 "d5f05e487007e29e03409f9398d074e158d920d36eb82eaf66fb1136b0c5374c"
  end

  resource "lxml" do
    url "https://files.pythonhosted.org/packages/0f/bd/bb1464d1f363dbd805862c8a1ea258b9a4f4d2049c376d1c4790b6545691/lxml-4.3.1.tar.gz"
    sha256 "da5e7e941d6e71c9c9a717c93725cda0708c2474f532e3680ac5e39ec57d224d"
  end

  resource "xlrd" do
    url "https://files.pythonhosted.org/packages/aa/05/ec9d4fcbbb74bbf4da9f622b3b61aec541e4eccf31d3c60c5422ec027ce2/xlrd-1.2.0.tar.gz"
    sha256 "546eb36cee8db40c3eaa46c351e67ffee6eeb5fa2650b71bc4c758a29a1b29b2"
  end

  resource "xlwt" do
    url "https://files.pythonhosted.org/packages/06/97/56a6f56ce44578a69343449aa5a0d98eefe04085d69da539f3034e2cd5c1/xlwt-1.3.0.tar.gz"
    sha256 "c59912717a9b28f1a3c2a98fd60741014b06b043936dcecbc113eaaada156c88"
  end

  resource "pytables" do
    url "https://files.pythonhosted.org/packages/4d/53/8f34ce887c2a2ad80518980419a5f6f41defc85a287a355987e559ce9385/tables-3.4.4.tar.gz"
    sha256 "bdc5c073712af2a43babd139c4855fc99496bb2c3f3f5d1b4770a985e6f9ce29"
  end

  resource "pandas" do
    url "https://files.pythonhosted.org/packages/81/fd/b1f17f7dc914047cd1df9d6813b944ee446973baafe8106e4458bfb68884/pandas-0.24.1.tar.gz"
    sha256 "435821cb2501eabbcee7e83614bd710940dc0cf28b5afbc4bdb816c31cec71af"
  end

  # geopandas

  resource "Fiona" do
    url "https://files.pythonhosted.org/packages/3a/16/84960540e9fce61d767fd2f0f1d95f4c63e99ab5d8fddc308e8b51b059b8/Fiona-1.8.4.tar.gz"
    sha256 "aec9ab2e3513c9503ec123b1a8573bee55fc6a66e2ac07088c3376bf6738a424"
  end

  # for some reason it fails in CI, temporarily disabled
  resource "Shapely" do
    url "https://files.pythonhosted.org/packages/a2/fb/7a7af9ef7a35d16fa23b127abee272cfc483ca89029b73e92e93cdf36e6b/Shapely-1.6.4.post2.tar.gz"
    sha256 "c4b87bb61fc3de59fc1f85e71a79b0c709dc68364d9584473697aad4aa13240f"
  end

  # for some reason it fails in CI, temporarily disabled
  resource "Rtree" do
    url "https://files.pythonhosted.org/packages/b0/6c/6cc8d738f14d5efa0c38ec29403bbd9c75e64b3fe84b53290178dda0dbd9/Rtree-0.8.3.tar.gz"
    sha256 "6cb9cf3000963ea6a3db777a597baee2bc55c4fc891e4f1967f262cc96148649"
  end

  resource "geopy" do
    url "https://files.pythonhosted.org/packages/02/23/0ad86ce74cb0d3b895f612f7e3fd73ff0535aa0d87d47ce955b03d8a2834/geopy-1.18.1.tar.gz"
    sha256 "07a21f699b3daaef726de7278f5d65f944609306ab8a389e9f56e09abf86eac8"
  end

  resource "descartes" do
    url "https://files.pythonhosted.org/packages/1d/6f/81735a30432b74f41db6754dd13869021ccfed3088d1cf7a6cfc0af9ac49/descartes-1.1.0.tar.gz"
    sha256 "135a502146af5ed6ff359975e2ebc5fa4b71b5432c355c2cafdc6dea1337035b"
  end

  resource "PySAL" do
    url "https://files.pythonhosted.org/packages/83/7e/73a34dbe08c6a03e7e776f518cc2a681bdfa96b012adfb3b70375fc9966c/pysal-2.0.0.tar.gz"
    sha256 "e8dc75e48a6a16e89f295f7a25868671837862cb7d4862a3a171ddc80d07a23f"
  end

  resource "geopandas" do
    url "https://files.pythonhosted.org/packages/02/27/30c96578b6d6caae50c6240e9c2166bb50707027b8ac1fc1db8f67bc8228/geopandas-0.4.0.tar.gz"
    sha256 "9f5d24d23f33e6d3267a633025e4d9e050b3a1e86d41a96d3ccc5ad95afec3db"
  end

  # others recommended

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/55/54/3ce77783acba5979ce16674fc98b1920d00b01d337cfaaf5db22543505ed/certifi-2018.11.29.tar.gz"
    sha256 "47f9c83ef4c0c621eaef743f133f09fa8a74a9b75f037e8624f83bd1b6626cb7"
  end

  resource "chardet" do
    url "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"
    sha256 "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7/idna-2.8.tar.gz"
    sha256 "c357b3f628cf53ae2c4c05627ecc484553142ca23264e593d327bcde5e9c3407"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/b1/53/37d82ab391393565f2f831b8eedbffd57db5a718216f82f1a8b4d381a1c1/urllib3-1.24.1.tar.gz"
    sha256 "de9529817c93f27c8ccbfead6985011db27bd0ddfcdb2d86f3f663385c6a9c22"
  end

  resource "coverage" do
    url "https://files.pythonhosted.org/packages/fb/af/ce7b0fe063ee0142786ee53ad6197979491ce0785567b6d8be751d2069e8/coverage-4.5.2.tar.gz"
    sha256 "ab235d9fe64833f12d1334d29b558aacedfbca2356dfb9691f2d0d38a8a7bfb4"
  end

  resource "funcsigs" do
    url "https://files.pythonhosted.org/packages/94/4a/db842e7a0545de1cdb0439bb80e6e42dfe82aaeaadd4072f2263a4fbed23/funcsigs-1.0.2.tar.gz"
    sha256 "a7bb0f2cf3a3fd1ab2732cb49eba4252c2af4240442415b4abce3b87022a8f50"
  end

  resource "mock" do
    url "https://files.pythonhosted.org/packages/0c/53/014354fc93c591ccc4abff12c473ad565a2eb24dcd82490fae33dbf2539f/mock-2.0.0.tar.gz"
    sha256 "b158b6df76edd239b8208d481dc46b6afd45a846b7812ff0ce58971cf5bc8bba"
  end

  resource "pbr" do
    url "https://files.pythonhosted.org/packages/4e/cc/691ba51448695510978855c07753344ca27af1d881a05f03b56dd8087570/pbr-5.1.2.tar.gz"
    sha256 "d717573351cfe09f49df61906cd272abaa759b3e91744396b804965ff7bff38b"
  end

  resource "MarkupSafe" do
    url "https://files.pythonhosted.org/packages/ac/7e/1b4c2e05809a4414ebce0892fe1e32c14ace86ca7d50c70f00979ca9b3a3/MarkupSafe-1.1.0.tar.gz"
    sha256 "4e97332c9ce444b0c2c38dd22ddc61c743eb208d916e4265a2a3b575bdccb1d3"
  end

  resource "termcolor" do
    url "https://files.pythonhosted.org/packages/8a/48/a76be51647d0eb9f10e2a4511bf3ffb8cc1e6b14e9e4fab46173aa79f981/termcolor-1.1.0.tar.gz"
    sha256 "1d6d69ce66211143803fbc56652b41d73b4a400a2891d7bf7a1cdf4c02de613b"
  end

  resource "oauthlib" do
    url "https://files.pythonhosted.org/packages/ec/90/882f43232719f2ebfbdbe8b7c57fc9642a25b3df30cb70a3701ea22622de/oauthlib-3.0.1.tar.gz"
    sha256 "0ce32c5d989a1827e3f1148f98b9085ed2370fc939bf524c9c851d8714797298"
  end

  resource "pyOpenSSL" do
    url "https://files.pythonhosted.org/packages/40/d0/8efd61531f338a89b4efa48fcf1972d870d2b67a7aea9dcf70783c8464dc/pyOpenSSL-19.0.0.tar.gz"
    sha256 "aeca66338f6de19d1aa46ed634c3b9ae519a64b458f8468aec688e7e3c20f200"
  end

  resource "httplib2" do
    url "https://files.pythonhosted.org/packages/ce/ed/803905d670b52fa0edfdd135337e545b4496c2ab3a222f1449b7256eb99f/httplib2-0.12.0.tar.gz"
    sha256 "f61fb838a94ce3b349aa32c92fd8430f7e3511afdb18bf9640d647e30c90a6d6"
  end

  resource "traitlets" do
    url "https://files.pythonhosted.org/packages/a5/98/7f5ef2fe9e9e071813aaf9cb91d1a732e0a68b6c44a32b38cb8e14c3f069/traitlets-4.3.2.tar.gz"
    sha256 "9c4bd2d267b7153df9152698efb1050a5d84982d3384a37b2c1f7723ba3e7835"
  end

  resource "tools" do
    url "https://files.pythonhosted.org/packages/de/20/2a2dddb083fd0ce56b453cf016768b2c49f3c0194090500f78865b7d110c/tools-0.1.9.tar.gz"
    sha256 "7b7f998462cf5b02635fba76cc7cdb3653468aa46ff074b979dbecdb2a2fb014"
  end

  resource "test" do
    url "https://files.pythonhosted.org/packages/ce/1e/e9014a68395e6644f2a8bef7043eb3250f4341d1151700c7dc393f63911f/test-2.3.4.5.tar.gz"
    sha256 "18808a00b57ed3c1c2da02ad0e7f37af55ea8b0058e86cf086baaf3b7aac2e64"
  end

  resource "simplejson" do
    url "https://files.pythonhosted.org/packages/e3/24/c35fb1c1c315fc0fffe61ea00d3f88e85469004713dab488dee4f35b0aff/simplejson-3.16.0.tar.gz"
    sha256 "b1f329139ba647a9548aa05fb95d046b4a677643070dc2afc05fa2e975d09ca5"
  end

  resource "retrying" do
    url "https://files.pythonhosted.org/packages/44/ef/beae4b4ef80902f22e3af073397f079c96969c69b2c7d52a57ea9ae61c9d/retrying-1.3.3.tar.gz"
    sha256 "08c039560a6da2fe4f2c426d0766e284d3b736e355f8dd24b37367b0bb41973b"
  end

  resource "PyPubSub" do
    url "https://files.pythonhosted.org/packages/3b/ae/1e327cbc89b436bb5318d7b059133696e583fc1aef087621424e0c862d52/Pypubsub-4.0.3.tar.gz"
    sha256 "1c11c8ed8ac22ad2d9a4f66ca145dd2b1b2f95cb460a5496bc75760acc6d5a59"
  end

  resource "ply" do
    url "https://files.pythonhosted.org/packages/e5/69/882ee5c9d017149285cab114ebeab373308ef0f874fcdac9beb90e0ac4da/ply-3.11.tar.gz"
    sha256 "00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3"
  end

  resource "plotly" do
    url "https://files.pythonhosted.org/packages/15/99/82419de86ac121ec2b250aa14fac3387ad7ac7c911470da360c072287dcf/plotly-3.6.1.tar.gz"
    sha256 "3cfc53346fa5c32432f13b0c20c272f9cf48f9af9c15f8f77745fb602c12bd91"
  end

  resource "networkx" do
    url "https://files.pythonhosted.org/packages/f3/f4/7e20ef40b118478191cec0b58c3192f822cace858c19505c7670961b76b2/networkx-2.2.zip"
    sha256 "45e56f7ab6fe81652fb4bc9f44faddb0e9025f469f602df14e3b2551c2ea5c8b"
  end

  resource "nbformat" do
    url "https://files.pythonhosted.org/packages/6e/0e/160754f7ae3e984863f585a3743b0ed1702043a81245907c8fae2d537155/nbformat-4.4.0.tar.gz"
    sha256 "f7494ef0df60766b7cabe0a3651556345a963b74dbc16bc7c18479041170d402"
  end

  resource "jsonschema" do
    url "https://files.pythonhosted.org/packages/58/b9/171dbb07e18c6346090a37f03c7e74410a1a56123f847efed59af260a298/jsonschema-2.6.0.tar.gz"
    sha256 "6ff5f3180870836cae40f06fa10419f557208175f13ad7bc26caa77beb1f6e02"
  end

  resource "ipython_genutils" do
    url "https://files.pythonhosted.org/packages/e8/69/fbeffffc05236398ebfcfb512b6d2511c622871dca1746361006da310399/ipython_genutils-0.2.0.tar.gz"
    sha256 "eb2e116e75ecef9d4d228fdc66af54269afa26ab4463042e33785b887c628ba8"
  end

  resource "ExifRead" do
    url "https://files.pythonhosted.org/packages/7b/cb/92b644626830115910cf2b36d3dfa600adbec86dff3207a7de3bfd6c6a60/ExifRead-2.1.2.tar.gz"
    sha256 "79e244f2eb466709029e8806fe5e2cdd557870c3db5f68954db0ef548d9320ad"
  end

  resource "decorator" do
    url "https://files.pythonhosted.org/packages/c4/26/b48aaa231644bc875bb348e162d156edb18b994da900a10f4493ea995a2f/decorator-4.3.2.tar.gz"
    sha256 "33cd704aea07b4c28b3eb2c97d288a06918275dac0ecebdaf1bc8a48d98adb9e"
  end

  resource "lidar" do
    url "https://files.pythonhosted.org/packages/a8/2e/1407e52a21c696faf45f5ff0936958b421ca39d4e8c554cb2edd9f695652/lidar-0.2.3.tar.gz"
    sha256 "6486376b453ec4ce7bd14c585351410a67bc17c90e0ce7b6446b5f7c0ae9c48b"
  end

  resource "whitebox" do
    url "https://files.pythonhosted.org/packages/c2/67/d7c9c00b63c21bb5b5725b0cd8a05937ca032ed19f5f5a86136b4e432269/whitebox-0.7.0.tar.gz"
    sha256 "42b49298407f6c4360f6aa4958b302a83dfee095eb4eb494fc7280659d0d478b"
  end

  # resource "GDAL" do
  #   url "https://files.pythonhosted.org/packages/7c/b0/a2ecb10a68a319910c4681f452c83843b99c4ef6231d33a8e55b0104a50c/GDAL-2.4.0.tar.gz"
  #   sha256 "b725a580e6faa0bc17edc3e6caa1da9e6efc401fab19e8482631ee179132b4df"
  # end

  # others

  resource "nltk" do
    url "https://files.pythonhosted.org/packages/6f/ed/9c755d357d33bc1931e157f537721efb5b88d2c583fe593cc09603076cc3/nltk-3.4.zip"
    sha256 "286f6797204ffdb52525a1d21ec0a221ec68b8e3fa4f2d25f412ac8e63c70e8d"
  end

  resource "scikit-learn" do
    url "https://files.pythonhosted.org/packages/49/0e/8312ac2d7f38537361b943c8cde4b16dadcc9389760bb855323b67bac091/scikit-learn-0.20.2.tar.gz"
    sha256 "bc5bc7c7ee2572a1edcb51698a6caf11fae554194aaab9a38105d9ec419f29e6"
  end

  resource "statsmodels" do
    url "https://files.pythonhosted.org/packages/67/68/eb3ec6ab61f97216c257edddb853cc174cd76ea44b365cf4adaedcd44482/statsmodels-0.9.0.tar.gz"
    sha256 "6461f93a842c649922c2c9a9bc9d9c4834110b89de8c4af196a791ab8f42ba3b"
  end

  resource "PyOpenGL" do
    url "https://files.pythonhosted.org/packages/ce/33/ef0e3b40a3f4cbfcfb93511652673fb19d07bafac0611f01f6237d1978ed/PyOpenGL-3.1.0.zip"
    sha256 "efa4e39a49b906ccbe66758812ca81ced13a6f26931ab2ba2dba2750c016c0d0"
  end

  resource "pyqtgraph" do
    url "https://files.pythonhosted.org/packages/cd/ad/307e0280df5c19986c4206d138ec3a8954afc722cea991f4adb4a16337d9/pyqtgraph-0.10.0.tar.gz"
    sha256 "4c08ab34881fae5ecf9ddfe6c1220b9e41e6d3eb1579a7d8ef501abb8e509251"
  end

  resource "gmt-python" do
    url "https://files.pythonhosted.org/packages/30/de/c5a0a37c9e656212872a40ac38e8f675e222789d8403e2c410503cd2b140/gmt-python-0.1a3.tar.gz"
    sha256 "91f719838f6d376bc472eb22d82e3ecccf7fca689600d47ce80c48e24784f59a"
  end

  resource "Pyro4" do
    url "https://files.pythonhosted.org/packages/a9/e6/07950f8efd3e6c781c46873c4f346fa6e56ca99330803511c956edd1096b/Pyro4-4.75.tar.gz"
    sha256 "3897c0254046d4cb412a4d1a8f2f9c2c1c1ae643a24db07d0abdb51acdb8d7b5"
  end

  resource "GitPython" do
    url "https://files.pythonhosted.org/packages/4d/e8/98e06d3bc954e3c5b34e2a579ddf26255e762d21eb24fede458eff654c51/GitPython-2.1.11.tar.gz"
    sha256 "8237dc5bfd6f1366abeee5624111b9d6879393d84745a507de0fda86043b65a8"
  end

  resource "asn1crypto" do
    url "https://files.pythonhosted.org/packages/fc/f1/8db7daa71f414ddabfa056c4ef792e1461ff655c2ae2928a2b675bfed6b4/asn1crypto-0.24.0.tar.gz"
    sha256 "9d5c20441baf0cb60a4ac34cc447c6c189024b6b4c6cd7877034f4965c464e49"
  end

  resource "cryptography" do
    url "https://files.pythonhosted.org/packages/69/ed/5e97b7f54237a9e4e6291b6e52173372b7fa45ca730d36ea90b790c0059a/cryptography-2.5.tar.gz"
    sha256 "4946b67235b9d2ea7d31307be9d5ad5959d6c4a8f98f900157b47abddf698401"
  end

  resource "gitdb2" do
    url "https://files.pythonhosted.org/packages/c4/5c/579abccd59187eaf6b3c8a4a6ecd86fce1dfd818155bfe4c52ac28dca6b7/gitdb2-2.0.5.tar.gz"
    sha256 "83361131a1836661a155172932a13c08bda2db3674e4caa32368aa6eb02f38c2"
  end

  resource "gitdb" do
    url "https://files.pythonhosted.org/packages/e3/95/7e5d7261feb46c0539ac5e451be340ddd64d78c5118f2d893b052c76fe8c/gitdb-0.6.4.tar.gz"
    sha256 "a3ebbc27be035a2e874ed904df516e35f4a29a778a764385de09de9e0f139658"
  end

  resource "pubsub" do
    url "https://files.pythonhosted.org/packages/1b/6a/587dd0d9ab5e1a9ff0d71be6e251640644e3b692cbf65a8772b787300b58/pubsub-0.1.2.tar.gz"
    sha256 "9b91d0e492f7a1f07de8bea9bc381897d42e33cd1e348192699eb8bb436c8a55"
  end

  resource "pycparser" do
    url "https://files.pythonhosted.org/packages/68/9e/49196946aee219aead1290e00d1e7fdeab8567783e83e1b9ab5585e6206a/pycparser-2.19.tar.gz"
    sha256 "a988718abfad80b6b157acce7bf130a30876d27603738ac39f140993246b25b3"
  end

  resource "pytils" do
    url "https://files.pythonhosted.org/packages/c6/c1/12b556b5bb393ce5130d57af862d045f57fee764797c0fe837e49cb2a5da/pytils-0.3.tar.gz"
    sha256 "1e85118d095d48928fef1a73e3e1dccdbc07bc931131705976b7dd05b66627fc"
  end

  resource "smmap" do
    url "https://files.pythonhosted.org/packages/bc/aa/b744b3761fff1b10579df996a2d2e87f124ae07b8336e37edc89cc502f86/smmap-0.9.0.tar.gz"
    sha256 "0e2b62b497bd5f0afebc002eda4d90df9d209c30ef257e8673c90a6b5c119d62"
  end

  resource "smmap2" do
    url "https://files.pythonhosted.org/packages/3b/ba/e49102b3e8ffff644edded25394b2d22ebe3e645f3f6a8139129c4842ffe/smmap2-2.0.5.tar.gz"
    sha256 "29a9ffa0497e7f2be94ca0ed1ca1aa3cd4cf25a1f6b4f5f87f74b46ed91d609a"
  end

  resource "gnm" do
    url "https://files.pythonhosted.org/packages/4e/c6/dba4aacba9dd9ab4c5a723b155813b242ef87ec2444ad36604926fa33e9b/gnm-1.0.4.tar.gz"
    sha256 "2aeb5ab50401a930e11c3ef0dbd452fa6af3ed7e82ad03f4ab8f2b9eedf4a5b6"
  end

  # optional for pandas

  resource "beautifulsoup4" do
    url "https://files.pythonhosted.org/packages/80/f2/f6aca7f1b209bb9a7ef069d68813b091c8c3620642b568dac4eb0e507748/beautifulsoup4-4.7.1.tar.gz"
    sha256 "945065979fb8529dd2f37dbb58f00b661bdbcbebf954f93b32fdf5263ef35348"
  end

  resource "blosc" do
    url "https://files.pythonhosted.org/packages/f4/8f/024a70d6af0b0dd736954a16b2a4be544a2b61ef6c0f660e5221accd4f8c/blosc-1.7.0.tar.gz"
    sha256 "7ffa7d243a980f5d9e63d7a1f8934803d986398f0aec058345095e47f0cabc72"
  end

  resource "bottleneck" do
    url "https://files.pythonhosted.org/packages/05/ae/cedf5323f398ab4e4ff92d6c431a3e1c6a186f9b41ab3e8258dff786a290/Bottleneck-1.2.1.tar.gz"
    sha256 "6efcde5f830aed64feafca0359b51db0e184c72af8ba6675b4a99f263922eb36"
  end

  resource "numexpr" do
    url "https://files.pythonhosted.org/packages/82/a0/42e0f42d79e0db81e78424828dee1aea08a06da66c2bc06068742e9b860f/numexpr-2.6.9.tar.gz"
    sha256 "fc218b777cdbb14fa8cff8f28175ee631bacabbdd41ca34e061325b6c44a6fa6"
  end

  resource "openpyxl" do
    url "https://files.pythonhosted.org/packages/41/a8/257a30b5b7ce0e548bc03f5be3d4b262140c1f7a506038da63cd1f4d34ad/openpyxl-2.6.0.tar.gz"
    sha256 "70da6b45a5925285b6a3d93570b45f4402eb2d335740163a58eef533b139565c"
  end

  resource "pandas-datareader" do
    url "https://files.pythonhosted.org/packages/ac/7d/15392ca70fc9fc988423568e78a56370a632237583cfdcb7605f3740fb88/pandas-datareader-0.7.0.tar.gz"
    sha256 "7dee3fe6fa483c8c2ee4f1af91a65b542c5446d75a6fc25c832cad1ffca8ef0b"
  end

  resource "qtpy" do
    url "https://files.pythonhosted.org/packages/60/eb/97613c6faf3df25be90107a5affe934bb0b240a4048d639d1f116dbae630/QtPy-1.6.0.tar.gz"
    sha256 "fd5c09655e58bf3a013d2940e71f069732ed67f056d4dcb2b0609a3ecd9b320f"
  end

  resource "sqlalchemy" do
    url "https://files.pythonhosted.org/packages/c6/52/73d1c92944cd294a5b165097038418abb6a235f5956d43d06f97254f73bf/SQLAlchemy-1.2.17.tar.gz"
    sha256 "52a42dbf02d0562d6e90e7af59f177f1cc027e72833cc29c3a821eefa009c71d"
  end

  resource "xlsxwriter" do
    url "https://files.pythonhosted.org/packages/fe/d3/bfd7da98e4465fc82b2cc890085d3aab8a5702429a68e77be9086c249919/XlsxWriter-1.1.3.tar.gz"
    sha256 "e9aa1fc246d1683ca54bca81223e60123a2781dd3b67cc05daa328b0c1f3fbe7"
  end

  resource "olefile" do
    url "https://files.pythonhosted.org/packages/34/81/e1ac43c6b45b4c5f8d9352396a14144bba52c8fec72a80f425f6a4d653ad/olefile-0.46.zip"
    sha256 "133b031eaf8fd2c9399b78b8bc5b8fcbe4c31e85295749bb17a87cba8f3c3964"
  end

  # grass

  resource "argparse" do
    url "https://files.pythonhosted.org/packages/18/dd/e617cfc3f6210ae183374cd9f6a26b20514bbb5a792af97949c5aacddf0f/argparse-1.4.0.tar.gz"
    sha256 "62b089a55be1d8949cd2bc7e0df0bddb9e028faefc8c32038cc84862aefdd6e4"
  end

  resource "subprocess32" do
    url "https://files.pythonhosted.org/packages/be/2b/beeba583e9877e64db10b52a96915afc0feabf7144dcbf2a0d0ea68bf73d/subprocess32-3.5.3.tar.gz"
    sha256 "6bc82992316eef3ccff319b5033809801c0c3372709c5f6985299c88ac7225c3"
  end

  resource "backports.functools_lru_cache" do
    url "https://files.pythonhosted.org/packages/57/d4/156eb5fbb08d2e85ab0a632e2bebdad355798dece07d4752f66a8d02d1ea/backports.functools_lru_cache-1.5.tar.gz"
    sha256 "9d98697f088eb1b0fa451391f91afb5e3ebde16bbdb272819fd091151fda4f1a"
  end

  # others

  # for some reason it fails in CI, temporarily disabled
  # resource "wxPython" do
  #   url "https://files.pythonhosted.org/packages/17/74/7c3ced03c3c76b9f98e4a0edae1801755a7599ebf481c04d9f77dfff17e3/wxPython-4.0.4.tar.gz"
  #   sha256 "0d9ef4260cb2f3e23ed9dcf6baa905ba585ac7d631613cddc299c4c83463ae29"
  # end

  # for some reason it fails in CI, temporarily disabled
  resource "pymssql" do
    url "https://files.pythonhosted.org/packages/2e/81/99562b93d75f3fc5956fa65decfb35b38a4ee97cf93c1d0d3cb799fffb99/pymssql-2.1.4.tar.gz"
    sha256 "3201eb1b1263ad55b555d727ed8bed0b12b7b9de3ce5e529206e36d4be1a7afb"
  end

  resource "PyMySQL" do
    url "https://files.pythonhosted.org/packages/da/15/23ba6592920e21cb40eb0fe0ea002d2b6177beb1ca8a4c1add5a8f32754d/PyMySQL-0.9.3.tar.gz"
    sha256 "d8c059dcd81dedb85a9f034d5e22dcb4442c0b201908bede99e306d65ea7c8e7"
  end

  resource "py-postgresql" do
    url "https://files.pythonhosted.org/packages/45/fb/b652627746d727e867258019bfd81586fe17789b653f26f6bcb369366a55/py-postgresql-1.2.1.tar.gz"
    sha256 "271bef0cb340f58662cbe958d05746fb421d18f35815e6965f839c824678bb3d"
  end

  resource "py2oracle" do
    url "https://files.pythonhosted.org/packages/88/e3/4908cf35b22386c0ba9e3a9b36143eade5cd23563cfb29c39787771e0107/py2oracle-0.4.tar.gz"
    sha256 "39bd37315b1b6e477eca8a0b442fa5bae2281425012339730bfaf140ec581f52"
  end

  resource "pandas_oracle" do
    url "https://files.pythonhosted.org/packages/42/5f/439c7f43b3e890cc0f9e242856d176dca6f31585b74bbe0c63e049489a32/pandas_oracle-2.1.3.tar.gz"
    sha256 "f4fdfa2b9e22ae551474abcfa868efd82a135691ace2bfd7a9e96d9302e5d063"
  end

  # r

  resource "rpy2" do
    url "https://files.pythonhosted.org/packages/02/d1/074ffbbe7b4bf74c60b75d74c8e67a1e4515b0d85f85cd6540e39610754a/rpy2-2.9.5.tar.gz"
    sha256 "b91f8efca7d0929f2b2b3634946be892cba6c21f92acdf737399e7eedf4532db"
  end

  resource "pyRscript" do
    url "https://files.pythonhosted.org/packages/a4/3b/a3e62553aa109b0fbdaed9d8c2b89ac3b1b1ad49c56ce722106946476c4c/pyRscript-0.0.2.tar.gz"
    sha256 "78b12b1f32416e5f5ba383f6558018c062de5c14703a05a977f1584b6f5b213c"
  end

  resource "seaborn" do
    url "https://files.pythonhosted.org/packages/7a/bf/04cfcfc9616cedd4b5dd24dfc40395965ea9f50c1db0d3f3e52b050f74a5/seaborn-0.9.0.tar.gz"
    sha256 "76c83f794ca320fb6b23a7c6192d5e185a5fcf4758966a0c0a54baee46d41e2f"
  end

  resource "pycairo" do
    url "https://files.pythonhosted.org/packages/a6/54/23d6cf3e8d8f1eb30e0e58f171b6f62b2ea75c024935492373639a1a08e4/pycairo-1.18.0.tar.gz"
    sha256 "abd42a4c9c2069febb4c38fe74bfc4b4a9d3a89fea3bc2e4ba7baff7a20f783f"
  end

  resource "PyGObject" do
    url "https://files.pythonhosted.org/packages/8c/1f/76533985b054473ef6ab1ba4d9c00d62da502f8b43d3171ae588ec81ae93/PyGObject-3.30.4.tar.gz"
    sha256 "2d4423cbf169d50a3165f2dde21478a00215c7fb3f68d9d236af588c670980bb"
  end

  resource "CairoSVG" do
    url "https://files.pythonhosted.org/packages/f3/23/67e77d4ffd643287a0dfb7dc76acef05548bd1964cd355f588b93c026deb/CairoSVG-2.3.0.tar.gz"
    sha256 "66f333ef5dc79fdfbd3bbe98adc791b1f854e0461067d202fa7b15de66d517ec"
  end

  # for some reason it fails in CI, temporarily disabled
  resource "PyGTK" do
    url "https://files.pythonhosted.org/packages/85/52/3d9bb924bd2c9bdb8afd9b7994cd09160fad5948bb2eca18fd7ffa12cfdc/pygtk-2.24.0.win32-py2.6.exe"
    sha256 "16336e79f9a7913e5b2d1cf50120896495aac8892be2d352f660b905205c48db"
  end

  resource "palettable" do
    url "https://files.pythonhosted.org/packages/f5/ef/cf4480c0ebaf51c1a23f4e6c943769210c8385543af0fe0999a1d2099d5b/palettable-3.1.1.tar.gz"
    sha256 "0685b223a236bb7e2a900ef7a855ccf9a4027361c8acf400f3b350ea51870f80"
  end

  resource "pgi" do
    url "https://files.pythonhosted.org/packages/ed/92/60411ba83f86fa128932466e7ffc86d806d075da64c04d6d45c99a08f4dc/pgi-0.0.11.2.tar.gz"
    sha256 "5b011ff4d81f83eed4380b0c72876be9b5572c4ed97e2b784dce477183c934f5"
  end

  # for some reason it fails in CI, temporarily disabled
  resource "geos" do
    url "https://files.pythonhosted.org/packages/46/52/ef047a04ce59fc95cae1338b3cac5f50cf74849d3dd51c8a3a50fad50229/geos-0.2.1.tar.gz"
    sha256 "97c69520ba6081cf3135f8c37b07b1641d3a02eb3f0b75af54fc956eb9dd0bb3"
  end

  def install
    # install python environment
    venv = virtualenv_create(libexec/'vendor', "#{Formula["python"].opt_bin}/python3")
    # res = resources.map(&:name).to_set - %w[pyodbc h5py xcffib cairocffi matplotlib Shapely Rtree wxPython pymssql PyGTK geos rpy2 pyRscript] # python-dateutil
    res = resources.map(&:name).to_set - %w[pyodbc h5py Shapely Rtree pymssql PyGTK geos rpy2 pyRscript] # python-dateutil

    # fix pip._vendor.pep517.wrappers.BackendUnavailable
    system libexec/"vendor/bin/pip3", "install", "--upgrade", "-v", "setuptools", "pip<19.0.0", "wheel"

    res.each do |r|
      venv.pip_install resource(r)
    end

    venv.pip_install_and_link "pyodbc"
    venv.pip_install_and_link "h5py"
    # venv.pip_install_and_link "xcffib" # not
    # venv.pip_install_and_link "cairocffi" # not
    # venv.pip_install_and_link "matplotlib"
    venv.pip_install_and_link "Shapely"
    venv.pip_install_and_link "Rtree" # not
    # venv.pip_install_and_link "wxPython" # not
    venv.pip_install_and_link "pymssql" # not
    venv.pip_install_and_link "PyGTK" # not
    venv.pip_install_and_link "geos"

    # venv.pip_install_and_link "python-dateutil"

    if build.with?("r") || ("r-sethrfore")
      venv.pip_install resource("rpy2")

      # fix ModuleNotFoundError: No module named 'pip.req'
      system libexec/"vendor/bin/pip3", "install", "--upgrade", "-v", "setuptools", "pip==9.0.3", "wheel"
      venv.pip_install resource("pyRscript")
    end

    # upgrade pip
    system libexec/"vendor/bin/pip3", "install", "--upgrade", "-v", "setuptools", "pip", "wheel"

    cp_r "#{buildpath}/pyqgis_startup.py", "#{libexec}"
  end

  def caveats
    s = <<~EOS

      This formula was created to have more Python modules and save time using the generated bottle.

      It is not necessary to build each time a new version or revision of the QGIS formula is generated.

      It will only be updated if necessary, although you can choose to update modules if you wish,
      just remember that you will need to build QGIS again.

    EOS

    unless opts.include?("r") || ("r-sethrfore")
      s += <<~EOS
        You can use the \e[32m--with-r\e[0m or \e[32m--with-r-sethrfore\e[0m to install others useful modules.

      EOS
    end
    s
  end

  test do
    #  TODO
  end
end

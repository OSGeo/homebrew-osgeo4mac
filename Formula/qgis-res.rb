class QgisRes < Formula
  include Language::Python::Virtualenv
  desc "List of Resoruces for QGIS (Homebrew)"
  homepage "https://www.qgis.org"
  # TODO: add one for Py3 (only necessary when macOS ships a Python3 or 3rd-party isolation is needed)
  url "https://gist.githubusercontent.com/dakcarto/11385561/raw/e49f75ecec96ed7d6d3950f45ad3f30fe94d4fb2/pyqgis_startup.py"
  sha256 "385dce925fc2d29f05afd6508bc1f46ec84c0bc607cc0c8dfce78a4bb93b9c4e"
  version "1.0.0"

  # revision 1

  option "with-r", "Build with R support"

  depends_on "pkg-config" => :build
  depends_on "gcc" => :build # for gfortran
  depends_on "swig" => :build
  depends_on "openblas"
  depends_on "python"
  depends_on "numpy"
  depends_on "scipy"
  depends_on "brewsci/bio/matplotlib"
  depends_on "freetype"
  depends_on "libpng"
  depends_on "cairo"
  depends_on "py3cairo"
  depends_on "gtk+3"
  depends_on "pygobject3"
  depends_on "pygtk"
  depends_on "pygobject"
  depends_on "pyqt"

  depends_on "osgeo/osgeo4mac/gdal2"

  # R with more support: serfore/r-srf
  # https://github.com/adamhsparks/setup_macOS_for_R
  if build.with?("r")
    unless Formula["r"].opt_prefix.exist?
      depends_on "r"
    end
  end

  # needed by `psycopg2`
  depends_on "postgresql" => :recommended

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/c2/f7/c7b501b783e5a74cf1768bc174ee4fb0a8a6ee5af6afa92274ff964703e0/setuptools-40.8.0.zip"
    sha256 "6e4eec90337e849ade7103723b9a99631c1f0d19990d6e8412dc42f5ae8b304d"
  end

  resource "pip" do
    url "https://files.pythonhosted.org/packages/c8/89/ad7f27938e59db1f0f55ce214087460f65048626e2226531ba6cb6da15f0/pip-19.0.1.tar.gz"
    sha256 "e81ddd35e361b630e94abeda4a1eddd36d47a90e71eb00f38f46b57f787cd1a5"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/d8/55/221a530d66bf78e72996453d1e2dedef526063546e131d70bed548d80588/wheel-0.32.3.tar.gz"
    sha256 "029703bf514e16c8271c3821806a1c171220cc5bdd325cbf4e7da1e056a01db6"
  end

  resource "GDAL" do
    url "https://files.pythonhosted.org/packages/7c/b0/a2ecb10a68a319910c4681f452c83843b99c4ef6231d33a8e55b0104a50c/GDAL-2.4.0.tar.gz"
    sha256 "b725a580e6faa0bc17edc3e6caa1da9e6efc401fab19e8482631ee179132b4df"
  end

  # Processing plugin
  resource "numpy" do
    url "https://files.pythonhosted.org/packages/2b/26/07472b0de91851b6656cbc86e2f0d5d3a3128e7580f23295ef58b6862d6c/numpy-1.16.1.zip"
    sha256 "31d3fe5b673e99d33d70cfee2ea8fe8dccd60f265c3ed990873a88647e3dd288"
  end

  resource "scipy" do
    url "https://files.pythonhosted.org/packages/ea/c8/c296904f2c852c5c129962e6ca4ba467116b08cd5b54b7180b2e77fe06b2/scipy-1.2.0.tar.gz"
    sha256 "51a2424c8ed80e60bdb9a896806e7adaf24a58253b326fbad10f80a6d06f2214"
  end

  resource "pandas" do
    url "https://files.pythonhosted.org/packages/81/fd/b1f17f7dc914047cd1df9d6813b944ee446973baafe8106e4458bfb68884/pandas-0.24.1.tar.gz"
    sha256 "435821cb2501eabbcee7e83614bd710940dc0cf28b5afbc4bdb816c31cec71af"
  end

  resource "nltk" do
    url "https://files.pythonhosted.org/packages/6f/ed/9c755d357d33bc1931e157f537721efb5b88d2c583fe593cc09603076cc3/nltk-3.4.zip"
    sha256 "286f6797204ffdb52525a1d21ec0a221ec68b8e3fa4f2d25f412ac8e63c70e8d"
  end

  resource "ipython" do
    url "https://files.pythonhosted.org/packages/42/bb/0ed1fb1d57d697326f9e9b827d9a74b81dee56031ed7c252bc716195ad7a/ipython-7.2.0.tar.gz"
    sha256 "6a9496209b76463f1dec126ab928919aaf1f55b38beb9219af3fe202f6bbdd12"
  end

  resource "scikit-learn" do
    url "https://files.pythonhosted.org/packages/49/0e/8312ac2d7f38537361b943c8cde4b16dadcc9389760bb855323b67bac091/scikit-learn-0.20.2.tar.gz"
    sha256 "bc5bc7c7ee2572a1edcb51698a6caf11fae554194aaab9a38105d9ec419f29e6"
  end

  resource "statsmodels" do
    url "https://files.pythonhosted.org/packages/67/68/eb3ec6ab61f97216c257edddb853cc174cd76ea44b365cf4adaedcd44482/statsmodels-0.9.0.tar.gz"
    sha256 "6461f93a842c649922c2c9a9bc9d9c4834110b89de8c4af196a791ab8f42ba3b"
  end

  resource "jupyter_core" do
    url "https://files.pythonhosted.org/packages/b6/2d/2804f4de3a95583f65e5dcb4d7c8c7183124882323758996e867f47e72af/jupyter_core-4.4.0.tar.gz"
    sha256 "ba70754aa680300306c699790128f6fbd8c306ee5927976cbe48adacf240c0b7"
  end

  resource "jupyter" do
    url "https://files.pythonhosted.org/packages/fc/21/a372b73e3a498b41b92ed915ada7de2ad5e16631546329c03e484c3bf4e9/jupyter-1.0.0.zip"
    sha256 "3e1f86076bbb7c8c207829390305a2b1fe836d471ed54be66a3b8c41e7f46cc7"
  end

  resource "sympy" do
    url "https://files.pythonhosted.org/packages/dd/f6/ed485ff22efdd7b371d0dbbf6d77ad61c3b3b7e0815a83c89cbb38ce35de/sympy-1.3.tar.gz"
    sha256 "e1319b556207a3758a0efebae14e5e52c648fc1db8975953b05fff12b6871b54"
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

  resource "whitebox" do
    url "https://files.pythonhosted.org/packages/c2/67/d7c9c00b63c21bb5b5725b0cd8a05937ca032ed19f5f5a86136b4e432269/whitebox-0.7.0.tar.gz"
    sha256 "42b49298407f6c4360f6aa4958b302a83dfee095eb4eb494fc7280659d0d478b"
  end

  if build.include?("r")
    resource "pytest" do
      url "https://files.pythonhosted.org/packages/41/f8/507d1f6121293a0392f5d0850c138d9c7dac6d22f575734078da2d0f447c/pytest-4.2.0.tar.gz"
      sha256 "65aeaa77ae87c7fc95de56285282546cfa9c886dc8e5dc78313db1c25e21bc07"
    end

    resource "pip-tools" do
      url "https://files.pythonhosted.org/packages/c2/09/b89b14a8b25b254c96ebe7888d21c91d691727369ddd076a2bb4ec7b0b23/pip-tools-3.3.2.tar.gz"
      sha256 "100496b15463155f4da3df04c2ca0068677e1ee74d346ebade2d85eef4de8cda"
    end

    resource "Sphinx" do
      url "https://files.pythonhosted.org/packages/dd/f8/df628d41f42793d446285767164c6a8da71d82892f2c98c43e0523836d39/Sphinx-1.8.4.tar.gz"
      sha256 "c1c00fc4f6e8b101a0d037065043460dffc2d507257f2f11acaed71fd2b0c83c"
    end

    resource "sphinxcontrib-websupport" do
      url "https://files.pythonhosted.org/packages/07/7a/e74b06dce85555ffee33e1d6b7381314169ebf7e31b62c18fcb2815626b7/sphinxcontrib-websupport-1.1.0.tar.gz"
      sha256 "9de47f375baf1ea07cdb3436ff39d7a9c76042c10a769c52353ec46e4e8fc3b9"
    end

    resource "rpy2" do
      url "https://files.pythonhosted.org/packages/02/d1/074ffbbe7b4bf74c60b75d74c8e67a1e4515b0d85f85cd6540e39610754a/rpy2-2.9.5.tar.gz"
      sha256 "b91f8efca7d0929f2b2b3634946be892cba6c21f92acdf737399e7eedf4532db"
    end

    # resource "pyRscript" do
    #   url "https://files.pythonhosted.org/packages/a4/3b/a3e62553aa109b0fbdaed9d8c2b89ac3b1b1ad49c56ce722106946476c4c/pyRscript-0.0.2.tar.gz"
    #   sha256 "78b12b1f32416e5f5ba383f6558018c062de5c14703a05a977f1584b6f5b213c"
    # end

    resource "pyRscript" do
      url "https://github.com/chairco/pyRscript.git",
        :branch => "master",
        :commit => "e952f450a873de52baa4fe80ed901f0cf990c0b7"
      version "0.0.2"
    end
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

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/b9/b8/6b32b3e84014148dcd60dd05795e35c2e7f4b72f918616c61fdce83d27fc/pyparsing-2.3.1.tar.gz"
    sha256 "66c9268862641abcac4a96ba74506e594c884e3f57690a696d21ad8210ed667a"
  end

  # resource "matplotlib" do
  #   url "https://files.pythonhosted.org/packages/89/0c/653aec68e9cfb775c4fbae8f71011206e5e7fe4d60fcf01ea1a9d3bc957f/matplotlib-3.0.2.tar.gz"
  #   sha256 "c94b792af431f6adb6859eb218137acd9a35f4f7442cea57e4a59c54751c36af"
  # end

  # resource "matplotlib" do
  #   url "https://files.pythonhosted.org/packages/eb/a0/31b6ba00bc4dcbc06f0b80d1ad6119a9cc3081ecb04a00117f6c1ca3a084/matplotlib-2.2.3.tar.gz"
  #   sha256 "7355bf757ecacd5f0ac9dd9523c8e1a1103faadf8d33c22664178e17533f8ce5"
  # end

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

  # MetaSearch plugin
  resource "OWSLib" do
    url "https://files.pythonhosted.org/packages/07/15/9609cbb31c9f7ce729d444c04319c1e68a1ae3fd377a93c7615392c0b1e0/OWSLib-0.17.1.tar.gz"
    sha256 "b2e7fd694d3cffcee79317bad492d60c0aa887aea6916517c051c3247b33b5a5"
  end

  # dependence for pyproj
  resource "cython" do
    url "https://files.pythonhosted.org/packages/cf/e2/03af631ca4a2cf7bc392dd8785c7cc427bff3af4bf5864cdde734f80d052/Cython-0.29.4.tar.gz"
    sha256 "d1ee3d39c73a094ae5b6e2f9263ae0dc61af1b549a0869ade8c3c30325ed9f26"
  end

  # resource "pyproj" do
  #   url "https://files.pythonhosted.org/packages/26/8c/1da0580f334718e04f8bbf74f0515a7fb8185ff96b2560ce080c11aa145b/pyproj-1.9.6.tar.gz"
  #   sha256 "e0c02b1554b20c710d16d673817b2a89ff94738b0b537aead8ecb2edc4c4487b"
  # end

  resource "pyproj" do
    url "https://github.com/jswhit/pyproj.git",
      :branch => "master",
      :commit => "263e283bce209ec7a6e4517828a31839545f2e8a"
    version "1.9.6"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/0e/01/68747933e8d12263d41ce08119620d9a7e5eb72c876a3442257f74490da0/python-dateutil-2.7.5.tar.gz"
    sha256 "88f9287c0174266bb0d8cedd395cfba9c58e87e5ad86b2ce58859bc11be3cf02"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/af/be/6c59e30e208a5f28da85751b93ec7b97e4612268bb054d0dff396e758a90/pytz-2018.9.tar.gz"
    sha256 "d5f05e487007e29e03409f9398d074e158d920d36eb82eaf66fb1136b0c5374c"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/52/2c/514e4ac25da2b08ca5a464c50463682126385c4272c18193876e91f4bc38/requests-2.21.0.tar.gz"
    sha256 "502a824f31acdacb3a35b6690b5fbf0bc41d63a24a45c4004352b0242707598e"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"
    sha256 "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"
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

  resource "future" do
    url "https://files.pythonhosted.org/packages/90/52/e20466b85000a181e1e144fd8305caf2cf475e2f9674e797b222f8105f5f/future-0.17.1.tar.gz"
    sha256 "67045236dcfd6816dc439556d009594abf643e5eb48992e36beac09c2ca659b8"
  end

  resource "mock" do
    url "https://files.pythonhosted.org/packages/0c/53/014354fc93c591ccc4abff12c473ad565a2eb24dcd82490fae33dbf2539f/mock-2.0.0.tar.gz"
    sha256 "b158b6df76edd239b8208d481dc46b6afd45a846b7812ff0ce58971cf5bc8bba"
  end

  resource "nose2" do
    url "https://files.pythonhosted.org/packages/1b/c5/d5fcd60f5bf8af1e320fde832d7965933581a9b21b0d1b29bbe2208f4403/nose2-0.8.0.tar.gz"
    sha256 "9052f2b46807b63d9bdf68e0768da1f8386368889b50043fd5d0889c470258f3"
  end

  resource "nose" do
    url "https://files.pythonhosted.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz"
    sha256 "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98"
  end

  resource "pbr" do
    url "https://files.pythonhosted.org/packages/4e/cc/691ba51448695510978855c07753344ca27af1d881a05f03b56dd8087570/pbr-5.1.2.tar.gz"
    sha256 "d717573351cfe09f49df61906cd272abaa759b3e91744396b804965ff7bff38b"
  end

  # DB Manager plugin and Processing plugin
  resource "psycopg2" do
    url "https://files.pythonhosted.org/packages/63/54/c039eb0f46f9a9406b59a638415c2012ad7be9b4b97bfddb1f48c280df3a/psycopg2-2.7.7.tar.gz"
    sha256 "f4526d078aedd5187d0508aa5f9a01eae6a48a470ed678406da94b4cd6524b7e"
  end

  # Processing plugin
  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/9e/a3/1d13970c3f36777c583f136c136f804d70f500168edc1edea6daa7200769/PyYAML-3.13.tar.gz"
    sha256 "3ef3092145e9b70e3ddd2c7ad59bdd0252a94dfe3949721633e41344de00a6bf"
  end

  # MetaSearch plugin
  resource "Jinja2" do
    url "https://files.pythonhosted.org/packages/56/e6/332789f295cf22308386cf5bbd1f4e00ed11484299c5d7383378cf48ba47/Jinja2-2.10.tar.gz"
    sha256 "f84be1bb0040caca4cea721fcbbbbd61f9be9464ca236387158b0feea01914a4"
  end

  resource "MarkupSafe" do
    url "https://files.pythonhosted.org/packages/ac/7e/1b4c2e05809a4414ebce0892fe1e32c14ace86ca7d50c70f00979ca9b3a3/MarkupSafe-1.1.0.tar.gz"
    sha256 "4e97332c9ce444b0c2c38dd22ddc61c743eb208d916e4265a2a3b575bdccb1d3"
  end

  # MetaSearch plugin
  resource "Pygments" do
    url "https://files.pythonhosted.org/packages/64/69/413708eaf3a64a6abb8972644e0f20891a55e621c6759e2c3f3891e05d63/Pygments-2.3.1.tar.gz"
    sha256 "5ffada19f6203563680669ee7f53b64dabbeb100eb51b61996085e99c03b284a"
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

  resource "ExifRead" do
    url "https://files.pythonhosted.org/packages/7b/cb/92b644626830115910cf2b36d3dfa600adbec86dff3207a7de3bfd6c6a60/ExifRead-2.1.2.tar.gz"
    sha256 "79e244f2eb466709029e8806fe5e2cdd557870c3db5f68954db0ef548d9320ad"
  end

  resource "GitPython" do
    url "https://files.pythonhosted.org/packages/4d/e8/98e06d3bc954e3c5b34e2a579ddf26255e762d21eb24fede458eff654c51/GitPython-2.1.11.tar.gz"
    sha256 "8237dc5bfd6f1366abeee5624111b9d6879393d84745a507de0fda86043b65a8"
  end

  resource "PySAL" do
    url "https://files.pythonhosted.org/packages/83/7e/73a34dbe08c6a03e7e776f518cc2a681bdfa96b012adfb3b70375fc9966c/pysal-2.0.0.tar.gz"
    sha256 "e8dc75e48a6a16e89f295f7a25868671837862cb7d4862a3a171ddc80d07a23f"
  end

  resource "PyPubSub" do
    url "https://files.pythonhosted.org/packages/3b/ae/1e327cbc89b436bb5318d7b059133696e583fc1aef087621424e0c862d52/Pypubsub-4.0.3.tar.gz"
    sha256 "1c11c8ed8ac22ad2d9a4f66ca145dd2b1b2f95cb460a5496bc75760acc6d5a59"
  end

  resource "Shapely" do
    url "https://files.pythonhosted.org/packages/a2/fb/7a7af9ef7a35d16fa23b127abee272cfc483ca89029b73e92e93cdf36e6b/Shapely-1.6.4.post2.tar.gz"
    sha256 "c4b87bb61fc3de59fc1f85e71a79b0c709dc68364d9584473697aad4aa13240f"
  end

  resource "plotly" do
    url "https://files.pythonhosted.org/packages/4d/59/63a5a05532a67b1c49283e8b7885bbe55454a1eef8443e97a7479bb9964b/plotly-3.6.0.tar.gz"
    sha256 "3fd64a8dc3d6fcb5b1abe8f393319d333a94b312a1d470c30231a05b90f7fb28"
  end

  resource "asn1crypto" do
    url "https://files.pythonhosted.org/packages/fc/f1/8db7daa71f414ddabfa056c4ef792e1461ff655c2ae2928a2b675bfed6b4/asn1crypto-0.24.0.tar.gz"
    sha256 "9d5c20441baf0cb60a4ac34cc447c6c189024b6b4c6cd7877034f4965c464e49"
  end

  resource "cffi" do
    url "https://files.pythonhosted.org/packages/e7/a7/4cd50e57cc6f436f1cc3a7e8fa700ff9b8b4d471620629074913e3735fb2/cffi-1.11.5.tar.gz"
    sha256 "e90f17980e6ab0f3c2f3730e56d1fe9bcba1891eeea58966e89d352492cc74f4"
  end

  resource "cryptography" do
    url "https://files.pythonhosted.org/packages/69/ed/5e97b7f54237a9e4e6291b6e52173372b7fa45ca730d36ea90b790c0059a/cryptography-2.5.tar.gz"
    sha256 "4946b67235b9d2ea7d31307be9d5ad5959d6c4a8f98f900157b47abddf698401"
  end

  resource "decorator" do
    url "https://files.pythonhosted.org/packages/c4/26/b48aaa231644bc875bb348e162d156edb18b994da900a10f4493ea995a2f/decorator-4.3.2.tar.gz"
    sha256 "33cd704aea07b4c28b3eb2c97d288a06918275dac0ecebdaf1bc8a48d98adb9e"
  end

  resource "gitdb2" do
    url "https://files.pythonhosted.org/packages/c4/5c/579abccd59187eaf6b3c8a4a6ecd86fce1dfd818155bfe4c52ac28dca6b7/gitdb2-2.0.5.tar.gz"
    sha256 "83361131a1836661a155172932a13c08bda2db3674e4caa32368aa6eb02f38c2"
  end

  resource "gitdb" do
    url "https://files.pythonhosted.org/packages/e3/95/7e5d7261feb46c0539ac5e451be340ddd64d78c5118f2d893b052c76fe8c/gitdb-0.6.4.tar.gz"
    sha256 "a3ebbc27be035a2e874ed904df516e35f4a29a778a764385de09de9e0f139658"
  end

  # for some reason it fails in CI, temporarily disabled
  # resource "h5py" do
  #   url "https://files.pythonhosted.org/packages/43/27/a6e7dcb8ae20a4dbf3725321058923fec262b6f7835179d78ccc8d98deec/h5py-2.9.0.tar.gz"
  #   sha256 "9d41ca62daf36d6b6515ab8765e4c8c4388ee18e2a665701fef2b41563821002"
  # end

  resource "ipython_genutils" do
    url "https://files.pythonhosted.org/packages/e8/69/fbeffffc05236398ebfcfb512b6d2511c622871dca1746361006da310399/ipython_genutils-0.2.0.tar.gz"
    sha256 "eb2e116e75ecef9d4d228fdc66af54269afa26ab4463042e33785b887c628ba8"
  end

  resource "jsonschema" do
    url "https://files.pythonhosted.org/packages/58/b9/171dbb07e18c6346090a37f03c7e74410a1a56123f847efed59af260a298/jsonschema-2.6.0.tar.gz"
    sha256 "6ff5f3180870836cae40f06fa10419f557208175f13ad7bc26caa77beb1f6e02"
  end

  resource "lxml" do
    url "https://files.pythonhosted.org/packages/16/4a/b085a04d6dad79aa5c00c65c9b2bbcb2c6c22e5ac341e7968e0ad2c57e2f/lxml-4.3.0.tar.gz"
    sha256 "d1e111b3ab98613115a208c1017f266478b0ab224a67bc8eac670fa0bad7d488"
  end

  resource "nbformat" do
    url "https://files.pythonhosted.org/packages/6e/0e/160754f7ae3e984863f585a3743b0ed1702043a81245907c8fae2d537155/nbformat-4.4.0.tar.gz"
    sha256 "f7494ef0df60766b7cabe0a3651556345a963b74dbc16bc7c18479041170d402"
  end

  resource "networkx" do
    url "https://files.pythonhosted.org/packages/f3/f4/7e20ef40b118478191cec0b58c3192f822cace858c19505c7670961b76b2/networkx-2.2.zip"
    sha256 "45e56f7ab6fe81652fb4bc9f44faddb0e9025f469f602df14e3b2551c2ea5c8b"
  end

  resource "pubsub" do
    url "https://files.pythonhosted.org/packages/1b/6a/587dd0d9ab5e1a9ff0d71be6e251640644e3b692cbf65a8772b787300b58/pubsub-0.1.2.tar.gz"
    sha256 "9b91d0e492f7a1f07de8bea9bc381897d42e33cd1e348192699eb8bb436c8a55"
  end

  resource "pycparser" do
    url "https://files.pythonhosted.org/packages/68/9e/49196946aee219aead1290e00d1e7fdeab8567783e83e1b9ab5585e6206a/pycparser-2.19.tar.gz"
    sha256 "a988718abfad80b6b157acce7bf130a30876d27603738ac39f140993246b25b3"
  end

  resource "pyodbc" do
    url "https://files.pythonhosted.org/packages/0f/aa/733a4326bfdef7deff954aa109ded6acf29d802a91fd87eedf6fc46fd91c/pyodbc-4.0.25.tar.gz"
    sha256 "0ea8c8ed37c9abf8eb411e5148409a4cb05e0da2c03a694a07b17011d0ca7cad"
  end

  resource "pytils" do
    url "https://files.pythonhosted.org/packages/c6/c1/12b556b5bb393ce5130d57af862d045f57fee764797c0fe837e49cb2a5da/pytils-0.3.tar.gz"
    sha256 "1e85118d095d48928fef1a73e3e1dccdbc07bc931131705976b7dd05b66627fc"
  end

  resource "retrying" do
    url "https://files.pythonhosted.org/packages/44/ef/beae4b4ef80902f22e3af073397f079c96969c69b2c7d52a57ea9ae61c9d/retrying-1.3.3.tar.gz"
    sha256 "08c039560a6da2fe4f2c426d0766e284d3b736e355f8dd24b37367b0bb41973b"
  end

  resource "simplejson" do
    url "https://files.pythonhosted.org/packages/e3/24/c35fb1c1c315fc0fffe61ea00d3f88e85469004713dab488dee4f35b0aff/simplejson-3.16.0.tar.gz"
    sha256 "b1f329139ba647a9548aa05fb95d046b4a677643070dc2afc05fa2e975d09ca5"
  end

  resource "smmap" do
    url "https://files.pythonhosted.org/packages/bc/aa/b744b3761fff1b10579df996a2d2e87f124ae07b8336e37edc89cc502f86/smmap-0.9.0.tar.gz"
    sha256 "0e2b62b497bd5f0afebc002eda4d90df9d209c30ef257e8673c90a6b5c119d62"
  end

  resource "smmap2" do
    url "https://files.pythonhosted.org/packages/3b/ba/e49102b3e8ffff644edded25394b2d22ebe3e645f3f6a8139129c4842ffe/smmap2-2.0.5.tar.gz"
    sha256 "29a9ffa0497e7f2be94ca0ed1ca1aa3cd4cf25a1f6b4f5f87f74b46ed91d609a"
  end

  resource "test" do
    url "https://files.pythonhosted.org/packages/ce/1e/e9014a68395e6644f2a8bef7043eb3250f4341d1151700c7dc393f63911f/test-2.3.4.5.tar.gz"
    sha256 "18808a00b57ed3c1c2da02ad0e7f37af55ea8b0058e86cf086baaf3b7aac2e64"
  end

  resource "tools" do
    url "https://files.pythonhosted.org/packages/de/20/2a2dddb083fd0ce56b453cf016768b2c49f3c0194090500f78865b7d110c/tools-0.1.9.tar.gz"
    sha256 "7b7f998462cf5b02635fba76cc7cdb3653468aa46ff074b979dbecdb2a2fb014"
  end

  resource "traitlets" do
    url "https://files.pythonhosted.org/packages/a5/98/7f5ef2fe9e9e071813aaf9cb91d1a732e0a68b6c44a32b38cb8e14c3f069/traitlets-4.3.2.tar.gz"
    sha256 "9c4bd2d267b7153df9152698efb1050a5d84982d3384a37b2c1f7723ba3e7835"
  end

  resource "xlrd" do
    url "https://files.pythonhosted.org/packages/aa/05/ec9d4fcbbb74bbf4da9f622b3b61aec541e4eccf31d3c60c5422ec027ce2/xlrd-1.2.0.tar.gz"
    sha256 "546eb36cee8db40c3eaa46c351e67ffee6eeb5fa2650b71bc4c758a29a1b29b2"
  end

  resource "xlwt" do
    url "https://files.pythonhosted.org/packages/06/97/56a6f56ce44578a69343449aa5a0d98eefe04085d69da539f3034e2cd5c1/xlwt-1.3.0.tar.gz"
    sha256 "c59912717a9b28f1a3c2a98fd60741014b06b043936dcecbc113eaaada156c88"
  end

  resource "OSR" do
    url "https://files.pythonhosted.org/packages/22/f3/469a6e1612fe2e9cd2c955148e375a663f9b91157e077eff4dd8c6064686/OSR-0.0.1.tar.gz"
    sha256 "fbb85b9ae07fcf44c0ea64eae2fcf0e487454a26b7d2a543ebdde4908c7bf81e"
  end

  resource "ogr" do
    url "https://files.pythonhosted.org/packages/3c/0a/95bac909f21040411f571c622606d73b101a3aba77601f84177abd55ce48/ogr-0.0.1.tar.gz"
    sha256 "238b26b4bdf9a1037fd819d3584250c6a3879535507bd0b673ad796bd3136d45"
  end

  resource "gnm" do
    url "https://files.pythonhosted.org/packages/4e/c6/dba4aacba9dd9ab4c5a723b155813b242ef87ec2444ad36604926fa33e9b/gnm-1.0.4.tar.gz"
    sha256 "2aeb5ab50401a930e11c3ef0dbd452fa6af3ed7e82ad03f4ab8f2b9eedf4a5b6"
  end

  resource "ply" do
    url "https://files.pythonhosted.org/packages/e5/69/882ee5c9d017149285cab114ebeab373308ef0f874fcdac9beb90e0ac4da/ply-3.11.tar.gz"
    sha256 "00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3"
  end

  resource "pep8" do
    url "https://files.pythonhosted.org/packages/01/a0/64ba19519db49e4094d82599412a9660dee8c26a7addbbb1bf17927ceefe/pep8-1.7.1.tar.gz"
    sha256 "fe249b52e20498e59e0b5c5256aa52ee99fc295b26ec9eaa85776ffdb9fe6374"
  end

  resource "pexpect" do
    url "https://files.pythonhosted.org/packages/89/43/07d07654ee3e25235d8cea4164cdee0ec39d1fda8e9203156ebe403ffda4/pexpect-4.6.0.tar.gz"
    sha256 "2a8e88259839571d1251d278476f3eec5db26deb73a70be5ed5dc5435e418aba"
  end

  resource "expect" do
    url "https://files.pythonhosted.org/packages/86/9a/4944ecc222f24d18e8d2819800472ffc2668e52986afd5c7bc41ecaf897b/expects-0.9.0.tar.gz"
    sha256 "419902ccafe81b7e9559eeb6b7a07ef9d5c5604eddb93000f0642b3b2d594f4c"
  end

  resource "capturer" do
    url "https://files.pythonhosted.org/packages/ce/a4/fabb849584366383a59d2ac985a7ece30609f1ae4a40ecfd02baad900a2d/capturer-2.4.tar.gz"
    sha256 "090142a58f3f85def3a7dd55d9024d0d1a86d1a88aaf9317c0f146244994a615"
  end

  # work with Python 2.4 or later, will not work under any version of Python 3
  # resource "supervisor" do
  #   url "https://files.pythonhosted.org/packages/ba/65/92575a8757ed576beaee59251f64a3287bde82bdc03964b89df9e1d29e1b/supervisor-3.3.5.tar.gz"
  #   sha256 "1b4d6d2e551dcb49e928cfffea857b8cca6b64a4a8fb755dcf86addf62866af0"
  # end

  def install
    # install python environment
    venv = virtualenv_create(libexec/'vendor', "#{Formula["python"].opt_bin}/python3")

    res = resources.map(&:name).to_set - %w[python-dateutil pyRscript]

    if build.with?("r")
      # fix ModuleNotFoundError: No module named 'pip.req'
      system libexec/"vendor/bin/pip", "install", "--upgrade", "-v", "setuptools", "pip==9.0.3", "wheel"
      venv.pip_install_and_link "pyRscript"
    end

    # fix pip._vendor.pep517.wrappers.BackendUnavailable
    system libexec/"vendor/bin/pip", "install", "--upgrade", "-v", "setuptools", "pip<19.0.0", "wheel"
    venv.pip_install_and_link "python-dateutil"

    res.each do |r|
      venv.pip_install resource(r)
    end

    cp_r "#{buildpath}/pyqgis_startup.py", "#{libexec}"
  end

  def caveats
    s = <<~EOS

    This formula was created to have more Python modules and save time using the generated bottle.

    It is not necessary to build each time a new version or revision of the QGIS formula is generated.

    It will only be updated if necessary, although you can choose to update modules if you wish,
    just remember that you will need to build QGIS again.

    EOS
    s
  end

  test do
    #  TODO
  end
end

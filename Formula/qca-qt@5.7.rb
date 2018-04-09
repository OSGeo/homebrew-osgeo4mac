class QcaQtAT57 < Formula
  desc "Qt Cryptographic Architecture (QCA)"
  homepage "http://delta.affinix.com/qca/"
  head "https://anongit.kde.org/qca.git"

  stable do
    url "https://github.com/KDE/qca/archive/v2.1.1.tar.gz"
    sha256 "aa8ec328da163a5e20ac59146e56b17d0677789f020d0c3875c4ed5e9e82e749"

    # Fix for linking CoreFoundation and removing deprecated code (already in HEAD)
    patch do
      url "https://github.com/KDE/qca/commit/f223ce03d4b94ffbb093fc8be5adf8d968f54434.diff"
      sha256 "75ef105b01658c3b4030b8c697338dbceddbcc654b022162b284e0fa8df582b5"
    end

    # Fix for framework installation (already in HEAD)
    patch do
      url "https://github.com/KDE/qca/commit/9e4bf795434304bce32626fe0f6887c10fec0824.diff"
      sha256 "5f4e575d2c9f55090c7e3358dc27b6e22cccecaaee264d1638aabac86421c314"
    end
  end

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    sha256 "f478153f18c3640a42d0dbe22495e194d2ddeb8c55ab8d67d08a9b850a4b9ed3" => :sierra
  end

  keg_only "Qt5 is keg-only"

  option "with-api-docs", "Build API documentation"

  deprecated_option "with-gnupg" => "with-gpg2"
  deprecated_option "with-qt" => "with-qt@5.7"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "qt@5.7" => :recommended

  # Plugins (QCA needs at least one plugin to do anything useful)
  depends_on "openssl" # qca-ossl
  depends_on "botan" => :optional # qca-botan
  depends_on "libgcrypt" => :optional # qca-gcrypt
  depends_on "gpg" => :optional # qca-gnupg
  depends_on "nss" => :optional # qca-nss
  depends_on "pkcs11-helper" => :optional # qca-pkcs11

  if build.with? "api-docs"
    depends_on "graphviz" => :build
    depends_on "doxygen" => [:build, "with-graphviz"]
  end

  def install
    odie "Qt dependency must be defined" if build.without?("qt") && build.without?("qt@5.7")

    args = std_cmake_args
    args << "-DQT4_BUILD=OFF"
    args << "-DBUILD_TESTS=OFF"

    # Plugins (qca-ossl, qca-cyrus-sasl, qca-logger, qca-softstore always built)
    args << "-DWITH_botan_PLUGIN=#{build.with?("botan") ? "YES" : "NO"}"
    args << "-DWITH_gcrypt_PLUGIN=#{build.with?("libgcrypt") ? "YES" : "NO"}"
    args << "-DWITH_gnupg_PLUGIN=#{build.with?("gpg2") ? "YES" : "NO"}"
    args << "-DWITH_nss_PLUGIN=#{build.with?("nss") ? "YES" : "NO"}"
    args << "-DWITH_pkcs11_PLUGIN=#{build.with?("pkcs11-helper") ? "YES" : "NO"}"

    system "cmake", ".", *args
    system "make", "install"

    if build.with? "api-docs"
      system "make", "doc"
      doc.install "apidocs/html"
    end
  end

  test do
    system bin/"qcatool-qt5", "--noprompt", "--newpass=",
                              "key", "make", "rsa", "2048", "test.key"
  end
end

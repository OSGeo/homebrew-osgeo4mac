class QcaQt4 < Formula
  desc "Qt Cryptographic Architecture (QCA)"
  homepage "http://delta.affinix.com/qca/"
  head "https://anongit.kde.org/qca.git"

  stable do
    url "https://github.com/KDE/qca/archive/v2.1.1.tar.gz"
    sha256 "aa8ec328da163a5e20ac59146e56b17d0677789f020d0c3875c4ed5e9e82e749"

    # Fix for linking CoreFoundation and removing deprecated code; already in HEAD).
    patch do
      url "https://github.com/KDE/qca/commit/f223ce03d4b94ffbb093fc8be5adf8d968f54434.diff"
      sha256 "78f0239c7007f7bf74c94c90f142f49d4b748a2c7a2d56eaed38dc5ee3fd6ee1"
    end

    # Fix for framework installation; already in HEAD).
    patch do
      url "https://github.com/KDE/qca/commit/9e4bf795434304bce32626fe0f6887c10fec0824.diff"
      sha256 "952e1fc4f96db0ee11e7dca0013e81e512fe79ac0c4b3cf993ce8c7f0061a016"
    end
  end

  bottle do
    root_url "http://qgis.dakotacarto.com/bottles"
    sha256 "61d5c196db97b6b951ad3287acc5824e02863e45e15d2901fb1c5206372bca77" => :sierra
  end

  keg_only "Newer Qt5-only version in homebrew-core"

  option "with-api-docs", "Build API documentation"

  deprecated_option "with-gnupg" => "with-gpg2"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "qt-4"

  # Plugins (QCA needs at least one plugin to do anything useful)
  depends_on "openssl" # qca-ossl
  depends_on "botan" => :optional # qca-botan
  depends_on "libgcrypt" => :optional # qca-gcrypt
  depends_on :gpg => [:optional, :run] # qca-gnupg
  depends_on "nss" => :optional # qca-nss
  depends_on "pkcs11-helper" => :optional # qca-pkcs11

  if build.with? "api-docs"
    depends_on "graphviz" => :build
    depends_on "doxygen" => [:build, "with-graphviz"]
  end

  def install
    args = std_cmake_args
    args << "-DQT4_BUILD=ON"
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
    system bin/"qcatool", "--noprompt", "--newpass=",
                          "key", "make", "rsa", "2048", "test.key"
  end
end

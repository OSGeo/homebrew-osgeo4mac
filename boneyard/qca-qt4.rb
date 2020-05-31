class QcaQt4 < Formula
  desc "Qt Cryptographic Architecture (QCA)"
  homepage "http://delta.affinix.com/qca/"
  head "https://anongit.kde.org/qca.git"

  stable do
    url "https://github.com/KDE/qca/archive/v2.1.1.tar.gz"
    sha256 "aa8ec328da163a5e20ac59146e56b17d0677789f020d0c3875c4ed5e9e82e749"

    # Fix for linking CoreFoundation and removing deprecated code; already in HEAD).
    patch do
      url "https://github.com/KDE/qca/commit/f223ce03d4b94ffbb093fc8be5adf8d968f54434.diff?full_index=1"
      sha256 "e882bfa4a290d62a7ddea8c05019d5e616234027c95f7f8339072af03a2e6bc7"
    end

    # Fix for framework installation; already in HEAD).
    patch do
      url "https://github.com/KDE/qca/commit/9e4bf795434304bce32626fe0f6887c10fec0824.diff?full_index=1"
      sha256 "a7dc91e0d68b38712fbe2228f3c028090e6e2f8ba3a74b334b46bae4276430ee"
    end
  end

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    rebuild 1
    sha256 "b36a88ea9d3f7d2588341e37e9b2c6d4580cb1de1cdafa2a09a4571d5afe722f" => :high_sierra
    sha256 "b36a88ea9d3f7d2588341e37e9b2c6d4580cb1de1cdafa2a09a4571d5afe722f" => :sierra
  end

  keg_only "newer Qt5-only version in homebrew-core"

  option "with-api-docs", "Build API documentation"

  deprecated_option "with-gnupg" => "with-gpg2"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "qt-4"

  # Plugins (QCA needs at least one plugin to do anything useful)
  depends_on "openssl" # qca-ossl
  depends_on "botan" => :optional # qca-botan
  depends_on "libgcrypt" => :optional # qca-gcrypt
  depends_on "gnupg"
  depends_on "nss" => :optional # qca-nss
  depends_on "pkcs11-helper" => :optional # qca-pkcs11

  if build.with? "api-docs"
    depends_on "graphviz" => :build
    depends_on "doxygen" => :build
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

class OsgeoMongoCxxDriverLegacy < Formula
  desc "C++ driver for MongoDB"
  homepage "https://github.com/mongodb/mongo-cxx-driver"
  url "https://github.com/mongodb/mongo-cxx-driver/archive/legacy-1.1.3.tar.gz"
  sha256 "50304162f706c2c73e04f200cdac767cb2c55d47cf724811cbfc8bb34a0fd6bc"

  revision 3

  head "https://github.com/mongodb/mongo-cxx-driver.git", :branch => "releases/legacy"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "eba1f1faf4e7aa27700f0daf65ac89711162244583a609e0bafc6e88060c8056" => :catalina
    sha256 "eba1f1faf4e7aa27700f0daf65ac89711162244583a609e0bafc6e88060c8056" => :mojave
    sha256 "eba1f1faf4e7aa27700f0daf65ac89711162244583a609e0bafc6e88060c8056" => :high_sierra
  end

  keg_only "Newer driver in homebrew core"

  # src/.../ssl_manager.cpp:631:23: error: BIO_s_file_internal was not declared in this scope
  # https://bugs.gentoo.org/676066
  # https://patch-diff.githubusercontent.com/raw/mongodb/mongo-cxx-driver/pull/615.patch
  patch :DATA

  depends_on "scons" => :build
  depends_on "boost"
  depends_on "openssl"
  # depends_on "openssl@1.1"

  resource "connect_test" do
    url "https://raw.githubusercontent.com/mongodb/mongo-cxx-driver/legacy/src/mongo/client/examples/tutorial.cpp"
    sha256 "39ad991cf07722312398cd9dbfefb2b8df00729c2224bdf0b644475b95a240dc"
  end

  resource "bson_test" do
    url "https://raw.githubusercontent.com/mongodb/mongo-cxx-driver/legacy/src/mongo/bson/bsondemo/bsondemo.cpp"
    sha256 "299c87b57f11e3ff9ac0fd2e8ac3f8eb174b64c673951199831a0ba176292164"
  end

  def install
    args = [
      "--prefix=#{prefix}",
      "--c++11=on",
      "--libc++",
      "--osx-version-min=10.9",
      "--extrapath=#{Formula["boost"].opt_prefix}",
      "--sharedclient",
      "--use-sasl-client",
      "--ssl",
      "--disable-warnings-as-errors",
      "--cpppath=#{Formula["openssl"].opt_include}",
      "--libpath=#{Formula["openssl"].opt_lib}",
      "install"
    ]


    system "scons", *args
  end

  test do
    # TODO

    # resource("connect_test").stage do
    #   system ENV.cxx, "-o", "test", "tutorial.cpp",
    #   "-I#{include}/",
    #   "-L#{lib}", "-lmongoclient", "-pthread", "-lboost_thread-mt", "-lboost_system", "-lboost_regex", "-std=c++11", "-stdlib=libc++"
    # assert_match "couldn't connect : couldn't connect to server 0.0.0.0:27017 (0.0.0.0), address resolved to 0.0.0.0",
    #   shell_output("./test mongodb://0.0.0.0 2>&1", 1)
    # end

    # resource("bson_test").stage do
    #   system ENV.cxx, "-o", "test", "bsondemo.cpp",
    #   "-I#{include}",
    #   "-L#{lib}", "-lmongoclient", "-lboost_thread-mt", "-lboost_system",  "-lboost_regex", "-std=c++11", "-stdlib=libc++"
    #   system "./test"
    # end
  end
end

__END__

--- a/src/mongo/client/command_writer.h
+++ b/src/mongo/client/command_writer.h
@@ -17,6 +17,11 @@

 #include "mongo/client/dbclient_writer.h"

+#include <boost/version.hpp>
+#if BOOST_VERSION >= 106700
+#include <boost/next_prior.hpp>
+#endif
+
 namespace mongo {

 class DBClientBase;

--- a/src/mongo/client/wire_protocol_writer.h
+++ b/src/mongo/client/wire_protocol_writer.h
@@ -16,6 +16,10 @@
 #pragma once

 #include "mongo/client/dbclient_writer.h"
+#include <boost/version.hpp>
+#if BOOST_VERSION >= 106700
+#include <boost/next_prior.hpp>
+#endif

 namespace mongo {


--- a/src/mongo/crypto/crypto_openssl.cpp
+++ b/src/mongo/crypto/crypto_openssl.cpp
@@ -34,19 +34,27 @@ namespace crypto {
  * Computes a SHA-1 hash of 'input'.
  */
 bool sha1(const unsigned char* input, const size_t inputLen, unsigned char* output) {
-    EVP_MD_CTX digestCtx;
-    EVP_MD_CTX_init(&digestCtx);
-    ON_BLOCK_EXIT(EVP_MD_CTX_cleanup, &digestCtx);
+    EVP_MD_CTX *digestCtx = EVP_MD_CTX_create();
+    if (!digestCtx) {
+        return false;
+    }
+
+    EVP_MD_CTX_init(digestCtx);
+    #if OPENSSL_VERSION_NUMBER < 0x10100000L
+    ON_BLOCK_EXIT(EVP_MD_CTX_destroy, digestCtx);
+    #else
+    ON_BLOCK_EXIT(EVP_MD_CTX_free, digestCtx);
+    #endif

-    if (1 != EVP_DigestInit_ex(&digestCtx, EVP_sha1(), NULL)) {
+    if (1 != EVP_DigestInit_ex(digestCtx, EVP_sha1(), NULL)) {
         return false;
     }

-    if (1 != EVP_DigestUpdate(&digestCtx, input, inputLen)) {
+    if (1 != EVP_DigestUpdate(digestCtx, input, inputLen)) {
         return false;
     }

-    return (1 == EVP_DigestFinal_ex(&digestCtx, output, NULL));
+    return (1 == EVP_DigestFinal_ex(digestCtx, output, NULL));
 }

 /*


--- a/src/mongo/util/net/ssl_manager.cpp
+++ b/src/mongo/util/net/ssl_manager.cpp
@@ -628,7 +628,12 @@ bool SSLManager::_initSSLContext(SSL_CTX** context, const Params& params) {

 bool SSLManager::_setSubjectName(const std::string& keyFile, std::string& subjectName) {
     // Read the certificate subject name and store it
-    BIO* in = BIO_new(BIO_s_file_internal());
+    BIO* in;
+    #if OPENSSL_VERSION_NUMBER < 0x10100000L
+    in = BIO_new(BIO_s_file_internal());
+    #else
+    in = BIO_new(BIO_s_file());
+    #endif
     if (NULL == in) {
         error() << "failed to allocate BIO object: " << getSSLErrorMessage(ERR_get_error()) << endl;
         return false;

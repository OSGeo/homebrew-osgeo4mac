class MongoCxxDriverLegacy < Formula
  desc "C++ driver for MongoDB"
  homepage "https://github.com/mongodb/mongo-cxx-driver"
  url "https://github.com/mongodb/mongo-cxx-driver/archive/legacy-1.1.3.tar.gz"
  sha256 "50304162f706c2c73e04f200cdac767cb2c55d47cf724811cbfc8bb34a0fd6bc"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 1
    sha256 "41339a7c0004abf77162a9c54d50f24009e7012b9ef72cba177c37a0f95a9d06" => :high_sierra
    sha256 "41339a7c0004abf77162a9c54d50f24009e7012b9ef72cba177c37a0f95a9d06" => :sierra
  end

  keg_only "Newer driver in homebrew core"

  needs :cxx11

  patch :DATA

  depends_on "scons" => :build
  depends_on "boost"

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
      "install"
    ]

    scons(*args)
  end

  test do
    resource("connect_test").stage do
      system ENV.cxx, "-o", "test", "tutorial.cpp",
      "-I#{include}/",
      "-L#{lib}", "-lmongoclient", "-pthread", "-lboost_thread-mt", "-lboost_system", "-lboost_regex", "-std=c++11", "-stdlib=libc++"
    assert_match "couldn't connect : couldn't connect to server 0.0.0.0:27017 (0.0.0.0), address resolved to 0.0.0.0",
      shell_output("./test mongodb://0.0.0.0 2>&1", 1)

    end

    resource("bson_test").stage do
      system ENV.cxx, "-o", "test", "bsondemo.cpp",
      "-I#{include}",
      "-L#{lib}", "-lmongoclient", "-lboost_thread-mt", "-lboost_system",  "-lboost_regex", "-std=c++11", "-stdlib=libc++"
      system "./test"

    end


      end
end
__END__
diff --git a/src/mongo/client/command_writer.h b/src/mongo/client/command_writer.h
index 09cd752..6d60721 100644
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
--
2.17.0
diff --git a/src/mongo/client/wire_protocol_writer.h b/src/mongo/client/wire_protocol_writer.h
index 10cc935..72bb191 100644
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

--
2.17.0

class QtkeychainQtAT57 < Formula
  desc "Platform-independent Qt API for storing passwords securely"
  homepage "https://github.com/frankosterfeld/qtkeychain"
  url "https://github.com/frankosterfeld/qtkeychain/archive/d077333d7c4bb2846b9de9f3b8631a0b58f70a7e.tar.gz"
  version "0.7.90"
  sha256 "fe766d6189ffd89f5c8303833b43b832b13e14481970466ac09821e28d103f08"

  head "https://github.com/frankosterfeld/qtkeychain.git", :using => :git

  bottle do
    root_url "http://qgis.dakotacarto.com/bottles"
    cellar :any
    sha256 "ca83e609900bee30417f87265e50775eaa4bf20ca82fc0ad1ff755a6632fd178" => :sierra
  end

  keg_only "Qt5 is keg-only"

  option "with-static", "Build static in addition to shared library"
  option "with-translations", "Generate Qt translation (.ts) files"

  depends_on "cmake" => :build
  depends_on "qt@5.7"

  def install
    args = std_cmake_args
    args << "-DQTKEYCHAIN_STATIC=OFF"
    args << "-DBUILD_WITH_QT4=OFF"
    args << "-DBUILD_TRANSLATIONS=#{build.with?("translations") ? "ON" : "OFF"}"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
      (libexec/"bin").install "testclient"
      system "install_name_tool", "-change", "@rpath/libqt5keychain.1.dylib",
             "#{opt_lib}/libqt5keychain.1.dylib",
             "#{libexec}/bin/testclient"

      if build.with? "static"
        args << "-DQTKEYCHAIN_STATIC=ON"
        system "cmake", "..", *args
        system "make"
        mv "libqtkeychain.a", lib/"libqtkeychain_static.a"
      end
    end
  end

  def caveats
    if build.with? "static"
      <<-EOS.undent
        Static library is available at:
          #{opt_lib}/libqtkeychain_static.a
      EOS
    end
  end

  test do
    assert_match "Password deleted successfully",
                 shell_output(libexec/"bin/testclient delete something")
  end
end

class Qtkeychain < Formula
  desc "Platform-independent Qt-based API for storing passwords securely"
  homepage "https://github.com/frankosterfeld/qtkeychain"
  url "https://github.com/frankosterfeld/qtkeychain/archive/v0.8.0.tar.gz"
  sha256 "b492f603197538bc04b2714105b1ab2b327a9a98d400d53d9a7cb70edd2db12f"

  head "https://github.com/frankosterfeld/qtkeychain.git", :using => :git

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    sha256 "6449adce0087b95b8d5c09b96f75e75720f09901a94393360e1e3946d921589c" => :sierra
  end

  option "with-static", "Build static in addition to shared library"
  option "with-translations", "Generate Qt translation (.ts) files"

  depends_on "cmake" => :build
  depends_on "qt"

  def lib_name
    "libqt5keychain"
  end

  def install
    args = std_cmake_args
    args << "-DQTKEYCHAIN_STATIC=OFF"
    args << "-DBUILD_WITH_QT4=OFF"
    args << "-DBUILD_TRANSLATIONS=#{build.with?("translations") ? "ON" : "OFF"}"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
      (libexec/"bin").install "testclient"
      so_ver = 1
      lib_name_ver = "#{lib_name}.#{so_ver}"
      MachO::Tools.change_install_name("#{libexec}/bin/testclient",
                                       "@rpath/#{lib_name_ver}.dylib",
                                       "#{opt_lib}/#{lib_name_ver}.dylib")

      if build.with? "static"
        args << "-DQTKEYCHAIN_STATIC=ON"
        system "cmake", "..", *args
        system "make"
        mv "#{lib_name}.a", lib/"#{lib_name}_static.a"
      end
    end
  end

  def caveats
    if build.with? "static"
      <<~EOS
        Static library is available at:
          #{opt_lib}/#{lib_name}_static.a
      EOS
    end
  end

  test do
    assert_match "Password deleted successfully",
                 shell_output(libexec/"bin/testclient delete something-particular")
  end
end

class Qtkeychain < Formula
  desc "Platform-independent Qt-based API for storing passwords securely"
  homepage "https://github.com/frankosterfeld/qtkeychain"
  url "https://github.com/frankosterfeld/qtkeychain/archive/v0.9.1.tar.gz"
  sha256 "9c2762d9d0759a65cdb80106d547db83c6e9fdea66f1973c6e9014f867c6f28e"

  head "https://github.com/frankosterfeld/qtkeychain.git", :using => :git

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    rebuild 1
    sha256 "f4349f3ff6c1fd1740c19e32596da4fc1c96361f371f0182ef9a84a65901e8df" => :mojave
    sha256 "f4349f3ff6c1fd1740c19e32596da4fc1c96361f371f0182ef9a84a65901e8df" => :high_sierra
    sha256 "f4349f3ff6c1fd1740c19e32596da4fc1c96361f371f0182ef9a84a65901e8df" => :sierra
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

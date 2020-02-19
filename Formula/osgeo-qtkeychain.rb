class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_qtkeychain_linked }

  def core_qtkeychain_linked
    Formula["qtkeychain"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink qtkeychain\e[0m or remove with brew \e[32muninstall --ignore-dependencies qtkeychain\e[0m\n\n" if core_qtkeychain_linked
    s
  end
end

class OsgeoQtkeychain < Formula
  desc "Platform-independent Qt-based API for storing passwords securely"
  homepage "https://github.com/frankosterfeld/qtkeychain"
  url "https://github.com/frankosterfeld/qtkeychain/archive/v0.10.0.tar.gz"
  sha256 "5f916cd97843de550467db32d2e10f218b904af5b21cfdfcc7c6425d7dfc3ec2"

  # revision 1

  head "https://github.com/frankosterfeld/qtkeychain.git", :using => :git

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "a9261f3ce89b4e46e1cc52415d54b993fc2716cc7ed4fd713bb57d2f78596659" => :catalina
    sha256 "a9261f3ce89b4e46e1cc52415d54b993fc2716cc7ed4fd713bb57d2f78596659" => :mojave
    sha256 "a9261f3ce89b4e46e1cc52415d54b993fc2716cc7ed4fd713bb57d2f78596659" => :high_sierra
  end

  option "with-static", "Build static in addition to shared library"
  option "with-translations", "Generate Qt translation (.ts) files"

  # keg_only "qtkeychain is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

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

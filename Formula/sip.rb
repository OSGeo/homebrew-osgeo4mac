class Sip < Formula
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/sip/sip-4.19.14.tar.gz"
  sha256 "0ef3765dbcc3b8131f83e60239f49508f82205b33cae5408c405e2e2f2d0af87"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any_skip_relocation
    rebuild 1
    sha256 "8c58738fb6a0b9c365fb2797ca5baa8041a890b681005b240fe70d6a87a7592b" => :mojave
    sha256 "8c58738fb6a0b9c365fb2797ca5baa8041a890b681005b240fe70d6a87a7592b" => :high_sierra
    sha256 "1902e507b0c5746f31b2410c19b52dc8477f97beec8ca9096fc718a72afb80fc" => :sierra
  end

  revision 3

  head "https://www.riverbankcomputing.com/hg/sip", :using => :hg

  depends_on "python"
  depends_on "python@2"

  def install
    ENV.prepend_path "PATH", Formula["python"].opt_libexec/"bin"
    ENV.delete("SDKROOT") # Avoid picking up /Application/Xcode.app paths

    if build.head?
      # Link the Mercurial repository into the download directory so
      # build.py can use it to figure out a version number.
      ln_s cached_download/".hg", ".hg"
      # build.py doesn't run with python3
      system "#{Formula["python"].opt_bin}/python3", "build.py", "prepare"
    end

    ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python"].opt_bin}/python3"].each do |python|
      version = Language::Python.major_minor_version python
      system python, "configure.py",
                     "--deployment-target=#{MacOS.version}",
                     "--destdir=#{lib}/python#{version}/site-packages",
                     "--bindir=#{bin}",
                     "--incdir=#{include}",
                     "--sipdir=#{HOMEBREW_PREFIX}/share/sip",
                     "--sip-module=PyQt5.sip",
                     "--no-dist-info"
      system "make"
      system "make", "install"
      system "make", "clean"
    end
  end

  def post_install
    (HOMEBREW_PREFIX/"share/sip").mkpath
  end

  def caveats; <<~EOS
    The sip-dir for Python is #{HOMEBREW_PREFIX}/share/sip.
  EOS
  end

  test do
    system "#{Formula["python"].opt_bin}/python3", "-c", "import PyQt5.sip"
  end
end

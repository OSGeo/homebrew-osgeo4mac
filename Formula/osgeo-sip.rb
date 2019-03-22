class OsgeoSip < Formula
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/sip/sip-4.19.15.tar.gz"
  sha256 "2b5c0b2c0266b467b365c21376d50dde61a3236722ab87ff1e8dacec283eb610"

  # revision 1

  head "https://www.riverbankcomputing.com/hg/sip", :using => :hg

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any_skip_relocation
    sha256 "ad0e3c923a1eb9ae6c93e7fe39d30fca96a9f6e77e383cc0088b915b6d14467d" => :mojave
    sha256 "ad0e3c923a1eb9ae6c93e7fe39d30fca96a9f6e77e383cc0088b915b6d14467d" => :high_sierra
    sha256 "826c8da791d81f6190a648f0515fcd6131b24a640979715e2b14ea0730715d51" => :sierra
  end

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
      system "python", "build.py", "prepare"
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
    ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python"].opt_bin}/python3"].each do |python|
      version = Language::Python.major_minor_version python
      ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
      system python, "-c", '"import PyQt5.sip"'
    end
  end
end

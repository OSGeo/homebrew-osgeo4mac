class OsgeoSip < Formula
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/sip/4.19.17/sip-4.19.17.tar.gz"
  sha256 "12bcd8f4d5feefc105bc075d12c5090ee783f7380728563c91b8b95d0ec45df3"

  # revision 1

  head "https://www.riverbankcomputing.com/hg/sip", :using => :hg

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    sha256 "e48de26148df185f46a7c24a281121c70f99b907d9a56ea8ac88e70a17d7686e" => :mojave
    sha256 "e48de26148df185f46a7c24a281121c70f99b907d9a56ea8ac88e70a17d7686e" => :high_sierra
    sha256 "9a01d4e8541dc53da7c33d9a1fe309f9aae318c0d541c09a61915bdbbc85ff95" => :sierra
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

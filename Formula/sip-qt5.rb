class SipQt5 < Formula
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/sip/sip-4.19.14.tar.gz"
  sha256 "0ef3765dbcc3b8131f83e60239f49508f82205b33cae5408c405e2e2f2d0af87"

  # revision 1

  head "https://www.riverbankcomputing.com/hg/sip", :using => :hg

  depends_on "python" => :recommended

  def install
    ENV.prepend_path "PATH", Formula["python"].opt_libexec/"bin"
    if build.head?
      # Link the Mercurial repository into the download directory so
      # build.py can use it to figure out a version number.
      ln_s cached_download/".hg", ".hg"
      # build.py doesn't run with python3
      system "#{Formula["python"].opt_bin}/python3", "build.py", "prepare"
    end

    ENV.delete("SDKROOT") # Avoid picking up /Application/Xcode.app paths
    system "#{Formula["python"].opt_bin}/python3", "configure.py",
                   "--deployment-target=#{MacOS.version}",
                   "--destdir=#{lib}/python#{py_ver}/site-packages",
                   "--bindir=#{bin}",
                   "--incdir=#{include}",
                   "--sipdir=#{HOMEBREW_PREFIX}/share/sip",
                   "--sip-module=PyQt5.sip"
    system "make"
    system "make", "install"
    system "make", "clean"
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

  private

  def py_ver
    `#{Formula["python"].opt_bin}/python3 -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`.strip
  end
end

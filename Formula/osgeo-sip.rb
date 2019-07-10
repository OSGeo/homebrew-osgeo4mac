class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_sip_linked }

  def core_sip_linked
    Formula["sip"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink sip\e[0m or remove with brew \e[32muninstall --ignore-dependencies sip\e[0m\n\n" if core_sip_linked
    s
  end
end


class OsgeoSip < Formula
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/sip/4.19.18/sip-4.19.18.tar.gz"
  sha256 "c0bd863800ed9b15dcad477c4017cdb73fa805c25908b0240564add74d697e1e"

  # revision 1

  head "https://www.riverbankcomputing.com/hg/sip", :using => :hg

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    sha256 "cb8827eb16612c5e8d9d05bf3f2e8cb22c31714ca853e0d3bddc6097258f5ba9" => :mojave
    sha256 "cb8827eb16612c5e8d9d05bf3f2e8cb22c31714ca853e0d3bddc6097258f5ba9" => :high_sierra
    sha256 "5d1d49ba02489e399cfb3e7569584e818819240e2daae1ebe2a7a8abf3ecc0d7" => :sierra
  end

  # keg_only "sip" is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

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

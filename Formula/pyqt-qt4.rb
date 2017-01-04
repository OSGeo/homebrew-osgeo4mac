class PyqtQt4 < Formula
  desc "Python bindings for Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/intro"
  url "https://downloads.sf.net/project/pyqt/PyQt4/PyQt-4.11.4/PyQt-mac-gpl-4.11.4.tar.gz"
  sha256 "f178ba12a814191df8e9f87fb95c11084a0addc827604f1a18a82944225ed918"

  # bottle do
  #   root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
  #   sha256 "" => :mavericks
  # end

  keg_only "Newer Qt5-only version in homebrew-core"

  depends_on :python => :recommended
  depends_on "qt-4"
  depends_on "sip-qt4"

  def install
    if build.without? "python"
      # this is a flaw in Homebrew, where `depends on :python` alone does not work
      odie "Must be built with Python2"
    end

    # On Mavericks we want to target libc++, this requires a non default qt makespec
    if ENV.compiler == :clang && MacOS.version >= :mavericks
      ENV.append "QMAKESPEC", "unsupported/macx-clang-libc++"
    end

    Language::Python.each_python(build) do |python, version|
      ENV["PYTHONPATH"] = "#{HOMEBREW_PREFIX}/lib/qt-4/python#{version}/site-packages"

      args = %W[
        --confirm-license
        --bindir=#{bin}
        --destdir=#{lib}/qt-4/python#{version}/site-packages
        --sipdir=#{share}/sip
      ]

      # We need to run "configure.py" so that pyqtconfig.py is generated, which
      # is needed by QGIS, PyQWT (and many other PyQt interoperable
      # implementations such as the ROS GUI libs). This file is currently needed
      # for generating build files appropriate for the qmake spec that was used
      # to build Qt. The alternatives provided by configure-ng.py is not
      # sufficient to replace pyqtconfig.py yet (see
      # https://github.com/qgis/QGIS/pull/1508). Using configure.py is
      # deprecated and will be removed with SIP v5, so we do the actual compile
      # using the newer configure-ng.py as recommended. In order not to
      # interfere with the build using configure-ng.py, we run configure.py in a
      # temporary directory and only retain the pyqtconfig.py from that.

      require "tmpdir"
      dir = Dir.mktmpdir
      begin
        cp_r(Dir.glob("*"), dir)
        cd dir do
          system python, "configure.py", *args
          inreplace "pyqtconfig.py", Formula["qt-4"].prefix.to_s, Formula["qt-4"].opt_prefix.to_s
          (lib/"qt-4/python#{version}/site-packages/PyQt4").install "pyqtconfig.py"
        end
      ensure
        remove_entry_secure dir
      end

      # On Mavericks we want to target libc++, this requires a non default qt makespec
      if ENV.compiler == :clang && MacOS.version >= :mavericks
        args << "--spec" << "unsupported/macx-clang-libc++"
      end

      system python, "configure-ng.py", *args
      system "make"
      system "make", "install"
      system "make", "clean" # for when building against multiple Pythons
    end

    post_install
  end

  def post_install
    # do symlinking of keg-only here, since `brew doctor` complains about it
    # and user may need to re-link again after following suggestion to unlink
    Language::Python.each_python(build) do |_python, version|
      subpth = "qt-4/python#{version}/site-packages/PyQt4"
      hppth = HOMEBREW_PREFIX/"lib/#{subpth}"
      hppth.mkpath
      cd lib/subpth do
        Dir["*"].each { |f| ln_sf "#{opt_lib.relative_path_from(hppth)}/#{subpth}/#{f}", "#{hppth}/" }
      end
    end
  end

  def caveats
    s = "Phonon support is broken.\n\n"
    s += "Python modules in:\n"
    Language::Python.each_python(build) do |_python, version|
      s += "  #{HOMEBREW_PREFIX}/lib/qt-4/python#{version}/site-packages/PyQt4"
    end
    s
  end

  test do
    Language::Python.each_python(build) do |python, version|
      Pathname("test.py").write <<-EOS.undent
      import site; site.addsitedir("#{HOMEBREW_PREFIX}/lib/qt-4/python#{version}/site-packages")
      from PyQt4 import QtNetwork
      QtNetwork.QNetworkAccessManager().networkAccessible()
      EOS
      system python, "test.py"
    end
  end
end

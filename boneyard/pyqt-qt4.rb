class PyqtQt4 < Formula
  desc "Python bindings for Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/intro"
  url "https://downloads.sf.net/project/pyqt/PyQt4/PyQt-4.11.4/PyQt-mac-gpl-4.11.4.tar.gz"
  sha256 "f178ba12a814191df8e9f87fb95c11084a0addc827604f1a18a82944225ed918"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    rebuild 1
    sha256 "00d6c9ee4e673050ebc4bdf7fbd7f95689981fe7e2186bc8be4f1ab16c07a1bd" => :high_sierra
    sha256 "00d6c9ee4e673050ebc4bdf7fbd7f95689981fe7e2186bc8be4f1ab16c07a1bd" => :sierra
  end

  depends_on "python@2" => :recommended
  depends_on "qt-4"
  depends_on "sip-qt4"

  def install
    if build.without? "python@2"
      # this is a flaw in Homebrew, where `depends on :python` alone does not work
      odie "Must be built with Python2"
    end

    # On Mavericks we want to target libc++, this requires a non default qt makespec
    if ENV.compiler == :clang && MacOS.version >= :mavericks
      ENV.append "QMAKESPEC", "unsupported/macx-clang-libc++"
    end

    ENV.prepend_path "PATH", "#{Formula["sip-qt4"].opt_libexec}/bin"

    Language::Python.each_python(build) do |python, version|
      ENV["PYTHONPATH"] = "#{HOMEBREW_PREFIX}/lib/qt-4/python#{version}/site-packages"

      args = %W[
        --confirm-license
        --bindir=#{bin}
        --destdir=#{lib}/qt-4/python#{version}/site-packages
        --sipdir=#{share}/sip-qt4
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

      oldargs = args + %W[--plugin-destdir=#{lib}/qt-4/plugins]

      require "tmpdir"
      dir = Dir.mktmpdir
      begin
        cp_r(Dir.glob("*"), dir)
        cd dir do
          system python, "configure.py", *oldargs
          qt4 = Formula["qt-4"]
          # can't use qt4.prefix anymore, as it is opt-relative
          inreplace "pyqtconfig.py",
                    qt4.opt_prefix.realpath,
                    qt4.opt_prefix
          inreplace "pyqtconfig.py",
                    "#{HOMEBREW_CELLAR}/#{name}/#{installed_version}",
                    opt_prefix
          (lib/"qt-4/python#{version}/site-packages/PyQt4").install "pyqtconfig.py"
        end
      ensure
        remove_entry_secure dir
      end

      # On Mavericks we want to target libc++, this requires a non default qt makespec
      if ENV.compiler == :clang && MacOS.version >= :mavericks
        args << "--spec" << "unsupported/macx-clang-libc++"
      end

      ngargs = args + %W[
        --sip-incdir=#{Formula["sip-qt4"].opt_libexec}/include
        --designer-plugindir=#{lib}/qt-4/plugins/designer
      ]

      system python, "configure-ng.py", *ngargs
      system "make"
      system "make", "install"
      system "make", "clean" # for when building against multiple Pythons
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
      ENV["PYTHONPATH"] = HOMEBREW_PREFIX/"lib/qt-4/python#{version}/site-packages"
      system "#{bin}/pyuic4", "--version"
      system "#{bin}/pylupdate4", "-version"
      system python, "-c", "import PyQt4"
      %w[
        Qt
        QtCore
        QtDeclarative
        QtDesigner
        QtGui
        QtHelp
        QtMultimedia
        QtNetwork
        QtOpenGL
        QtScript
        QtScriptTools
        QtSql
        QtSvg
        QtTest
        QtWebKit
        QtXml
        QtXmlPatterns
      ].each { |mod| system python, "-c", "import PyQt4.#{mod}" }
    end
  end
end

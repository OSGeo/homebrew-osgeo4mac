class PyqtQt4 < Formula
  desc "Python bindings for Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/intro"
  url "https://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-4.12.3/PyQt4_gpl_mac-4.12.3.tar.gz/download"
  sha256 "293e4be7dd741db72b1265e062ea14332ba5532741314f64eb935d141570305f"

  revision 1

  depends_on "python@2" => :recommended
  depends_on "qt@4"
  depends_on "sip-qt4"
  # depends_on "qt4-webkit" => :recommended

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
      ENV["PYTHONPATH"] = "#{HOMEBREW_PREFIX}/lib/qt4/python#{version}/site-packages"

      args = ["--confirm-license",
              "--bindir=#{bin}",
              "--destdir=#{lib}/qt4/python#{version}/site-packages",
              # "--stubsdir=#{lib}/qt4/python#{version}/site-packages/PyQt4",
              "--sipdir=#{share}/sip-qt4" # PyQt4
              # sip.h could not be found automatically
              # "--sip-incdir=#{Formula["sip-qt4"].opt_libexec}/include",
              # "--qmake=#{Formula["qt@4"].bin}/qmake",
              # Force deployment target to avoid libc++ issues
              # "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
              # "--verbose"
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

      oldargs = args + %W[--plugin-destdir=#{lib}/qt4/plugins]

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
          (lib/"qt4/python#{version}/site-packages/PyQt4").install "pyqtconfig.py"
        end
      ensure
        remove_entry_secure dir
      end

      # On Mavericks we want to target libc++, this requires a non default qt makespec
      if ENV.compiler == :clang && MacOS.version >= :mavericks
        args << "--spec" << "unsupported/macx-clang-libc++"
      end

      # When building PyQt4 for Python >= 3.5, it tries to build and install
      # type checking stubs outside its sandbox. This commit fixes this by
      # disabling the stubs.
      # This only affects Python >= 3.5, and those builds currently fail, so no
      # version bump or bottle rebuild is needed.
      args << "--no-stubs"

      ngargs = args + %W[
        --sip-incdir=#{Formula["sip-qt4"].opt_libexec}/include
        --designer-plugindir=#{lib}/qt4/plugins/designer
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
      s += "  #{HOMEBREW_PREFIX}/lib/qt4/python#{version}/site-packages/PyQt4"
    end
    s
  end

  test do
    # it is temporarily disabled
    # Language::Python.each_python(build) do |python, version|
    #   ENV["PYTHONPATH"] = HOMEBREW_PREFIX/"lib/qt4/python#{version}/site-packages"
    #   system "#{bin}/pyuic4", "--version"
    #   system "#{bin}/pylupdate4", "-version"
    #   system python, "-c", "import PyQt4"
    #   %w[
    #     Qt
    #     QtCore
    #     QtDeclarative
    #     QtDesigner
    #     QtGui
    #     QtHelp
    #     QtMultimedia
    #     QtNetwork
    #     QtOpenGL
    #     QtScript
    #     QtScriptTools
    #     QtSql
    #     QtSvg
    #     QtTest
    #     QtWebKit
    #     QtXml
    #     QtXmlPatterns
    #   ].each { |mod| system python, "-c", "import PyQt4.#{mod}" }
    # end
  end
end

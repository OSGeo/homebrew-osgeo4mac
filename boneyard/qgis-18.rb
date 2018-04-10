require 'formula'

class PyQtImportable < Requirement
  fatal true
  satisfy { quiet_system 'python', '-c', '"from PyQt4 import QtCore"' }

  def message
    <<~EOS
      Python could not import the PyQt4 module. This will cause the QGIS build to fail.
      The most common reason for this failure is that the PYTHONPATH needs to be adjusted.
      The pyqt caveats explain this adjustment and may be reviewed using:

          brew info pyqt
    EOS
  end
end

class Qgis18 < Formula
  homepage 'http://www.qgis.org'
  url 'http://qgis.org/downloads/qgis-1.8.0.tar.bz2'
  sha1 '99c0d716acbe0dd70ad0774242d01e9251c5a130'

  depends_on 'cmake' => :build
  depends_on :python
  depends_on PyQtImportable

  depends_on 'gsl'
  depends_on 'pyqt'
  depends_on 'qwt60'
  depends_on 'expat'
  depends_on 'gdal-19'
  depends_on 'proj'
  depends_on 'spatialindex'
  depends_on 'bison'
  depends_on 'grass' => :optional
  depends_on 'gettext' if build.with? 'grass'
  depends_on 'postgis' => :optional

  def install
    cxxstdlib_check :skip
    # Set bundling level back to 0 (the default in all versions prior to 1.8.0)
    # so that no time and energy is wasted copying the Qt frameworks into QGIS.
    args = std_cmake_args.concat %W[
      -DQWT_INCLUDE_DIR=#{Formula['qwt60'].opt_prefix}/lib/qwt.framework/Headers/
      -DQWT_LIBRARY=#{Formula['qwt60'].opt_prefix}/lib/qwt.framework/qwt
      -DBISON_EXECUTABLE=#{Formula['bison'].opt_prefix}/bin/bison
      -DENABLE_TESTS=NO
      -DQGIS_MACAPP_BUNDLE=0
      -DQGIS_MACAPP_DEV_PREFIX='#{prefix}/Frameworks'
      -DQGIS_MACAPP_INSTALL_DEV=YES
      -DPYTHON_INCLUDE_DIR='#{python.incdir}'
      -DPYTHON_LIBRARY='#{python.libdir}/lib#{python.xy}.dylib'
    ]

    grass = Formula['grass']
    args << "-DGRASS_PREFIX='#{grass.opt_prefix}/grass-#{grass.version}'" if build.with? 'grass'

    # So that `libintl.h` can be found
    ENV.append 'CXXFLAGS', "-I'#{Formula['gettext'].opt_prefix}/include'" if build.with? 'grass'

    # Avoid ld: framework not found QtSql (https://github.com/Homebrew/homebrew-science/issues/23)
    ENV.append 'CXXFLAGS', "-F#{Formula['qt'].opt_prefix}/lib"

    Dir.mkdir 'build'
    python do
      Dir.chdir 'build' do
        system 'cmake', '..', *args
        system 'make install'
      end

      py_lib = lib/"#{python.xy}/site-packages"
      qgis_modules = prefix + 'QGIS.app/Contents/Resources/python/qgis'
      py_lib.mkpath
      ln_s qgis_modules, py_lib + 'qgis'

      # Create script to launch QGIS app
      (bin + 'qgis').write <<~EOS
        #!/bin/sh
        # Ensure Python modules can be found when QGIS is running.
        env PATH='#{HOMEBREW_PREFIX}/bin':$PATH PYTHONPATH='#{HOMEBREW_PREFIX}/lib/#{python.xy}/site-packages':$PYTHONPATH\\
          open #{prefix}/QGIS.app
      EOS
    end
  end

  def caveats
    s = <<~EOS
      QGIS has been built as an application bundle. To make it easily available, a
      wrapper script has been written that launches the app with environment
      variables set so that Python modules will be functional:

        qgis

      You may also symlink QGIS.app into ~/Applications:
        brew linkapps
        mkdir -p #{ENV['HOME']}/.MacOSX
        defaults write #{ENV['HOME']}/.MacOSX/environment.plist PYTHONPATH -string "#{HOMEBREW_PREFIX}/lib/#{python.xy}/site-packages"

      You will need to log out and log in again to make environment.plist effective.

    EOS
    #s += python.standard_caveats if python
    s
  end
end

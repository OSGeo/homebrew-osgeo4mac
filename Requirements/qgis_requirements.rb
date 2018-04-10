class UnlinkedQGIS2 < Requirement
  fatal true

  def unlinked_qgis
    found = `readlink ${HOMEBREW_PREFIX}/bin/qgis | egrep -o '/qgis[^/]*/' | tr -d '/' | tr -d '\n'`
    return found.empty?, found
  end

  satisfy(:build_env => false) { unlinked_qgis[0] }

  def message
    qgis_f = unlinked_qgis[1]
    <<~EOS

      Another QGIS formula is linked: #{qgis_f}

      Do `brew unlink #{qgis_f}` then try installing this formula again.
      You can leave #{qgis_f} unlinked and installed as keg-only;
      however, launching it as keg-only may cause issues or crashes, since it
      will be now be referencing Python modules of any newly linked QGIS.

      Issue can be overcome by setting PYTHONPATH, e.g. in the app's Options.

      Or, keep all QGIS formulae unlinked if you wish to run multiple installs.

    EOS
  end
end

class SipBinary < Requirement
  fatal true
  #noinspection RubyResolve
#  default_formula 'sip'
  satisfy(:build_env => false) { which 'sip' }

  def message
    <<~EOS
      The `sip` binary is missing. It is needed to generate the Python bindings for QGIS.
      Ensure `sip` formula is installed and linked.

    EOS
  end
end

class PyQtConfig < Requirement
  fatal true
  #noinspection RubyResolve
#  default_formula 'pyqt'
  # pyqtconfig is not created with PyQt4 >= 4.10.x when using configure-ng.
  # Homebrew's `pyqt` formula corrects this. Remains an issue until QGIS project
  # adjusts FindPyQt.py in CMake setup to work with configure-ng.
  satisfy(:build_env => false) { quiet_system 'python', '-c', 'from PyQt4 import pyqtconfig' }

  def message
    <<~EOS
      Python could not import the PyQt4.pyqtconfig module. This will cause the QGIS build to fail.
      The most common reason for this failure is that the PYTHONPATH needs to be adjusted.
      The `pyqt` caveats explain this adjustment and may be reviewed using:

          brew info pyqt

      Ensure `pyqt` formula is installed and linked, and that it includes the `pyqtconfig` module.

    EOS
  end
end

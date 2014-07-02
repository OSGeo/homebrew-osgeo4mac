class UnlinkedQGIS < Requirement
  fatal true

  def qgis_formula_name
    # meant to be overridden by each formula using requirement
    ""
  end

  def qgis_list
    %W[
      homebrew/science/qgis
      osgeo/osgeo4mac/qgis-18
      osgeo/osgeo4mac/qgis-20
      osgeo/osgeo4mac/qgis-22
      osgeo/osgeo4mac/qgis-24
    ]
  end

  def no_linked_qgis
    qgis_list.each do |f|
      next if f == qgis_formula_name
      next unless Formula.path(f).exist?
      begin
        return false, f if Formula[f].linked_keg.exist?
      rescue TapFormulaUnavailableError
        next
      rescue FormulaUnavailableError
        next
      end
    end
    return true, ""
  end

  satisfy(:build_env => false) { no_linked_qgis[0] }

  def message
    qgis_f = no_linked_qgis[1]
    <<-EOS.undent

      Another QGIS formula is linked: #{qgis_f}.
      Do `brew unlink #{qgis_f}` then try installing this formula again.
      You can leave #{qgis_f} unlinked and installed as keg-only;
      however, launching it as keg-only may cause issues or crashes, since it
      will be now be referencing Python modules of the newly linked QGIS.

      Issue can be overcome by setting PYTHONPATH, e.g. in the app's Options.

    EOS
  end
end

class SipBinary < Requirement
  fatal true
  #noinspection RubyResolve
  default_formula 'sip'
  satisfy(:build_env => false) { which 'sip' }

  def message
    <<-EOS.undent
      The `sip` binary is missing. It is needed to generate the Python bindings for QGIS.
      Ensure `sip` formula is installed and linked.

    EOS
  end
end

class PyQtConfig < Requirement
  fatal true
  #noinspection RubyResolve
  default_formula 'pyqt'
  # pyqtconfig is not created with PyQt4 >= 4.10.x when using configure-ng.
  # Homebrew's `pyqt` formula corrects this. Remains an issue until QGIS project
  # adjusts FindPyQt.py in CMake setup to work with configure-ng.
  satisfy(:build_env => false) { quiet_system 'python', '-c', 'from PyQt4 import pyqtconfig' }

  def message
    <<-EOS.undent
      Python could not import the PyQt4.pyqtconfig module. This will cause the QGIS build to fail.
      The most common reason for this failure is that the PYTHONPATH needs to be adjusted.
      The `pyqt` caveats explain this adjustment and may be reviewed using:

          brew info pyqt

      Ensure `pyqt` formula is installed and linked, and that it includes the `pyqtconfig` module.

    EOS
  end
end

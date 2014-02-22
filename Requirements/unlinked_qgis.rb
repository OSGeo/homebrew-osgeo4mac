class UnlinkedQGIS < Requirement
  fatal true

  def qgis_list
    # default: Homebrew/science's
    %W[qgis]
  end

  def no_linked_qgis
    qgis_list.each {|f| return false, f if Formula.factory(f).linked_keg.exist?}
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

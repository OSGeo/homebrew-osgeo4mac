class UnlinkedGRASS7 < Requirement
  fatal true

  def unlinked_grass
    found = `readlink ${HOMEBREW_PREFIX}/bin/grass7* | egrep -o '/grass[^/]*/' | tr -d '/' | tr -d '\n'`
    return found.empty?, found
  end

  satisfy(:build_env => false) { unlinked_grass[0] }

  def message
    grass_f = unlinked_grass[1]
    <<~EOS

      Another GRASS 7.x formula is linked: #{grass_f}

      Do `brew unlink #{grass_f}` then try installing this formula again.
      You can leave #{grass_f} unlinked and installed as keg-only;
      however, launching it as keg-only may cause issues or crashes, since it
      will be now be referencing Python modules of any newly linked GRASS.

      Keep all GRASS formulae unlinked if you wish to run multiple installs.

    EOS
  end
end

class UnlinkedGRASS6 < Requirement
  fatal true

  def unlinked_grass
    found = `readlink ${HOMEBREW_PREFIX}/bin/grass6* | egrep -o '/grass[^/]*/' | tr -d '/' | tr -d '\n'`
    return found.empty?, found
  end

  satisfy(:build_env => false) { unlinked_grass[0] }

  def message
    grass_f = unlinked_grass[1]
    <<~EOS

      Another GRASS 6.x formula is linked: #{grass_f}

      Do `brew unlink #{grass_f}` then try installing this formula again.
      You can leave #{grass_f} unlinked and installed as keg-only;
      however, launching it as keg-only may cause issues or crashes, since it
      will be now be referencing Python modules of any newly linked GRASS.

      Keep all GRASS formulae unlinked if you wish to run multiple installs.

    EOS
  end
end

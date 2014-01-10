Homebrew-osgeo4mac
==================

Mac [homebrew][] formula tap for maintaining a STABLE work environment for the
OSGeo.org geospatial toolset. This includes formulae that may not be specifically
for an OSGeo project, but do extend the toolset's functionality.

These formulae *may* provide multiple versions of existing packages in the
[main homebrew taps][taps]. Such formulae are to temporarily ensure stability for
the toolset, or to add extra options not found in the main taps. After such
formulae are field-tested with the OSGeo toolset, pull requests will be
created at the relevant upstream taps (when appropriate); then, if the requests
are committed, the formulae removed from this tap.

How do I install these formulae?
--------------------------------
Just `brew tap dakcarto/osgeo4mac` and then `brew install <formula>`.

Warnings such as the following can be **ignored**:

  * _Warning_: Could not tap **dakcarto/osgeo4mac/gdal** over **Homebrew/homebrew/gdal**

Those warnings just indicate formulae in this tap that shadow formulae in the
main Homebrew tap, and will not overwrite them. If the formula conflicts with
one from the main Homebrew tap or another tap you can install directly with:

```
brew install dakcarto/osgeo4mac/<formula>
```

**Important**: use the above method to install shadow formula(e) from this tap,
if desired, _prior_ to installing formula that depend upon them. Since the
conflicting formulae names are the same, formulae auto-installed via the
`depends_on` statement will always default to the conflicting tap, not this one,
i.e. conflicting formulae in this tap will _not_ be used when auto-installing.

You can also install via URL:

```
brew install https://raw.github.com/dakcarto/homebrew-osgeo4mac/master/<formula>.rb
```

How do I use the Brewfiles?
--------------------------------

See: [Using OSGeo4Mac Brewfiles][brewfiles] in the wiki.

Example installation session
-----------------------------

The following steps should result in a usable QGIS installation (QGIS 2.0 in this case) on a clean system:

```bash
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
brew doctor
brew tap dakcarto/homebrew-osgeo4mac
brew tap homebrew/science
brew install dakcarto/osgeo4mac/qgis-20
brew linkapps
```

You should now see QGIS 2 in Applications folder.


Docs
----
`brew help`, `man brew`, or the Homebrew [wiki][].

[homebrew]:http://brew.sh
[taps]:https://github.com/Homebrew/homebrew-versions
[wiki]:http://wiki.github.com/mxcl/homebrew
[brewfiles]:https://github.com/dakcarto/homebrew-osgeo4mac/wiki/Using-OSGeo4Mac-Brewfiles

Homebrew-osgeo4mac
==================

_NOTE_: On March 28, 2014, this repository was moved from dakcarto's github 
account to OSGeo's.

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
Just `brew tap osgeo/osgeo4mac` and then `brew install <formula>`.

If you have _previously_ tapped the **dakcarto/osgeo4mac** repository do:

```
brew untap dakcarto/osgeo4mac
brew tap osgeo/osgeo4mac
brew tap --repair
```

Warnings such as the following can be **ignored**:

  * _Warning_: Could not tap **osgeo/osgeo4mac/gdal** over **Homebrew/homebrew/gdal**

Those warnings just indicate formulae in this tap that shadow formulae in the
main Homebrew tap, and will not overwrite them. If the formula conflicts with
one from the main Homebrew tap or another tap you can install directly with:

```
brew install osgeo/osgeo4mac/<formula>
```

**Important**: use the above method to install shadow formula(e) from this tap,
if desired, _prior_ to installing formula that depend upon them. Since the
conflicting formulae names are the same, formulae auto-installed via the
`depends_on` statement will always default to the conflicting tap, not this one,
i.e. conflicting formulae in this tap will _not_ be used when auto-installing.

You can also install via URL:

```
brew install https://raw.githubusercontent.com/OSGeo/homebrew-osgeo4mac/master/Formula/<formula>.rb
```

How do I use the Brewfiles?
--------------------------------

If you have used `brewfiles` from this tap before, take note that the command is
no longer in Homebrew. As such, the previously available `brewfiles` have been
removed from this tap.

Docs
----
`brew help`, `man brew`, or the Homebrew [documentation][].

[homebrew]:http://brew.sh
[taps]:https://github.com/Homebrew/homebrew-versions
[documentation]:https://github.com/Homebrew/brew/tree/master/docs#readme

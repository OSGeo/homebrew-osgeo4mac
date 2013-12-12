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

If the formula conflicts with one from mxcl/master or another tap:

```
brew install dakcarto/osgeo4mac/<formula>
```

You can also install via URL:

```
brew install https://raw.github.com/dakcarto/homebrew-osgeo4mac/master/<formula>.rb
```

How do I use the Brewfiles?
--------------------------------

See: [Using OSGeo4Mac Brewfiles][brewfiles] in the wiki.

Docs
----
`brew help`, `man brew`, or the Homebrew [wiki][].

[homebrew]:http://brew.sh
[taps]:https://github.com/Homebrew/homebrew-versions
[wiki]:http://wiki.github.com/mxcl/homebrew
[brewfiles]:https://github.com/dakcarto/homebrew-osgeo4mac/wiki/Using-OSGeo4Mac-Brewfiles

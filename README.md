![docs/assets/images/osgeo-logo-brew-rgb.png](docs/assets/images/osgeo-logo-brew-rgb.png)



# Homebrew-osgeo4mac

**Build Status**: [![CircleCI](https://circleci.com/gh/OSGeo/homebrew-osgeo4mac.svg?style=svg)](https://circleci.com/gh/OSGeo/homebrew-osgeo4mac)

This is the [homebrew's][homebrew] tap for the **stable** versions of the [OSGeo][osgeo] geospatial toolset. Right now our main focus is to provide and up-to-date [QGIS][qgis] formulae easy to install to the end user. The tap includes formulae that may not be specifically
from an OSGeo project, but do extend the toolset's functionality

## How do I install these formulae?

Just `brew tap osgeo/osgeo4mac` and then `brew install <formula>`. Easy, isn't it? 

You can also install via URL:

```shell
$ brew install https://raw.githubusercontent.com/OSGeo/homebrew-osgeo4mac/master/Formula/<formula>.rb
```

## Renaming formulae

Currently we are renaming formulae. 

We recommend to run `brew migrate <old-formula-name>` to move your install in your cellar from the old name to the new name and unlink and link to the new keg if necessary. 

You can also just uninstall the old formula and reinstall the formula with the new name with: 

```shell
$ brew uninstall --ignore-depencencies <old-formula-name> 
$ brew install <new-formula-name> 
```

## Docs

Run `brew help`, `man brew`, check the [Homebrew documentation](https://github.com/Homebrew/brew/tree/master/docs#readme) or the [tap documentation][osgeo4mac-docs].

## Help wanted :sos:

If you are interested in collaborating more close with us in the repo maintenance, formula development or just have an idea to take this tap further, please tell us. Any help, idea or suggestion is really welcomed because we want this top to be useful to people that are interested into use QGIS and the rest of the OSGeo toolset on macOS. 

In addition to the normal communication over the issue tracker in this repo we also have a have a slack  workplace were we discuss repo matters in a more dynamic way. If you want to join us, because you are interested into collaborate in the discussion please tell us. 


[homebrew]:http://brew.sh
[taps]:https://github.com/Homebrew/homebrew-versions
[documentation]:https://github.com/Homebrew/brew/tree/master/docs#readme
[osgeo]: https://www.osgeo.org
[qgis]: https://www.qgis.org
[homebrew-core]: https://github.com/Homebrew/homebrew-core
[taps-docs]: https://docs.brew.sh/Taps
[osgeo4mac-docs]: https://osgeo.github.io/homebrew-osgeo4mac/

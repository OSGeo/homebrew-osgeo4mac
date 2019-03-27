---
layout: default
title: Installing QGIS 3
nav_order: 1
---

# Installing QGIS 3

To install the last version of QGIS 3 you just have to run in your terminal `brew install qgis`. Running this command in your terminal you download and install a precompiled [bottle](https://docs.brew.sh/Bottles) of QGIS 3 build with most of the available options. Check below the options with the bottle is build.

- `--with-3d`: Build with 3D Map View panel
- `--with-gpsbabel`: Build with GPSBabel. Read, write and manipulate GPS waypoints in a variety of formats
- `--with-grass`: Build with GRASS 7 integration plugin and Processing plugin support (or install grass-7x first)
- `--with-lastools`: Build with LAStools, efficient tools for LiDAR processing. Contains LASlib, a C++ programming API for reading / writing LIDAR data stored in standard LAS format.
- `--with-orfeo`: Build extra Orfeo Toolbox for Processing plugin
- `--with-qspatialite`: Build QSpatialite Qt database driver
- `--with-r`: Build extra R for Processing plugin
- `--with-saga`: Build extra Saga GIS (LTS) for Processing plugin
- `--with-server`: Build with QGIS Server (qgis_mapserv.fcgi)
- `--with-taudem`: Build with TauDEM, Terrain Analysis Using Digital Elevation Models for hydrology
- `--with-whitebox`: Build with Whitebox Tools, an advanced geospatial data analysis platform

The options `--with-mssql`
and `--with-oracle`
aren't implemented at the moment because the user needs to accept licenses before building with them and it would complicate too much the building process of the bottle. `--with-postgresql10`, `--with-api-docs` and `--with-isolation` are left to the end user consideration because we consider seldom used options or features.

Anyhow, if you are interested in any of those options to be included or dropped from the default build of QGIS 3, please let us know **why** opening an [issue](https://github.com/OSGeo/homebrew-osgeo4mac/issues).

## qgis-res

We are using this formula to speed-up the QGIS's installation and update processes and, in consequence, is one of the main dependencies of QGIS. This way you can have more Python modules available to use with QGIS and since this modules are seldom updated it saves installation and updating time.

When `qgis-res` formula is installed or updated, and since QGIS is build now by default `--with-r`, it will install R from Homebrew-core.

## R from core vs R from other taps

If you have installed R from other tap —from [sethrfore/r-srf](https://github.com/sethrfore/homebrew-r-srf) for instance— instead of R from core the install will ask you to uninstall it to continue. You have two options.

1. You can just uninstall your version of R and continue with QGIS 3 install. When the QGIS 3 install finish you just rever. You uninstall R from core and install again your preferred version.

2. You just can rename the keg in your cellar before you start the install or update of QGIS 3 and when it finish you rever your changes and relink the formula. Something like the bellow code will do the trick.

   ```shell
   # Before you install or update QGIS
   $ brew unlink R
   $ mv /usr/local/cellar/r /usr/local/cellar/r-backup

   # After the QGIS install finish
   $ rm -r /usr/local/cellar/r
   $ mv /usr/local/cellar/r-backup /usr/local/cellar/r
   $ brew link r
   ```


Please note that you have to do this even if you have your preferred tap pinned, since the pinned tap formulae only take preference when the formula is called by you, not when it's installed as dependency.

## Recommendations, issues, caveats and headaches :face_with_head_bandage:

You can come across the following problems.

### Formulae renaming & tap pinning

We are [pondering](https://github.com/OSGeo/homebrew-osgeo4mac/issues/769) renaming some formulae to take the same name of their counterpart on core. The main rationale behind this is to avoid to have two versions or kegs of the same software in your machine. However, this could bring problems in, since Homebrew take precedence other core formulae when installing dependencies, even when the tap is pin with `brew tap-pin <tap-name>`. Formulae from pinned taps only take precedence when you install those formulae from terminal.

Anyhow we recommend you to pin this tap, while we try to figure out this conundrum. We encourage you to give your opinion.

```shell
$ brew tap-pin osgeo/osgeo4mac
```

### The maximum number of open file descriptors

Since the build of QGIS 3 has a lot of dependencies you perhaps could run into an error related to the lack of resources allocated to the shell. Luckily you can change that using the command [`ulimit`](https://ss64.com/osx/ulimit.html). Check if `ulimit -n` is bigger than 1024 and it it's not set it `ulimit -n 1024` . It's up to you if you want to reset to you previous limit after you build or install QGIS.

### Post-install could not finish

It seems that there was a small change in OTB, I will correct it in the next release of QGIS.
You can solve this by temporarily renaming `OtbUtils` file.

```
$ mv /usr/local/Cellar/qgis/3.6.0_4/QGIS.app/Contents/Resources/python/plugins/otb/OTBUtils.py /usr/local/Cellar/qgis/3.6.0_4/QGIS.app/Contents/Resources/python/plugins/otb/OtbUtils.py
```

### Fixing dependencies

Sometimes errors installing or building are related to incorrect installed or linked dependencies. We recommend you to do the following and try to build or install again:

Remove the cache

```shell
$ rm -rf $(brew --cache)
```

and the temporary files in `/tmp` related to the build if any.

A failed installation perhaps has build `qgis_customwidgets.py` you need to delete it.

```shell
$ rm /usr/local/lib/python3.7/site-packages/PyQt5/uic/widget-plugins/qgis_customwidgets.py
```

Reinstall a relink some dependencies:

```shell
$ brew reinstall ninja gsl python qt sip-qt5 pyqt-qt5 pyqt5-webkit qscintilla2-qt5 six bison flex pkg-config
$ brew link --overwrite pyqt-qt5
$ brew unlink gettext python && brew link --force gettext python
```

## Mind the CI

**Build status**: [![CircleCI](https://circleci.com/gh/OSGeo/homebrew-osgeo4mac.svg?style=svg)](https://circleci.com/gh/OSGeo/homebrew-osgeo4mac)

You have to keep in mind that if the bottle is able to build in our building server —aka CI— and it isn't able to to build or install in your machine, the problem is probably related to your local environment. We can help, but we don't promise anything. You can check the state of the build on the readme file, but you have to keep in mind, also, that some times the state is marked as failed by an error unrelated to the build, but to the deployment. Usually it can't upload the bottles to the bottle server and we upload them manually.

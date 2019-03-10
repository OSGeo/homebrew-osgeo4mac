---
layout: default
title: Troubleshooting
nav_order: 3
---

# Troubleshooting

* Run `brew update` twice.

* Run `brew doctor` and fix all the warnings (**outdated Xcode/CLT and unbrewed dylibs are very likely to cause problems**).

* Check that **Command Line Tools for Xcode (CLT)** and **Xcode** are up to date.

* If commands fail with permissions errors, check the permissions of `/usr/local`'s subdirectories. If you’re unsure what to do, you can run: 

  ```shell
  $ cd /usr/local 
  $ sudo chown -R $(whoami) bin etc include lib sbin share var opt Cellar Caskroom Frameworks
  ```

## QGIS 3 Specific Problems

### The maximum number of open file descriptors

Since the build of QGIS 3 has a lot of dependencies you perhaps could run into an error related to the lack of resources allocated to the shell. Luckily you can change that using the command [`ulimit`](https://ss64.com/osx/ulimit.html). Check if `ulimit -n` is bigger than 1024 and it it's not set it `ulimit -n 1024` . It's up to you if you want to reset to you previous limit after you build or install QGIS. 

### Post-install could not finish

It seems that there was a small change in OTB, I will correct it in the next release of QGIS.
You can solve this by temporarily renaming `OtbUtils` file. 

```shell
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


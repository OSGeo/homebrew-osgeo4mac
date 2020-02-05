---
layout: default
title: Reporting issues
nav_order: 2
---

# Reporting Issues

**Run `brew update` twice and `brew doctor` *before* creating an issue!**

This document will help you check for common issues and make sure your issue has not already been reported.

## Check for common issues

Follow these steps to fix common problems:

* Run `brew update` twice.

* Run `brew doctor` and fix all the warnings (**outdated Xcode/CLT and unbrewed dylibs are very likely to cause problems**).

* Check that **Command Line Tools for Xcode (CLT)** and **Xcode** are up to date.

* If commands fail with permissions errors, check the permissions of `/usr/local`'s subdirectories. If you’re unsure what to do, you can run: 

  ```shell
  $ cd /usr/local 
  $ sudo chown -R $(whoami) bin etc include lib sbin share var opt Cellar Caskroom Frameworks
  ```

* Read through the [[Troubleshooting]].

## Check to see if the issue has been reported

* Search the [issue tracker](https://github.com/OSGeo/homebrew-osgeo4mac/issues) to see if someone else has already reported the same issue.
* Make sure you issue is specific to this tap and it's not part of other formula or dependency part of [core](https://github.com/Homebrew/homebrew-core/issues), [cask](https://github.com/Homebrew/homebrew-cask/issues) or other tap. 

## Create an issue

If your problem hasn't been solved or reported, then create an issue:

1. Upload debugging information to a [Gist](https://gist.github.com):
  * If you had a formula-related problem: run `brew gist-logs <formula>` (where `<formula>` is the name of the formula).
  * If you encountered a non-formula problem: upload the output of `brew config` and `brew doctor` to a new [Gist](https://gist.github.com).

2. [Create a new issue](https://github.com/Homebrew/homebrew-core/issues/new/choose).
  * Give your issue a descriptive title which includes the formula name (if applicable) and the version of macOS you are using. For example, if a formula fails to build, title your issue "\<formula> failed to build on \<10.x>", where "\<formula>" is the name of the formula that failed to build, and "\<10.x>" is the version of macOS you are using.
  * Include the URL output by `brew gist-logs <formula>` (if applicable). Please check [how to get the building logs](#how-to-get-the-building-logs) for more info. 
  * Include links to any additional Gists you may have created (such as for the output of `brew config`,  `brew doctor` or the output of your terminal). 
  * Please make, one problem one error. Don't mix up things because it isn't going to have any sense. 
  * Don't dumb in the description of the issue a incredible amount of code, use a [Gist](https://gist.github.com) instead.   
  **What is an incredible amount of code?** Well, you'll know it when you'll see it. Scrolling down endlessly to be able some meaningful text doesn't usually have any sense. 
  * Try to be as descriptive as possible, without being redundant, in other words **be concise**. This is not a chat or a forum, but informal style is encourage. Please follow the [Code of Conduct.](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/CODE_OF_CONDUCT.md#specific-guidelines). 

## How to get the building logs?

One of the things you can provide us with is the building logs. You have to take into account that when doing parallel-job (multi-core) compilations, any final error is generally not the actual error that caused the build to fail. When posting log output from a multi-core build, that last error notice is _usually_ preceded by completely unrelated output from other parallel jobs that are finishing up first, with the actual in-line error much further up in the log. This is the case for the ubiquitous Make tool, though sequential log output may be created by other compilation tools, e.g. Ninja.

In other, and more simple, words, if you just post the output of your terminal chances are that the actual and real problem isn't showing there, so you have to search for the building logs. 

Homebrew comes already with a tool that allow you to fetch and upload those logs in just one command `brew gist-logs`. You just have to run `brew gist-logs qgis` and the tool will upload those logs to the github gist platform. If you add the flag `-n` it will even open an issue in our repo with the gist linked. You can check other options running in your terminal `brew gist-logs -h`. 

Unfortunately, the `brew gist-logs` command can truncate large log files before uploading, indicated by a `[...snip...]` in the uploaded log. In which case, the actual in-line error _may_ have been removed. In that case you have to do the job manually yourself. You have to search in `~/Library/Logs/Homebrew/<formula>/<log>` or `~/Library/Logs/Homebrew/<formula>/0#.make` (for Make builds) and search in those logs for **`error:`** or maybe **`fatal error:`** (note case and colon).

When reporting issues, post the actual error and the matching compilation command(s) preceding it (again, may be further up in the log), or update the github gist page of the `brew gist-logs` output with the full log file that was truncated (gists are micro code repos, so you can update individual files).

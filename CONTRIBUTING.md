# Contributing to Homebrew-osgeo4mac

First time contributing to Homebrew-osgeo4mac? Read our [Code of Conduct](CODE_OF_CONDUCT.md).

## How...

### To report a bug

* Run `brew update` (twice). 
* Run and read `brew doctor`. 
* Read [the Hombrew Troubleshooting Checklist](https://docs.brew.sh/Troubleshooting). 
* Read the how to [report issues](https://github.com/OSGeo/homebrew-osgeo4mac/wiki/Reporting-issues) and the [troubleshooting](https://github.com/OSGeo/homebrew-osgeo4mac/wiki/Troubleshooting).  
* [Search](https://github.com/OSGeo/homebrew-osgeo4mac/issues) for same issue or similar to yours in the repo. 
* If there is no similar issue, open or closed, [open an issue](https://github.com/OSGeo/homebrew-osgeo4mac/issues/new/choose) on the repo.

### To submit a version upgrade for the `foo` formula

* Check if the same upgrade has been already submitted by [searching the open pull requests for `foo`](https://github.com/OSGeo/Homebrew-osgeo4mac/pulls?utf8=✓&q=is%3Apr+is%3Aopen+foo).
* `brew bump-formula-pr --strict foo` with `--url=...` and `--sha256=...` or `--tag=...` and `--revision=...` arguments.

### To add a new formula for `foo` version `2.3.4` from `$URL`

* Read [the Formula Cookbook](https://docs.brew.sh/Formula-Cookbook) or: `brew create $URL` and make edits
* `brew install --build-from-source foo`
* `brew audit --new-formula foo`
* `git commit` with message formatted `foo 2.3.4 (new formula)`
* [Open a pull request](https://docs.brew.sh/How-To-Open-a-Homebrew-Pull-Request) and fix any failing tests

### To contribute with a fix to the `foo` formula

#### You already know about Git

If you are already well versed in the use of `git`, then you can find the local
copy of the `homebrew-core` repository in this directory
(`$(brew --repository homebrew/core)`), modify the formula there
leaving the section `bottle do ... end` unchanged, and prepare a pull request
as you usually do.  Before submitting your pull request, be sure to test it
with these commands:

```shell
$ brew uninstall --force foo
$ brew install --build-from-source foo
$ brew test foo
$ brew audit --strict foo
```

After testing, if you think it is needed to force the corresponding bottles to be
rebuilt and redistributed, add a line of the form `revision 1` to the formula,
or add 1 to the revision number already present.

#### You don't know about Git

If you are not already well versed in the use of `git`, then you may learn
a little bit about it from the [Homebrew's documentation](https://docs.brew.sh/How-To-Open-a-Homebrew-Pull-Request) and then proceed as
follows:

* Run `brew edit foo` and make edits.
* Leave the section `bottle do ... end` unchanged.
* Test your changes using the commands listed above.
* Run `git commit` with message formatted `foo <insert new version number>` or `foo: <insert details>`. 
* Open a pull request as described in the introduction linked to above, wait for the automated test results, and fix any failing tests. 

## Help wanted :sos:

If you are interested in collaborating more close with us in the repo maintenance, formula development or just have an idea to take this tap further, please tell us. Any help, idea or suggestion is really welcomed because we want this top to be useful to people that are interested into use QGIS and the rest of the OSGeo toolset on macOS. 

In addition to the normal communication over the issue tracker in this repo we also have a have a ![](https://i.imgur.com/tZfrqQG.png)[slack workplace](https://homebrew-osgeo4mac.slack.com/) were we discuss repo matters in a more dynamic way. If you want to join us, because you are interested into collaborate in the discussion please tell us. 

**Thanks!** :pray:

\****Note****: this contributing page has been heavily based on the Homebrew core's [contributing page](https://github.com/Homebrew/brew/blob/master/CONTRIBUTING.md).*
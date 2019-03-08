---
layout: default
title: Reporting errors
nav_order: 2
---

# Reporting errors

Whether you are building or not, you can come across an error and the best you can do it report it in the [issues](https://github.com/OSGeo/homebrew-osgeo4mac/issues) section.

We encourage you to be as descriptive as possible and follow the following rules of thumb:

- Please make, one problem one error. Don't mix up things because it isn't going to have any sense.
- Don't dumb in the description of the issue a incredible amount of code, use a gist instead. What is an incredible amount of code. Well, you'll know it when you'll see it. Scrolling down endlessly to be able some meaningful text doesn't usually have any sense.
- Try to be as descriptive as possible, without being redundan, in other words be concise (This is not a chat or a forum, but don't be an asshole. Informal style is encourage). The best way is to report the steps that lead you the the error, terminal commands include. Meaningful outputs too.

## How to get the building logs?

One of the things you can provide us with is the building logs. You have to take into account that when doing parallel-job (multi-core) compilations, any final error is generally not the actual error that caused the build to fail. When posting log output from a multi-core build, that last error notice is _usually_ preceded by completely unrelated output from other parallel jobs that are finishing up first, with the actual in-line error much further up in the log. This is the case for the ubiquitous Make tool, though sequential log output may be created by other compilation tools, e.g. Ninja.

In other, and more simple, words, if you just post the output of your terminal chances are that the actual and real problem isn't showing there, so you have to search for the building logs.

Homebrew comes already with a tool that allow you to fetch and upload those logs in just one command `brew gist-logs`. You just have to run `brew gist-logs qgis` and the tool will upload those logs to the github gist platform. If you add the flag `-n` it will even open an issue in our repo with the gist linked. You can check other options running in your terminal `brew gist-logs -h`.

Unfortunately, the `brew gist-logs` command can truncate large log files before uploading, indicated by a `[...snip...]` in the uploaded log. In which case, the actual in-line error _may_ have been removed. In that case you have to do the job manually yourself. You have to search in `~/Library/Logs/Homebrew/<formula>/<log>` or `~/Library/Logs/Homebrew/<formula>/0#.make` (for Make builds) and search in those logs for **`error:`** or maybe **`fatal error:`** (note case and colon).

When reporting issues, post the actual error and the matching compilation command(s) preceding it (again, may be further up in the log), or update the github gist page of the `brew gist-logs` output with the full log file that was truncated (gists are micro code repos, so you can update individual files).

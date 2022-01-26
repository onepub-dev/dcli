# Existing tooling

As with any software project the first thing you should do is have a look at what pre-existing software is available that might solve your problem.

Maintaining any software is expensive, so if someone else is offering to do it for you...

Dart that eco system has a number of pre-exiting tools this guide notes a few of the more common ones.&#x20;

{% hint style="info" %}
Drop us a line if you know of some other build tools that you think should be listed here.
{% endhint %}

### Native Dart tools

To be complete here are some of the build related tools built into dart

* dart format - format your source code
* dart  doc - generates Dart api documenation
* dart fix - fixes common lint errors
* dart compile - compiles a Dart library with a `main` entry point to an exe
* dart create - creates a Dart project

### build\_runner

build\_runner is a core Dart package and used by many packages to automate the build process.

If you are doing json serialisation then you will already have come across build\_runner as it is used to generate the toJson and fromJson methods.

You can also use build\_runner in your on project to automate build steps.

Unfortunately the documentation on build runner is fairly sparse and and hard to follow. If you want to use build\_runner have a look at some of the projects that depend on build\_runner.&#x20;

{% hint style="info" %}
pub.dev shows a list of packages that use (depend on) a package. This provides an easy way to find sample code for any package.
{% endhint %}

### Github Actions

Github supports actions which allow you to automate a build/test process each time you push to git.

Github actions support Linux, Windows and MacOS which allows you to build a target for multiple OSs.

Github actions are essentially a declarative system as opposed to procedural.

I've never been a fan of declarative build systems (all the way back to make) as they tend to rely on too many magic interactions between declarative steps.

&#x20;

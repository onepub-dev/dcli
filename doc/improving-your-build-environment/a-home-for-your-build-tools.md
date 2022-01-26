# A home for your build tools

Your approach to developing build tools should be like developing any piece of software. Build tools are a key part of a successful project and should not be neglected.

{% hint style="info" %}
Home is where heart is but I prefer my tools down in the shed.
{% endhint %}

## &#x20;Where do my tools go?

There are five places I typically place build related tools depending on their scope.

{% hint style="info" %}
Include instructions on how to build your project in your README.MD
{% endhint %}

### Tool directory

The Dart specification includes a 'tool' directory under your project root. This is the right spot to place package specific tools.

```
bin
    flutter_main.dart
lib
    src
        some_flutter_code.dart
tool
    build.dart
```

If you need Dart additional Dart packages to build your tools you add them under the dev\_dependencies section of you Dart project.

```yaml
name: my_project
dependencies:
  some_flutter_package: ^1.0.0
dev_dependencies:
  dcli: ^1.14.0
```

The easiest way to add a dev dependency is from the cli

```bash
dart pub add --dev dcli
```

Dart libraries in you tool directory will normally contain a `main()` .&#x20;

```dart
!# /bin/env dcli
void main(List<String> args)
{
}
```

You should have a library called 'build.dart' which is the script you run to build you project. Being consistent in the naming convention makes it easer for other users.

### Separate package in multi-package repo

For projects that are made up of several packages contained in a multi-project git repo I generally create an additional 'build' project in the root of the repo.

Using a separate package makes it easier for other users to find the build tools rather than looking in the tool directory of each package.

You may still have build tools in the tool directory of a specific package but these should related to build issues specific to that package.

When using a sperate build package you typically don't have any files in the tool directory of the build package (unless you need a build tool for the build package).

With a build package you place you apps in the `bin` directory of the build package and source code in the normal lib\src structure.

```
bin
   build.dart
lib
   src
      build_support_code.dart
```

The dependency for the build project are added to the normal dependencies section of the build projects pubspec.yaml.&#x20;

```yaml
name: my_builder
dependencies:
  dcli:^1.14.0
```

### Common Build libraries

If you are running multiple projects with common build needs it can often be handy to create a 'build library' package. This package doesn't contain any main entry points.

Its sole purpose is to be a common repository of reusable code that your other build projects use.

```yaml
name: common_build_libs
dependencies:
    dcli: ^1.14.0
```

```
bin
    <empty>
lib
    src
        common_building_stuff.dart
```

### Build Tools Project(s)

Our deployment and production environments are built and run using Dart cli apps.

To support this environment we have a number of Dart packages that we using to deploy and run our systems.

We have a node management package that contains all of the cli apps required to create cloud instances (which refer to as nodes) and deploy our production systems to those nodes.

We then have a main package that is deployed to the system that provides any 'on node' management and diagnostic tools.

The deployment scripts compile the 'on node' scripts and deploy them as binaries to each node. (In this way we don't need to deploy Dart to the nodes reducing the security concerns around having a complete dev system on a production node).

&#x20;We also have a number of  specific build packages to build our Docker containers such as the Docker container we deploy on node to orchestrate backups.

### Tool Kit

Every developer has (or should have) a kit bag of tools that you take with you to help you get stuff done.

Dart makes packing your kit bag easy.

Create yourself a toolbag package and publish it to pub.dev.

Now where ever you go your tools are a simple command away

```
pub global activate my_toolbag
```

{% hint style="info" %}
To avoid polluting then pub.dev namespace please use a name that is unlikely to be used by a real project.  I recommend using something of the nature \<mycompany\_toolbag>.

If you have an internal pub.dev repository then deploy your toolbag there.
{% endhint %}

The structure of your tool bag project should be:

```
bin
    build_all.dart
    pub_get_all.dart
    git_clean.dart
    docker_clean.dart
lib
    src
        common.dart
```

To expose each of the bin libraries as executables add an executables section to your pubspec.yaml

```yaml
name: mycompany_toolbag
dependencies:
    dcli: ^1.14.0
executables:
    build_all:
    pub_get_all:
    git_clean:
    docker_clean:
    
```

{% hint style="warning" %}
Don't leave any company sensitive information in your source code! When you publish to pub.dev all of you source code is published. Use .gitignore and .pubignore to exclude files.
{% endhint %}

To publish your package to pub.dev run:

```bash
pub publish
```

You will need a google account to publish.

Once published you can activate your new toolbag on any system that has Dart installed.

```bash
pub global activate mycompany_toolbak
```

Each of you executables listed in the `executables` section of the packages pubspec.yaml are now available to run from your PATH.

```bash
build_all
```

### Binary deployments from GIT

Sometimes you need your toolbag on systems that don't (and shouldn't) have the Dart SDK installed.

{% hint style="info" %}
It is poor practice to put the Dart SDK (or any SDK) on a production system as it significantly increases your security risk surface.
{% endhint %}

&#x20;Being able to deploy a compiled Dart app (without needing a runtime) directly to a production system can solve this problem.

For the occasional use you can simply compile your Dart app to an executable and upload it to the production system.

```bash
dart compile exe bin/my_diag_tool.dart
or
dcli compile bin/my_diag_tool.dart
```

Then copy the resulting exe to the production system.

```bash
scp bin/my_diag_tool host.prodution.com:
```

Login to the remote system and you a ready to go.

If you regular access to you tools on production systems then you should consider deploying those tools as part of you production deployment process. But remember each time you deploy a tool to production you increase your risk profile.

### Use git as a binary repository

Another technique is to use git as a repository for your binaries.

Git allows you to create 'releases' which can include binary executables.  You can then download these releases directly from Git onto any system. &#x20;

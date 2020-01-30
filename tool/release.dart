#! /usr/bin/env dshell
import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/pubspec/pubspec_file.dart';
import 'package:pub_semver/pub_semver.dart';

void main(List<String> args) {
  var parser = ArgParser();
  parser.addFlag('incVersion',
      abbr: 'i',
      defaultsTo: true,
      help: 'Prompts the user to increment the version no.');

  parser.addCommand('help');
  var results = parser.parse(args);

  // only one commmand so it must be help
  if (results.command != null) {
    showUsage(parser);
    exit(0);
  }

  var incVersion = results['incVersion'] as bool;

  // climb the path searching for the pubspec
  var pubspecPath = findPubSpec();
  var projectRootPath = dirname(pubspecPath);
  var pubspec = getPubSpec(pubspecPath);
  var currentVersion = pubspec.version;

  print('Found pubspec.yaml in ${pubspecPath}');
  print('Current Dshell version is $currentVersion');

  var newVersion = currentVersion;
  if (incVersion) {
    newVersion = incrementVersion(currentVersion, pubspec, pubspecPath);
  }

  generateReleaseNotes(projectRootPath, newVersion, currentVersion);

  checkCommited();

  pushRelease();

  addGitTag(newVersion);

  publish(pubspecPath);
}

void publish(String pubspecPath) {
  var projectRoot = dirname(pubspecPath);

  'pub publish --dry-run'.start(workingDirectory: projectRoot);
}

void pushRelease() {
  print(" woudl run 'git push'.run");
}

void checkCommited() {
  var notCommited = 'git status --porcelain'.toList();

  if (notCommited.isNotEmpty) {
    print('You have uncommited files');
    if (confirm(prompt: 'Do you want to list them (Y/N):')) {
      print(notCommited.join('\n'));
    }
    if (!confirm(prompt: 'Do you want to continue with the release (Y/N)')) {
      exit(-1);
    }
  }
}

void generateReleaseNotes(
    String projectRootPath, Version newVersion, Version currentVersion) {
  // see https://blogs.sap.com/2018/06/22/generating-release-notes-from-git-commit-messages-using-basic-shell-commands-gitgrep/
  // for better ideas.

  var currentTag = 'git --no-pager tag --list'.lastLine;
  // just the messages from each commit
  var messages = 'git --no-pager log --pretty=format:"%s" ${currentTag}'.toList();
  var changeLogPath = join(projectRootPath, 'CHANGELOG.md');

  // write the commit messages to the change log.
  // Not very nices as the commit messages are necessarily that useful.
  var backup = '$changeLogPath.bak';
  move(changeLogPath, backup);

  changeLogPath.write('### ${newVersion.toString()}');

  messages.forEach((message) => changeLogPath.append(message));
  changeLogPath.append('');
  read(backup).forEach((line) => changeLogPath.append(line));
  delete(backup);
}

String findPubSpec() {
  var pubspecName = 'pubspec.yaml';
  var cwd = pwd;
  var found = true;

  var pubspecPath = join(cwd, pubspecName);
  // climb the path searching for the pubspec
  while (!exists(pubspecPath)) {
    cwd = dirname(cwd);
    if (cwd == '/') {
      found = false;
      break;
    }
    pubspecPath = join(cwd, pubspecName);
  }

  if (!found) {
    print(
        'Unable to find pubspec.yaml, run release from the dshell root directory.');
    exit(-1);
  }
  return truepath(pubspecPath);
}

PubSpecFile getPubSpec(String pubspecPath) {
  var pubspec = PubSpecFile.fromFile(pubspecPath);

  // check that the pubspec is ours
  if (pubspec.name != 'dshell') {
    print(
        'Found a pubspec at ${absolute(pubspecPath)} but it does not belong to dshell. ');
    exit(-1);
  }
  return pubspec;
}

void addGitTag(Version version) {
  if (confirm(prompt: 'Create a git release tag (Y/N):')) {
    var tagName = 'v${version}';

    // Check if the tag already exists and offer to replace it if it does.
    if (tagExists(tagName)) {
      var replace = confirm(
          prompt:
              'The tag $tagName already exists. Do you want to replace it? (Y/N):');
      if (replace) {
        'git tag -d $tagName'.run;
        'git push origin :refs/tags/$tagName'.run;
        print('');
      }
    }

    print('creating git tag');
    'git tag -a $tagName'.run;

    var message = ask(prompt: 'Enter a release message:');
    'git tag -a $tagName -m "$message"'.run;
  }
}

void showUsage(ArgParser parser) {
  print('''Releases a dart project:
      Increments the version no. in pubspec.yaml
      Regenerates src/util/version.g.dart with the new version no.
      Creates a git tag with the version no. in the form 'v<version-no>'
      Updates the CHANGELOG.md with a new version no. and the set of
      git commit messages.
      Commits the above changes
      Pushes the final results to git
      Runs docker unit tests checking that they have passed (?how)
      Publishes the package using 'pub publish'

      Usage:
      ${parser.usage}
      ''');
}

bool tagExists(String tagName) {
  var tags = 'git tag --list'.toList();

  return (tags.contains(tagName));
}

Version incrementVersion(
    Version version, PubSpecFile pubspec, String pubspecPath) {
  if (confirm(prompt: 'Is this a breaking change? (Y/N)')) {
    version = version.nextBreaking;
  } else if (confirm(prompt: 'Is a small patch? (Y/N)')) {
    version = version.nextPatch;
  } else {
    version = version.nextMinor;
  }

  // recreate the version file
  var dshellRootPath = dirname(pubspecPath);

  print('');
  print('The new version is: $version');
  if (confirm(prompt: 'Is this the correct version (Y/N): ')) {
    // write new version.g.dart file.
    var versionPath =
        join(dshellRootPath, 'lib', 'src', 'util', 'version.g.dart');
    print('Regenerating version file at ${absolute(versionPath)}');
    versionPath
        .write('/// GENERATED BY dshell tool/release.dart do not modify.');
    versionPath.append('');
    versionPath.append("var dshell_version = '$version';");

    // rewrite the pubspec.yaml with the new version
    pubspec.version = version;
    pubspec.writeToFile(pubspecPath);
  }
  return version;
}

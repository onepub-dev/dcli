/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec2/pubspec2.dart';
import 'package:pubspec_lock/pubspec_lock.dart';

import '../../../dcli.dart' hide PubSpec;
import '../../util/completion.dart';
import '../command_line_runner.dart';
import '../flags.dart';
import 'commands.dart';

/// Takes the current version settings from pubspec.lock
/// and updates the pubspec.yaml with explicit version for
/// each dependency.
/// We do this to make CLI tools less brittle when being globally activated.
/// We ofter see package updates which break a CLI script and unlock
/// a application dependency where you are expecting to tweak depenedencies
/// a CLI app needs to run out of the box every time.
class LockCommand extends Command {
  ///
  LockCommand() : super(_commandName);
  static const String _commandName = 'lock';

  /// [arguments] contains path to prepare
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    String targetPath;

    if (arguments.isEmpty) {
      targetPath = pwd;
    } else if (arguments.length != 1) {
      throw InvalidArgumentException(
        'Expected a single project path or no project path. '
        'Found ${arguments.length} ',
      );
    } else {
      targetPath = arguments[0];
    }

    _lock(targetPath);
    return 0;
  }

  void _lock(String targetPath) {
    if (!exists(targetPath)) {
      throw InvalidArgumentException(
          'The project path $targetPath does not exists.');
    }
    if (!isDirectory(targetPath)) {
      throw InvalidArgumentException('The project path must be a directory.');
    }

    final project = DartProject.fromPath(targetPath);
    final pathToProjectRoot = project.pathToProjectRoot;

    print('');
    print(orange('Locking $pathToProjectRoot ...'));
    print('');

    final projectDir = Directory(pathToProjectRoot);
    // ignore: discarded_futures
    var pubspec = waitForEx(PubSpec.load(projectDir));

    final file = File(join(pathToProjectRoot, 'pubspec.lock'));
    final pubspecLock = file.readAsStringSync().loadPubspecLockFromYaml();

    final dependencies = <String, DependencyReference>{};
    for (final package in pubspecLock.packages) {
      final name = packageName(package);

      /// we exclude dev dependencies.
      if (!pubspec.devDependencies.containsKey(name)) {
        dependencies.addAll(package.iswitch(
            sdk: buildSdk,
            hosted: buildHosted,
            git: buildGit,
            path: buildPath));
      }
    }

    // excluded dev depen
    pubspec = pubspec.copy(dependencies: dependencies);

    // ignore: discarded_futures
    waitForEx<void>(pubspec.save(projectDir));

    print('Updated ${dependencies.length} packages');
  }

  String packageName(PackageDependency dep) => dep.iswitch(
        sdk: (d) => d.package,
        hosted: (d) => d.package,
        git: (d) => d.package,
        path: (d) => d.package,
      );

  // map sdk
  Map<String, DependencyReference> buildSdk(SdkPackageDependency sdk) =>
      {sdk.package: SdkReference(sdk.package)};

  // map git
  Map<String, DependencyReference> buildGit(GitPackageDependency git) =>
      {git.package: GitReference(git.url, git.ref, git.path)};

  // map hosted
  Map<String, DependencyReference> buildHosted(HostedPackageDependency hosted) {
    final version = VersionConstraint.parse(hosted.version) as VersionRange;
    final constrainedVersion =
        version.max ?? version.min ?? VersionConstraint.any;
    if (hosted.url.isEmpty || isPubDev(hosted.url)) {
      return {hosted.package: HostedReference(constrainedVersion)};
    } else {
      return {
        hosted.package:
            ExternalHostedReference(hosted.package, hosted.url, version, false)
      };
    }
  }

  // map path
  Map<String, DependencyReference> buildPath(PathPackageDependency path) =>
      {path.package: PathReference(path.path)};

  @override
  String usage() => 'lock [<project path>]';

  @override
  String description({bool extended = false}) => '''
Updates the pubspec.yaml with all package versions constrained to a single version
based on the current pubspec.lock versions.
The update includes transitive dependencies.
   
The lock method is used to ensure that your CLI app will work even if incompatible
versions of a dependency is released which doesn't conformm to semantic versioning
which is very common. 

We recommend that you lock each CLI package before you release it.
''';

  @override
  List<String> completion(String word) => completionExpandScripts(word);

  @override
  List<Flag> flags() => [];

  bool isPubDev(String url) => url == 'https://pub.dartlang.org';
}

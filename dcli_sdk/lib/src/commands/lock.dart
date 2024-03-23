/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart' as sm;
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:pubspec_manager/pubspec_manager.dart';

import '../script/flags.dart';
import '../util/completion.dart';
import '../util/exceptions.dart';
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
  Future<int> run(List<Flag> selectedFlags, List<String> arguments) async {
    String targetPath;

    if (arguments.isEmpty) {
      targetPath = pwd;
    } else if (arguments.length != 1) {
      throw InvalidCommandArgumentException(
        'Expected a single project path or no project path. '
        'Found ${arguments.length} ',
      );
    } else {
      targetPath = arguments[0];
    }

    await _lock(targetPath);
    return 0;
  }

  Future<void> _lock(String targetPath) async {
    if (!exists(targetPath)) {
      throw InvalidCommandArgumentException(
          'The project path $targetPath does not exists.');
    }
    if (!isDirectory(targetPath)) {
      throw InvalidCommandArgumentException(
          'The project path must be a directory.');
    }

    final project = DartProject.fromPath(targetPath);
    final pathToProjectRoot = project.pathToProjectRoot;

    print('');
    print(orange('Locking $pathToProjectRoot ...'));
    print('');

    // ignore: discarded_futures
    final pubspec = PubSpec.load(directory: pathToProjectRoot);

    final file = File(join(pathToProjectRoot, 'pubspec.lock'));
    final pubspecLock = file.readAsStringSync().loadPubspecLockFromYaml();

    for (final package in pubspecLock.packages) {
      final name = packageName(package);

      /// we exclude dev dependencies.
      if (!pubspec.devDependencies.exists(name)) {
        pubspec.dependencies.add(package.iswitch(
            // we should never see an sdk dep
            sdk: (sdk) => throw DCliException(
                'Unexpected sdk version in package dependency'),
            hosted: buildHosted,
            git: buildGit,
            path: buildPath));
      }
    }

    // excluded dev dependencies
    //  pubspec = pubspec.copy(dependencies: dependencies);

    // ignore: discarded_futures
    pubspec.save();

    print('Updated ${pubspec.dependencies.length} packages');
  }

  String packageName(PackageDependency dep) => dep.iswitch(
        sdk: (d) => d.package,
        hosted: (d) => d.package,
        git: (d) => d.package,
        path: (d) => d.package,
      );

  // map git
  DependencyBuilderGit buildGit(GitPackageDependency git) =>
      DependencyBuilderGit(
          name: git.package, url: git.url, ref: git.ref, path: git.path);

  // map hosted
  DependencyBuilder buildHosted(HostedPackageDependency hosted) {
    final version =
        sm.VersionConstraint.parse(hosted.version) as sm.VersionRange;
    final constrainedVersion =
        version.max ?? version.min ?? sm.VersionConstraint.any;
    if (hosted.url.isEmpty || isPubDev(hosted.url)) {
      return DependencyBuilderPubHosted(
          name: hosted.name, versionConstraint: constrainedVersion.toString());
    } else {
      return DependencyBuilderAltHosted(
          name: hosted.package,
          hostedUrl: hosted.url,
          versionConstraint: version.toString());
    }
  }

  // map path
  DependencyBuilder buildPath(PathPackageDependency path) =>
      DependencyBuilderPath(name: path.package, path: path.path);

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

  bool isPubDev(String url) =>
      url == 'https://pub.dartlang.org' || url == 'https://pub.dev';
}

/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
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
/// and updates the pubspec.yaml with explicit versions for
/// each direct dependency (not transitive).
/// Dev dependencies remain unmodified (not locked).
///
/// Also writes `pubspec.lock-restore.yaml` capturing the original version
/// constraints and source info so an `unlock` command can restore ranges.
class LockCommand extends Command {
  static const _commandName = 'lock';

  LockCommand() : super(_commandName);

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

    _ensureFreshLock(pathToProjectRoot);

    final pubspec = PubSpec.load(directory: pathToProjectRoot);

    // Read the resolved versions from the lockfile.
    final lockFile = File(join(pathToProjectRoot, 'pubspec.lock'));
    if (!lockFile.existsSync()) {
      throw DCliException('''
pubspec.lock not found in $pathToProjectRoot. Run `dart pub get` first.''');
    }
    final pubspecLock = lockFile.readAsStringSync().loadPubspecLockFromYaml();
    // Abort if any local path deps are in the resolved graph (incl. overrides).
    _assertNoLocalPathsInLock(pubspecLock);

    // Build sets of names for quick checks.
    // Only lock direct (non-dev) dependencies listed in pubspec.yaml.
    final directDepNames = <String>{};
    for (final dependency in pubspec.dependencies.list) {
      directDepNames.add(dependency.name);
    }

    _createRestoreFile(
        pathToProjectRoot: pathToProjectRoot,
        pubspec: pubspec,
        directDepNames: directDepNames);

    // Now perform the lock by replacing only direct (non-dev) deps with pinned
    // versions from pubspec.lock.
    var updatedCount = 0;

    for (final package in pubspecLock.packages) {
      final name = packageName(package);

      // Only lock direct deps that are NOT dev deps.
      final isDirect = directDepNames.contains(name);
      final isDev = pubspec.devDependencies.exists(name);
      if (!isDirect || isDev) {
        continue;
      }

      // Remove the existing entry and add a new one with the locked version.
      pubspec.dependencies.remove(name);
      pubspec.dependencies.add(
        package.iswitch(
          // we should never see an sdk dep from lock for a package
          sdk: (sdk) => throw DCliException(
              'Unexpected sdk version in package dependency'),
          hosted: buildHosted,
          git: buildGit,
          path: buildPath,
        ),
      );
      updatedCount++;
    }

    pubspec.save();

    print('Locked $updatedCount direct package(s).');
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
        name: git.package,
        url: git.url,
        ref: git.ref,
        path: git.path,
      );

  // map hosted (pin to the exact resolved version from pubspec.lock)
  DependencyBuilder buildHosted(HostedPackageDependency hosted) {
    final versionRange =
        sm.VersionConstraint.parse(hosted.version) as sm.VersionRange;
    final pinned =
        versionRange.max ?? versionRange.min ?? sm.VersionConstraint.any;

    if (hosted.url.isEmpty || isPubDev(hosted.url)) {
      return DependencyBuilderPubHosted(
        name: hosted.name,
        versionConstraint: pinned.toString(),
      );
    } else {
      return DependencyBuilderAltHosted(
        name: hosted.package,
        hostedUrl: hosted.url,
        versionConstraint: pinned.toString(),
      );
    }
  }

  // map path
  DependencyBuilder buildPath(PathPackageDependency path) =>
      DependencyBuilderPath(name: path.package, path: path.path);

  void _createRestoreFile(
      {required String pathToProjectRoot,
      required PubSpec pubspec,
      required Set<String> directDepNames}) {
    // Prepare a restore file with original constraints for the unlock command.
    // We capture only direct (non-dev) entries.
    final restorePath = join(pathToProjectRoot, 'pubspec.lock-restore.yaml');
    final restore = StringBuffer()
      ..writeln('# Auto-generated by `lock` on '
          '${DateTime.now().toUtc().toIso8601String()}Z')
      ..writeln('# Restores original version ranges & sources for direct deps')
      ..writeln('version: 1')
      ..writeln('dependencies:');

    // Persist original details BEFORE we mutate pubspec.
    for (final depName in directDepNames) {
      if (pubspec.devDependencies.exists(depName)) {
        // As requested: do not track/lock dev_dependencies.
        continue;
      }

      final original = pubspec.dependencies[depName];
      if (original == null) {
        // Unusual, but ignore gracefully.
        continue;
      }

      // Emit a compact YAML snippet per dependency.
      // We preserve source & any relevant fields so unlock can
      // faithfully restore.
      switch (original) {
        case DependencyPubHosted(:final versionConstraint):
          final vc = versionConstraint;
          restore
            ..writeln('  $depName:')
            ..writeln('    source: hosted')
            ..writeln('    constraint: "$vc"');

        case DependencyAltHosted(:final versionConstraint, :final hostedUrl):
          final vc = versionConstraint;
          restore
            ..writeln('  $depName:')
            ..writeln('    source: hosted')
            ..writeln('    url: "$hostedUrl"')
            ..writeln('    constraint: "$vc"');

        case DependencyGit(:final url, :final ref, :final path):
          restore
            ..writeln('  $depName:')
            ..writeln('    source: git')
            ..writeln('    url: "$url"');
          if (ref != null) {
            restore.writeln('    ref: "$ref"');
          }
          if (path != null) {
            restore.writeln('    path: "$path"');
          }

        case DependencyPath(:final path):
          restore
            ..writeln('  $depName:')
            ..writeln('    source: path')
            ..writeln('    path: "$path"');

        case DependencySdk(:final sdk):
          restore
            ..writeln('  $depName:')
            ..writeln('    source: sdk')
            ..writeln('    sdk: "$sdk"');
      }
    }

    File(restorePath).writeAsStringSync(restore.toString());

    print(green('''
Wrote restore file: ${relative(restorePath, from: pathToProjectRoot)}'''));
  }

  void _assertNoLocalPathsInLock(PubspecLock lock) {
    final offenders = <String>[];

    for (final pkg in lock.packages) {
      pkg.iswitch(
        hosted: (_) {}, // ok
        git: (_) {}, // ok (git subdir != local FS path)
        sdk: (_) {}, // ok
        path: (p) => offenders.add('${p.package} → path: ${p.path}'),
      );
    }

    if (offenders.isNotEmpty) {
      final buf = StringBuffer()
        ..writeln(red('Lock aborted. Local `path:` dependencies are in use.'))
        ..writeln(
            'Detected from pubspec.lock (likely via pubspec_overrides.yaml).')
        ..writeln(
            'Replace local paths with hosted or git deps, then re-run `lock`:');
      for (final o in offenders) {
        buf.writeln('  • $o');
      }
      throw ExitWithMessageException(buf.toString());
    }
  }

  void _ensureFreshLock(String projectRoot) {
    final pubspecPath = join(projectRoot, 'pubspec.yaml');
    final overridesPath = join(projectRoot, 'pubspec_overrides.yaml');
    final lockPath = join(projectRoot, 'pubspec.lock');

    final pubspecStat = File(pubspecPath).statSync();
    final overridesStat = File(overridesPath).existsSync()
        ? File(overridesPath).statSync()
        : null;

    // If lock is missing, it's definitely stale.
    final lockExists = File(lockPath).existsSync();
    DateTime? lockMtime;
    if (lockExists) {
      lockMtime = File(lockPath).statSync().modified;
    }

    // The newest source file time that can affect resolution.
    final latestSpecMtime = [
      pubspecStat.modified,
      if (overridesStat != null) overridesStat.modified,
    ].reduce((a, b) => a.isAfter(b) ? a : b);

    final needsPubGet = !lockExists || (lockMtime!.isBefore(latestSpecMtime));

    if (needsPubGet) {
      print(orange(
          'pubspec.lock is missing or stale. Running `dart pub get`...'));
      final progress = Progress.print();
      DartSdk().runPubGet(projectRoot, progress: progress);

      if (progress.exitCode != 0) {
        throw ExitWithMessageException('`dart pub get` failed. Aborting lock.');
      }

      // Optional: sanity check the lock now exists.
      if (!File(lockPath).existsSync()) {
        throw DCliException(
            '`dart pub get` did not produce pubspec.lock at $lockPath');
      }
      print(green('pubspec.lock updated.'));
    }
  }

  @override
  String usage() => 'lock [<project path>]';

  @override
  String description({bool extended = false}) => '''
Updates the pubspec.yaml with all direct package versions constrained to a single
version based on the current pubspec.lock. Transitive dependencies are ignored.
Dev dependencies are not locked.

Also generates pubspec.lock-restore.yaml which captures the original dependency
sources and version ranges, so an unlock command can restore them.
''';

  @override
  List<String> completion(String word) => completionExpandScripts(word);

  @override
  List<Flag> flags() => [];

  bool isPubDev(String url) =>
      url == 'https://pub.dartlang.org' || url == 'https://pub.dev';
}

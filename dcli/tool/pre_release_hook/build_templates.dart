#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

// import 'dart:io';

import 'dart:collection';
import 'dart:io';

import 'package:dcli/dcli.dart' hide PubSpec;
import 'package:dcli/src/version/version.g.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec2/pubspec2.dart';

late String newVersion;
void main(List<String> args) async {
  print('Updating templates');
  await prepareTemplates();
  'dcli pack'.run;
}

/// Update each of the project templates (used by dcli create)
/// to reference the latest version of dcli.
Future<void> prepareTemplates() async {
  final dcliProject = DartProject.self;
  final pathToTemplates = join(dcliProject.pathToProjectRoot, '..', 'template');

  final pubspec = await PubSpec.loadFile(dcliProject.pathToPubSpec);
  final environment = pubspec.environment;

  find('pubspec.yaml', workingDirectory: pathToTemplates)
      .forEach((pathToTemplate) async {
    print(pathToTemplate);
    final pubspec = await PubSpec.loadFile(pathToTemplate);
    final existing = pubspec.dependencies;

    /// need a mutable map
    final newdeps = SplayTreeMap<String, DependencyReference>()
      ..addAll(existing)
      ..remove('dcli')
      ..remove('dcli_core')
      ..addAll({
        'dcli': HostedReference(VersionConstraint.parse('^$packageVersion')),
        'dcli_core':
            HostedReference(VersionConstraint.parse('^$packageVersion'))
      });

    final updated =
        pubspec.copy(dependencies: newdeps, environment: environment);

    await updated.save(Directory(dirname(pathToTemplate)));
  });
}

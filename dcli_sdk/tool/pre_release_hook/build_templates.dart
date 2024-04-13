#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli/src/version/version.g.dart';
import 'package:path/path.dart';
import 'package:pubspec_manager/pubspec_manager.dart';

void main(List<String> args) async {
  print('Updating templates');
  await prepareTemplates();
  Resources().pack();
}

/// Update each of the project templates (used by dcli create)
/// to reference the latest version of dcli
/// and update the sdk constraints.
Future<void> prepareTemplates() async {
  final dcliProject = DartProject.self;
  final pathToTemplates = join(dcliProject.pathToProjectRoot, '..', 'template');

  final pubspec = PubSpec.loadFromPath(dcliProject.pathToPubSpec);
  final environment = pubspec.environment;

  find('pubspec.yaml', workingDirectory: pathToTemplates)
      .forEach((pathToTemplate) async {
    print(pathToTemplate);
    final pubspec = PubSpec.loadFromPath(pathToTemplate);
    final dependencies = pubspec.dependencies;

    if (dependencies.exists('dcli')) {
      (dependencies['dcli']! as DependencyPubHosted).versionConstraint =
          packageVersion;
    }

    if (dependencies.exists('dcli_core')) {
      (dependencies['dcli_core']! as DependencyPubHosted).versionConstraint =
          packageVersion;
    }
    pubspec
      ..environment.sdk = environment.sdk
      ..environment.flutter = environment.flutter
      ..save();
  });
}

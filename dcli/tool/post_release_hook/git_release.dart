#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:settings_yaml/settings_yaml.dart';

/// @Throwing(ArgumentError)
/// @Throwing(SettingsYamlException)
void main(List<String> args) {
  final project = DartProject.self;

  final pathToSettings = join(
    project.pathToProjectRoot,
    'tool',
    'post_release_hook',
    '.settings.yaml',
  );
  final settings = SettingsYaml.load(pathToSettings: pathToSettings);
  final username = settings['username'] as String?;
  final personalAccessToken = settings['personalAccessToken'] as String?;
  final owner = settings['owner'] as String?;
  final repository = settings['repository'] as String?;

  'github_release -u $username --apiToken $personalAccessToken --owner $owner '
          '--repository $repository'
      .start(workingDirectory: DartProject.self.pathToProjectRoot);
}

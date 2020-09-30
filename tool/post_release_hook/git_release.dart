#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';
import 'package:settings_yaml/settings_yaml.dart';

void main(List<String> args) {
  var project = DartProject.current;

  var pathToSettings = join(project.pathToProjectRoot, 'tool',
      'post_release_hook', 'settings.config');
  var settings = SettingsYaml.load(pathToSettings: pathToSettings);
  var username = settings['username'] as String;
  var apiToken = settings['apiToken'] as String;
  var owner = settings['owner'] as String;
  var repository = settings['repository'] as String;

  'github_release -u $username --apiToken $apiToken --owner $owner --repository $repository --suffix linux'
      .start(workingDirectory: Script.current.pathToProjectRoot);
}

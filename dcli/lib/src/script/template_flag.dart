import 'package:path/path.dart';

import '../../dcli.dart';
import 'flags.dart';

/// Allows a user to select which template to use when
/// creating a project.
class TemplateFlag extends Flag {
  ///
  factory TemplateFlag() => _self;

  ///
  TemplateFlag._internal() : super(flagName);

  static const defaultTemplateName = 'simple';
  static const flagName = 'template';
  static final _self = TemplateFlag._internal();

  static final String defaultTemplatePath =
      join(Settings().pathToTemplateProject, defaultTemplateName);

  String? _templateName;

  @override
  // Returns the templateName
  String get option => _templateName!;

  /// true if the flag has an option.
  bool get hasOption => _templateName != null;

  @override
  bool get isOptionSupported => true;

  @override
  set option(String? value) {
    _templateName = value ?? defaultTemplateName;
  }

  @override
  String get abbreviation => 't';

  @override
  String usage() =>
      '--$flagName=<template name> | -$abbreviation=<template name>';

  @override
  String description() => '''
      Defines the name of the template to create the script or project from.
      If not passed the 'simple' template is used.''';
}

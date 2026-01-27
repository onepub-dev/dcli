import 'flag.dart';

/// Prints a list of the templates and exists
class TemplateListFlag extends Flag {
  static const flagName = 'list';

  static final _self = TemplateListFlag._internal();

  ///
  factory TemplateListFlag() => _self;

  ///
  TemplateListFlag._internal() : super(flagName);

  @override
  String get option => '';

  /// true if the flag has an option.
  bool get hasOption => false;

  @override
  bool get isOptionSupported => false;

  @override
  set option(String? value) {}

  @override
  String get abbreviation => 'l';

  @override
  String usage() => '--$flagName';

  @override
  String description() => '''
      Prints a list of project and script templates then exits.
''';
}

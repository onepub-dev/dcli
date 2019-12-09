import 'package:dshell/pubspec/pubspec.dart';
import 'package:dshell/script/dependency.dart';
import 'package:dshell/script/script.dart';

///
/// If no user defined pubspec exists we need to create
/// a default pubspec with the standard set
/// of dependencies we inject.
class PubSpecDefault implements PubSpec // with DependenciesMixin
{
  PubSpecImpl pubspec;
  Script _script;

  String get name => _script.basename;
  String get version => "1.0.0";

  PubSpecDefault(this._script) {
    pubspec = PubSpecImpl.fromString(_default());
  }

  /// Creates default content for a virtual pubspec
  String _default() {
    // List<Dependency> dependancies = defaultDepencies;

    // List<String> yamlLines = dependancies
    //     .map((dependancy) => "${dependancy.name}: ${dependancy.version}")
    //     .toList();

    return '''
name: ${_script.basename}
version: $version
''';
// dependencies:
//   ${yamlLines.join("\n  ")}
//    ''';
  }

  @override
  set dependencies(List<Dependency> newDependencies) {
    pubspec.dependencies = newDependencies;
  }

  @override
  List<Dependency> get dependencies => pubspec.dependencies;

  @override
  void writeToFile(String path) {
    pubspec.writeToFile(path);
  }

  // static List<Dependency> get defaultDepencies {
  //   return [
  //     Dependency("dshell", "^1.0.0"),
  //     Dependency("args", "^1.5.2"),
  //     Dependency("path", "^1.6.4"),
  //   ];
  // }
}

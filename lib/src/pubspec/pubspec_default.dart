import 'pubspec.dart';
import '../script/dependency.dart';
import '../script/script.dart';

///
/// If no user defined pubspec exists we need to create
/// a default pubspec with the standard set
/// of dependencies we inject.
class PubSpecDefault implements PubSpec // with DependenciesMixin
{
  PubSpecImpl pubspec;
  final Script _script;

  @override
  String get name => _script.basename;
  @override
  String get version => '1.0.0';

  PubSpecDefault(this._script) {
    pubspec = PubSpecImpl.fromString(_default());
  }

  /// Creates default content for a virtual pubspec
  String _default() {
    return '''
name: ${_script.basename}
version: $version
''';
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
}

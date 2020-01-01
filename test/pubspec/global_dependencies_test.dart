import 'package:dshell/src/pubspec/global_dependencies.dart';
import 'package:dshell/src/script/dependency.dart';
import 'package:test/test.dart';

void main() {
  test('load', () {
    var content = '''
dependencies:
  args: ^1.5.2
  collection: ^1.14.12
  file_utils: ^0.1.3
  path: ^1.6.4
  ''';

    var expected = [
      Dependency('args', '^1.5.2'),
      Dependency('collection', '^1.14.12'),
      Dependency('file_utils', '^0.1.3'),
      Dependency('path', '^1.6.4'),
    ];

    var gd = GlobalDependencies.fromString(content);
    expect(gd.dependencies, equals(expected));
  });
}

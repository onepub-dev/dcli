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

  test('dependency_overrides', () {
    var content = '''
dependencies:
  args: ^1.5.2
  collection: ^1.14.12
  file_utils: ^0.1.3
  path: ^1.6.4
  dshell:
    path: /home/dshell
dependency_overrides:
  args:
    path: /home/args
  ''';

    var expected = [
      Dependency.fromPath('args', '/home/args'),
      Dependency('collection', '^1.14.12'),
      Dependency('file_utils', '^0.1.3'),
      Dependency('path', '^1.6.4'),
      Dependency.fromPath('dshell', '/home/dshell'),
    ];

    var gd = GlobalDependencies.fromString(content);
    expect(gd.dependencies, equals(expected));
  });

  test('local dshell', () {
    var content = '''
dependencies:
  dshell: ^1.0.44 
  args: ^1.5.2
  path: ^1.6.4

dependency_overrides:
  dshell: 
    path: /home//dshell
  ''';

    var expected = [
      Dependency.fromPath('dshell', '/home/dshell'),
      Dependency('args', '^1.5.2'),
      Dependency('path', '^1.6.4'),
    ];

    var gd = GlobalDependencies.fromString(content);
    expect(gd.dependencies, equals(expected));
  });
}

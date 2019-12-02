import 'package:dshell/pubspec/global_dependancies.dart';
import 'package:dshell/script/dependency.dart';
import 'package:test/test.dart';

void main() {
  test("load", () {
    String content = """
dependencies:
  args: ^1.5.2
  collection: ^1.14.12
  file_utils: ^0.1.3
  path: ^1.6.4
  """;

    List<Dependency> expected = [
      Dependency("args", "^1.5.2"),
      Dependency("collection", "^1.14.12"),
      Dependency("file_utils", "^0.1.3"),
      Dependency("path", "^1.6.4"),
    ];

    GlobalDependancies gd = GlobalDependancies.fromString(content);
    expect(gd.dependancies, equals(expected));
  });
}

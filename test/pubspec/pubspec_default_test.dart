import 'package:dshell/pubspec/pubspec_default.dart';
import 'package:dshell/script/script.dart';
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

    Script script = Script.fromArg("local/test.dart");
    PubSpecDefault pubSpec = PubSpecDefault(script);

    expect(pubSpec.dependencies, equals(PubSpecDefault.defaultDepencies));
  });
}

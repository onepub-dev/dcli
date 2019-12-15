import 'package:dshell/pubspec/pubspec_annotation.dart';
import 'package:test/test.dart';

void main() {
  test("parse", () {
    String annotation = """
    /*
      @pubspec
      name: find.dart
      dependencies:
        dshell: ^1.0.0
        args: ^1.5.2
        path: ^1.6.4
    */
    """;

    PubSpecAnnotation.fromString(annotation);
  });
}

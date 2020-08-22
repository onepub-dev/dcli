@Timeout(Duration(seconds: 600))
import 'package:dcli/src/pubspec/pubspec_annotation.dart';
import 'package:test/test.dart';

void main() {
  test('parse /*', () {
    var annotation = '''
    /*
      @pubspec
      name: find.dart
      dependencies:
        dcli: ^1.0.0
        args: ^1.5.2
        path: ^1.6.4
    */
    ''';

    var pubspec = PubSpecAnnotation.fromString(annotation);
    expect(pubspec.annotationFound(), equals(true));
  });

  test('parse /**', () {
    var annotation = '''
    /**
      @pubspec
      name: find.dart
      dependencies:
        dcli: ^1.0.0
        args: ^1.5.2
        path: ^1.6.4
    **/
    ''';

    var pubspec = PubSpecAnnotation.fromString(annotation);
    expect(pubspec.annotationFound(), equals(true));
  });

  test('parse * on lines', () {
    /**
       * 
       */
    var annotation = '''
    /**
     *  @pubspec
     *  name: find.dart
     *  dependencies:
     *    dcli: ^1.0.0
     *    args: ^1.5.2
     *    path: ^1.6.4
    **/
    ''';

    var pubspec = PubSpecAnnotation.fromString(annotation);
    expect(pubspec.annotationFound(), equals(true));
  });

  test('parse /*@pubsec', () {
    /**
       * 
       */
    var annotation = '''
    /*@pubspec
     *  name: find.dart
     *  dependencies:
     *    dcli: ^1.0.0
     *    args: ^1.5.2
     *    path: ^1.6.4
    */
    ''';

    var pubspec = PubSpecAnnotation.fromString(annotation);
    expect(pubspec.annotationFound(), equals(true));
  });

  test('parse /**@pubsec', () {
    /**
       * 
       */
    var annotation = '''
    /**@pubspec
     *  name: find.dart
     *  dependencies:
     *    dcli: ^1.0.0
     *    args: ^1.5.2
     *    path: ^1.6.4
    */
    ''';

    var pubspec = PubSpecAnnotation.fromString(annotation);
    expect(pubspec.annotationFound(), equals(true));
  });

  test('parse /**@pubsec', () {
    /**
       * 
       */
    var annotation = '''
    /**@pubspec
     *  name: find.dart
     *  dependencies:
     *    dcli: ^1.0.0
     *    args: ^1.5.2
     *    path: ^1.6.4
    */
    ''';

    var pubspec = PubSpecAnnotation.fromString(annotation);
    expect(pubspec.annotationFound(), equals(true));
  });

  test('parse /* @pubsec', () {
    var annotation = '''
    /* @pubspec
name: test
version: 1.0.0
dependencies:
  dcli: ^2.0.0
  args: ^2.0.1
  collection: ^1.14.12
  file_utils: ^0.1.3
  path: ^2.0.2
*/
''';

    var pubspec = PubSpecAnnotation.fromString(annotation);
    expect(pubspec.annotationFound(), equals(true));
  });
}

@Timeout(Duration(seconds: 600))
import 'package:dshell/src/pubspec/pubspec_annotation.dart';
import 'package:test/test.dart';


void main() {
  test('parse /*', () {
    var annotation = '''
    /*
      @pubspec
      name: find.dart
      dependencies:
        dshell: ^1.0.0
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
        dshell: ^1.0.0
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
     *    dshell: ^1.0.0
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
     *    dshell: ^1.0.0
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
     *    dshell: ^1.0.0
     *    args: ^1.5.2
     *    path: ^1.6.4
    */
    ''';

    var pubspec = PubSpecAnnotation.fromString(annotation);
    expect(pubspec.annotationFound(), equals(true));
  });
}

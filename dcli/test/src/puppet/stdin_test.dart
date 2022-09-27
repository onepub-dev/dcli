import 'package:dcli/src/puppet/stdin.dart';
import 'package:test/test.dart';

void main() {
  test('stdin ...', () async {
    final puppet = PuppetStdin();
    const value = 'Hello World';
    puppet.writeLineSync(value);

    final line = puppet.readLineSync();

    expect(line, equals(value));
  });

  test('stdin - 100 lines', () async {
    final puppet = PuppetStdin();
    const value = 'Hello World';

    for (var i = 0; i < 100; i++) {
      puppet.writeLineSync('$value $i');
    }

    for (var i = 0; i < 100; i++) {
      final line = puppet.readLineSync();

      expect(line, equals('$value $i'));
    }
  });

  test('stdin - eof', () async {
    final puppet = PuppetStdin();
    const value = 'Hello World';

    for (var i = 0; i < 100; i++) {
      puppet.writeLineSync('$value $i');
    }
    puppet.close();

    var i = 0;
    String? line;
    while ((line = puppet.readLineSync()) != null) {
      expect(line, equals('$value $i'));
      i++;
    }
    expect(i, equals(100));
  });

 
}

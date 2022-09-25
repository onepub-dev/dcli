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
}

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('bash shell loggedInUser', () async {
    expect(Shell.current.loggedInUser, env('USER'));
  });

  // don't know how to automat this test as we need the sudo password.
  // test('bash shell loggedInUser under sudo', () async {
  //   expect(Shell.current.loggedInUser, env('USER'));
  // });
}

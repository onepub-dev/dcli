import 'package:dcli/src/functions/confirm.dart';
import 'package:test/test.dart';

void main() {
  test(
    'confirm no default',
    () {
      final result = confirm('Are you good?');
      print('result: $result');
    },
    skip: true,
  );

  test(
    'confirm default=true',
    () {
      final result = confirm('Are you good?', defaultValue: true);
      print('result: $result');
    },
    skip: true,
  );

  test(
    'confirm default=false',
    () {
      final result = confirm('Are you good?', defaultValue: false);
      print('result: $result');
    },
    skip: true,
  );
}

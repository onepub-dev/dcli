import 'package:dcli/src/util/file_util.dart';
import 'package:test/test.dart';

void main() {
  test('file util ...', () async {
    print(DateTime.now());
    calculateHash(
        '/home/bsutton/git/batman.bak/batman/test/sample_logs/njcontact.log');
    print(DateTime.now());
  });
}

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('simple run', () async{
    await withTempFileAsync ((testFile) async{
      'touch $testFile'.run;
    });
  });
}

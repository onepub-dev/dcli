import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(DeleteException)
/// @Throwing(TouchException)
void main() {
  // test('synchronous ...', () async {
  //   final p = ProcessSync()..run(ProcessSettings('cat'));

  //   for (var i = 0; i < 10; i++) {
  //     p.writeLine('line $i\n');
  //     final line = p.readStdout();
  //     print('from cat: $line');
  //   }
  // });

  test('onepub - exitCode', () async{
    await withTempFileAsync ((tokenFile) async{
      final progress = Progress.capture();
      expect(
          '''onepub export --user opcicd@cicd.jbbxpsdavu.onepub.dev --file $tokenFile'''
              .start(nothrow: true, progress: progress)
              .exitCode,
          equals(0));
    });
  });
}

@Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/file_sync.dart';
import 'package:test/test.dart';

// Creates text file with the given no. of lines.
void createLineFile(String testFile, int lines) {
  if (exists(testFile)) {
    delete(testFile);
  }

  if (!exists(dirname(testFile))) {
    createDir(dirname(testFile));
  }

  var file = FileSync(testFile);
  for (var i = 0; i < 10; i++) {
    file.append('Line $i is here');
  }
  file.close();
}

import 'package:dshell/dshell.dart';
import 'package:dshell/util/file_sync.dart';

// Creates text file with the given no. of lines.
void createLineFile(String testFile, int lines) {
  if (exists(testFile)) {
    delete(testFile);
  }

  makeDir(dirname(testFile));

  FileSync file = FileSync(testFile);
  for (int i = 0; i < 10; i++) {
    file.append("Line ${i} is here");
  }
  file.close();
}

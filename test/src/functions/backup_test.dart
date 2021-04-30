import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('backup/restore good path', () async {
    final root = createTempDir();
    const filename = 'test.txt';
    final file = join(root, filename);

    const content = 'Hellow World';
    file.write(content);

    backupFile(file);

    final backupFilename = '${join(root, '.bak', filename)}.bak';

    expect(exists(backupFilename), isTrue);
    expect(exists(file), isTrue);

    const secondline = 'Foo was here';

    file.append(secondline);

    expect(read(file).toList().join('\n').contains(secondline), isTrue);

    restoreFile(file);

    expect(read(file).toList().join('\n').contains(secondline), isFalse);

    expect(exists(backupFilename), isFalse);
  });

  test('restore missing backup', () async {
    final root = createTempDir();
    const filename = 'test.txt';
    final file = join(root, filename);

    const content = 'Hellow World';
    file.write(content);

    backupFile(file);

    final backupFilename = '${join(root, '.bak', filename)}.bak';

    // do a bad thing, delete the backup.
    delete(backupFilename);

    expect(() => restoreFile(file), throwsA(isA<RestoreFileException>()));
  });

  test('backup missing file', () async {
    final root = createTempDir();
    const filename = 'test.txt';
    final file = join(root, filename);

    const content = 'Hellow World';
    file.write(content);

    delete(file);

    expect(() => backupFile(file), throwsA(isA<CopyException>()));
  });
}

import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('copy filename to filename the good path', () async {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename)..append('Hellow World');

    const toFilename = 'text2.txt';
    final to = join(root, toFilename);

    copy(from, to);

    expect(exists(from), isTrue);

    expect(exists(to), isTrue);

    final toContent = read(to).toParagraph();
    final fromContent = read(from).toParagraph();

    expect(fromContent, equals(toContent));
  });

  test('copy filename to directory -  the good path', () async {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename)..append('Hellow World');

    final to = join(root, 'to');
    final toFilename = join(root, fromFilename);
    createDir(to, recursive: true);

    copy(from, to);

    expect(exists(from), isTrue);

    expect(exists(toFilename), isTrue);

    final toContent = read(toFilename).toParagraph();
    final fromContent = read(from).toParagraph();

    expect(fromContent, equals(toContent));
  });

  test("copy filename -  from doesn't exist", () async {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename);

    final to = join(root, 'to');
    createDir(to, recursive: true);

    expect(
        () => copy(from, to),
        throwsA(predicate((e) =>
            e is CopyException &&
            e.message == 'The from file ${truepath(from)} does not exists.')));
  });

  test('copy filename -  to already exists', () async {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename)..append('Hellow World');

    const toFilename = 'text2.txt';
    final to = join(root, toFilename);

    touch(to, create: true);

    expect(
        () => copy(from, to),
        throwsA(predicate((e) =>
            e is CopyException &&
            e.message == 'The target file ${truepath(to)} already exists.')));
  });

  test('copy with overwrite', () async {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename)..append('Hellow World');

    const toFilename = 'text2.txt';
    final to = join(root, toFilename);

    /// the 'to' file aready exists
    touch(to, create: true);

    expect(exists(to), isTrue);

    copy(from, to, overwrite: true);

    expect(exists(from), isTrue);

    expect(exists(to), isTrue);

    final toContent = read(to).toParagraph();
    final fromContent = read(from).toParagraph();

    expect(fromContent, equals(toContent));
  });

  test("copy to filename -  to directory doesn't exist", () async {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename)..append('Hellow World');

    const toFilename = 'text2.txt';
    final to = join(root, 'new', toFilename);

    expect(
        () => copy(from, to),
        throwsA(predicate((e) =>
            e is CopyException &&
            e.message ==
                'The to directory ${truepath(dirname(to))} does not exists.')));
  });

  test("copy to directory -  to directory doesn't exist", () async {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename)..append('Hellow World');

    final to = join(root, 'new', 'new');

    expect(
        () => copy(from, to),
        throwsA(predicate((e) =>
            e is CopyException &&
            e.message ==
                'The to directory ${truepath(dirname(to))} does not exists.')));
  });
}

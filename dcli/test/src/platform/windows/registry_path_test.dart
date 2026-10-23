import 'package:dcli/src/platform/windows/registry_path.dart';
import 'package:test/test.dart';

void main() {
  late String value;
  late int writes;
  late int notifications;
  late RegistryPath path;

  setUp(() {
    value = r'%USERPROFILE%\bin;C:\existing';
    writes = 0;
    notifications = 0;
    path = RegistryPath(
      read: () => value,
      write: (next) {
        writes++;
        value = next;
      },
      notify: () => notifications++,
    );
  });

  for (final prepend in [false, true]) {
    test('${prepend ? "prepend" : "append"} ignores duplicate entries', () {
      final original = value;
      final update = prepend ? path.prepend : path.append;
      update(r'C:\TestDirB');
      expect(
        value,
        prepend ? 'C:\\TestDirB;$original' : '$original;C:\\TestDirB',
      );
      final updated = value;
      update(r'C:\TestDirB');
      update(r'C:\TestDirB\..\TestDirB');
      expect(value, updated);
      expect(writes, 1);
      expect(notifications, 1);
      expect(path.contains(r'C:\TestDirB'), isTrue);
      expect(path.contains(r'C:\absent'), isFalse);
      path.replace(original.split(';'));
      expect(value, original);
      expect(writes, 2);
      expect(notifications, 2);
    });
  }

  test('replace preserves unexpanded entries and empty segments', () {
    path.replace([r'%USERPROFILE%\bin', '', r'C:\with spaces', '']);
    expect(value, r'%USERPROFILE%\bin;;C:\with spaces;');
    expect(notifications, 1);
  });

  test('failed write does not broadcast an environment change', () {
    final original = value;
    path = RegistryPath(
      read: () => value,
      write: (_) => throw StateError('simulated write failure'),
      notify: () => notifications++,
    );
    expect(() => path.append(r'C:\new'), throwsStateError);
    expect(value, original);
    expect(notifications, 0);
  });
}

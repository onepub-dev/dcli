import 'dart:async';
import 'dart:io';

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

void main() {
  test('line file ...', () async {
    await withTempFile<void>((file) async {
      final buffer = <String>[];
      final done = Completer<bool>();

      final src = File(file).openWrite();
      for (var i = 0; i < 1000; i++) {
        src.writeln('line $i');
      }
      await src.close();

      await withOpenLineFile(file, (file) async {
        late final StreamSubscription<String>? sub;
        try {
          sub = file.readAll().listen((line) async {
            sub!.pause();
            buffer.add(line);
            sub.resume();
          }, onDone: () => done.complete(true));
          await done.future;
        } finally {
          if (sub != null) {
            await sub.cancel();
          }
        }
      });

      expect(buffer.length, equals(1000));
    });
  });
}

import 'dart:async';

import 'package:dcli_core/dcli_core.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  test('settings ...', () async {
    await Settings().setVerbose(enabled: true);
    late var logged = Completer<bool>();

    final lines = <String>[];
    final dcliLogger = Logger('dcli');
    dcliLogger.onRecord.listen((record) {
      lines.add(record.message);
      logged.complete(true);
    });

    logged = Completer<bool>();
    verbose(() => 'test callback');
    await logged.future;
    expect(lines.length == 1, isTrue);
    expect(lines[0], equals('settings.dart:13 test callback'));

    logged = Completer<bool>();
    Settings().verbose('test message');
    await logged.future;
    expect(lines.length == 2, isTrue);
    expect(lines[2], equals('settings.dart:13 test message'));
  });
}

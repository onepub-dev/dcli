import 'dart:async';

import 'package:dcli_core/dcli_core.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
void main() {
  test('settings ...', () async {
    Settings().setVerbose(enabled: true);
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
    final pathToMe = join('test', 'src', 'settings_test.dart');
    expect(lines[0], equals('$pathToMe:22 test callback'));

    logged = Completer<bool>();
    Settings().verbose('test message');
    await logged.future;
    expect(lines.length == 2, isTrue);
    expect(lines[1], equals('$pathToMe:29 test message'));
  });
}

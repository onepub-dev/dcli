import 'package:dcli/dcli.dart';

void main(List<String> args) {
  Settings().setVerbose(enabled: true);
  try {
    'wmic process get processid,parentprocessid,executablepath'.run;

    final processes =
        'wmic process get processid,parentprocessid,executablepath'
            .toList(skipLines: 1);
    print(processes.join('\n'));
  } on FormatException catch (e, st) {
    print('message: ${e.message}');
    print('offset: ${e.offset}');
    print('source: ${e.source}');
    print(st);
    // ignore: avoid_catches_without_on_clauses
  } catch (e, st) {
    print(e.toString());
    print(st);
  }
}

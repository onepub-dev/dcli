import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final ls = await start('ls');
  final head = await start('head');
  final tail = await start('tail');

  var cnt = 0;
  await ls.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map((line) => '${++cnt}: $line\n')
      .transform(utf8.encoder)
      .pipe(head.stdin)
      //ignore: avoid_types_on_closure_parameters
      .catchError((Object e, StackTrace s) async {
    print('head exit: ${await head.exitCode}');
  },
          test: (e) =>
              e is SocketException &&
              e.osError!.errorCode == 32 // broken  pipe'
          );

  await head.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map((line) => 'tail: $line\n')
      .transform(utf8.encoder)
      .pipe(tail.stdin)
      //ignore: avoid_types_on_closure_parameters
      .catchError((Object e, StackTrace s) async {
    print('tail exit: ${await tail.exitCode}');
  }, test: (e) => e is SocketException && e.osError!.message == 'Broken pipe');

  await tail.stdout.pipe(stdout);
}

Future<Process> start(String command) async {
  final process = Process.start(
    command,
    [],
  );
  return process;
}

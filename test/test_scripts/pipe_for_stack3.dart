import 'dart:async';
import 'dart:convert';
import 'dart:io';

void main() async {
  //var ls = await start('ls');
  // var head = await start('head', ['-n', '10']);
  // var tail = await start('tail', ['-n' '3']);

  var head = await start('echo', ['-n', '10']);
  var tail = await start('tail', ['-n' '3']);
  run(
    generateLines(1000),
    head,
    tail,
  );
}

void run(Stream<String> ls, Process head, Process tail) {
  var cnt = 0;
  var fls = ls
      .transform(const LineSplitter())
      .map((line) => '${++cnt}: $line\n')
      .transform(utf8.encoder)
      .pipe(head.stdin)
      .catchError((Object e, StackTrace s) async {
    print('head exit: ${await head.exitCode}');
  },
          test: (e) =>
              e is SocketException && e.osError.errorCode == 32 // broken  pipe'
          );

  var fhead = head.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map((line) => 'tail: $line\n')
      .transform(utf8.encoder)
      .pipe(tail.stdin)
      .catchError((Object e, StackTrace s) async {
    print('tail exit: ${await tail.exitCode}');
  }, test: (e) => e is SocketException && e.osError.message == 'Broken pipe');

  var ftail = tail.stdout.pipe(stdout);

  Future.wait<void>([fls, fhead, ftail]);
}

Future<Process> start(String command, List<String> args) async {
  var process = Process.start(
    command,
    args,
  );
  return process;
}

Stream<String> generateLines(int to) async* {
  for (var i = 0; i < to; i++) {
    print('gen $i');
    yield 'generated($i)\n';
  }
}

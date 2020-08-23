import 'dart:async';
import 'dart:convert';
import 'dart:io';

void main() async {
  var ls = await start('ls', []);
  var head = await start('head', ['-n', '5']);

  var cnt = 1;
  await ls.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map((line) {
        print(line);
        return '${cnt++}: $line';
      })
      .transform(utf8.encoder)
      .pipe(head.stdin);

  //await head.stdout.transform(streamTransformer).pipe(stdout);
}

Future<Process> start(String command, List<String> args) async {
  var process = Process.start(
    command,
    args,
  );
  return process;
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

void main() async {
  var ls = await start('ls');
  var head = await start('head');

	ls.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map((line) => '1: $line\n')
      .transform(utf8.encoder)
      .pipe(head.stdin);

  await head.stdout.pipe(stdout);
}

Future<Process> start(String command) async {
  var process = Process.start(
    command,
    [],
  );
  return process;
}


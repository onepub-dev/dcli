import 'dart:async';
import 'dart:io';
import 'dart:convert';

extension on String {
  Future<Stream<String>> get run async {
    StreamController<String> _controller = StreamController<String>();

    List<String> parts = this.split(" ");
    String cmd = parts[0];
    List<String> args = List();

    if (parts.length > 1) {
      args = parts.sublist(1);
    }

    print("${Directory.current}");

    print("cmd $cmd args: $args");

    Completer<bool> done = Completer<bool>();
    await Process.start(cmd, args, runInShell: true)
        .then((Process process) async {
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((data) {
        //print("adding $data");
        _controller.add(data);
      });

      process.exitCode.then((exitCode) {
        done.complete(true);
      });
      // process.stdin.writeln('Hello, world!');
      // process.stdin.writeln('Hello, galaxy!');
      // process.stdin.writeln('Hello, universe!');
    });

    await done;

    return Future.value(_controller.stream);
  }

  Future<Stream<String>> operator |(IOSink next) {
    this.run.then((stream) {
      next.addStream(stream);
      // next.then<Stream<String>>((nextStream) {
      //   stream.pipe(nextStream.asStream());
      // });
    });
  }
}

void main() {
  'cat pubspec.lock'.run.then((stream) {
    stream.listen((data) {
      print("listner $data");
    });

    ///'cat pubspec.lock' | 'head'.run;
  });
}

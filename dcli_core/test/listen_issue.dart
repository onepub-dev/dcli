import 'dart:async';

Future<void> main() async {
  final controller = StreamController<String>();
  late StreamSubscription<String> sub;
  final streamCompleter = Completer<void>();
  try {
    sub = controller.stream.listen((item) async {
      // sub.pause();
      await _doSomethingAsync(item);
      //  sub.resume();
    }, onDone: () {
      streamCompleter.complete();
      print('stream onDone');
    });

    for (var i = 0; i < 10; i++) {
      controller.sink.add('Line $i');
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    print('for complete');
  } finally {
    await streamCompleter.future;
    print('stream complete');
    await sub.cancel();
    await controller.sink.close();

    await controller.close();
  }
  print('finished');
}

Future<void> _doSomethingAsync(String item) async {
  print(item);
  await Future.value(1);
  await Future<void>.delayed(const Duration(milliseconds: 100));
}

/// test summing a stream.
Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;
  await for (final value in stream) {
    sum += value;
  }
  return sum;
}

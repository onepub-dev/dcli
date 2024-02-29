import 'dart:async';

void main() async {
  // Create a StreamController
  final controller = StreamController<int>();

  final done = Completer<void>();

  // Add some data to the stream (before listening)
  controller.add(1);
  controller.add(2);
  controller.add(3);

  // Listen to the stream
  controller.stream.listen(
    (data) {
      print('Received: $data');
    },
    onDone: () {
      print('Stream closed');
      done.complete();
    },
    onError: (error) {
      print('Error: $error');
    },
    cancelOnError: true,
  );

  // Add more data to the stream (after listening)
  controller.add(4);
  controller.add(5);

  await done.future;

  // Close the stream
  await controller.close();
}

import 'package:native_synchronization_temp/native_synchronization.dart';

import 'message.dart';
import 'process_in_isolate.dart';

extension MailBoxMessage on Mailbox {
  Future<void> postMessage(Message message) async {
    var delay = const Duration(milliseconds: 1);
    var lastLog = DateTime.fromMillisecondsSinceEpoch(0); // track last log time
    const logInterval = Duration(seconds: 10);

    for (;;) {
      try {
        put(message.content);
        return;
      } on MailBoxFullException {
        // log first event and then at most once every 10 s
        final now = DateTime.now();
        if (now.difference(lastLog) >= logInterval) {
          isolateLogger(() => 'Mailbox is full; backing off');
          lastLog = now;
        }

        // exponential back-off with small jitter
        await Future.delayed(
          delay + Duration(microseconds: DateTime.now().microsecond % 500),
          () {},
        );
        final nextMs = (delay.inMilliseconds * 2).clamp(1, 8); // 1→2→4→8 ms
        delay = Duration(milliseconds: nextMs);
      } on MailBoxClosedException catch (e) {
        isolateLogger(() => 'MailBoxClosedException on postMessage $e');
        rethrow;
      }
    }
  }
}

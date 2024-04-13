import 'package:native_synchronization/mailbox.dart';

import 'message.dart';
import 'process_in_isolate2.dart';

extension MailBoxMessage on Mailbox {
  Future<void> postMessage(Message message) async {
    var tryPut = true;
    while (tryPut) {
      try {
        tryPut = false;
        // _logMessage('attempting to put message in mailbox $message');
        put(message.content);
        // _logMessage('attempting to put message in mailbox - success');
        // ignore: avoid_catching_errors
      } on StateError catch (e) {
        if (e.message == 'Mailbox is full') {
          _logMessage('mailbox is full sleeping for a bit');
          tryPut = true;

          /// yeild and give the mailbox read a chance to empty
          /// the mailbox.
          await Future.delayed(const Duration(seconds: 3), () {});
          _logMessage('woke from mailbox little put sleep.');
        } else {
          _logMessage('StateError on postMesage $e');
        }
      }
    }
  }
}

void _logMessage(String message) {
  if (debugIsolate) {
    print('postMessage: $message');
  }
}

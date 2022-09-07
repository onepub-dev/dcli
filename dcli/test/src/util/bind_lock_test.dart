/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';

const port = 63424;

Future<void> main() async {
  await _bindSocket();
}

Future<RawServerSocket?> _bindSocket() async {
  RawServerSocket? socket;
  try {
    socket = await RawServerSocket.bind(
      '127.0.0.1',
      port,
    );
    print('bind succeeded');
    sleep(8);
    print('woke');
    await socket.close();
  } on SocketException catch (e) {
    /// no op. We expect this if the hardlock is already held.
    print('bind failed: $e');
  }
  return socket;
}

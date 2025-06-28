/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
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

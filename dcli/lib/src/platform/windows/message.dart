// backwards compatiblity issue.
// ignore_for_file: constant_identifier_names

/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

// required for backwards compatibility
const HWND_BROADCAST = 0xffff;

/// Send a message to all top level windows that an environment variable
/// has changed.
void broadcastEnvironmentChange() {
  final what = 'Environment'.toNativeUtf16();

  final pResult = calloc<Int32>();
  try {
    SendMessageTimeout(
      HWND(Pointer.fromAddress(HWND_BROADCAST)),
      WM_SETTINGCHANGE,
      const WPARAM(0),
      LPARAM(what.address),
      SMTO_ABORTIFHUNG,
      5000,
      pResult.cast(),
    );
  } finally {
    calloc
      ..free(what)
      ..free(pResult);
  }
}

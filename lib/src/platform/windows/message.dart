import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

// ignore: public_member_api_docs,constant_identifier_names
const int HWND_BROADCAST = 0xffff;

// ignore: public_member_api_docs,constant_identifier_names
const int SMTO_ABORTIFHUNG = 0x0002;

/// Send a message to all top level windows that an environment variable
/// has changed.
void broadcastEnvironmentChange() {
  final what = TEXT('Environment');

  final pResult = calloc<Int32>(1);
  try {
    SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, 0, what.address,
        SMTO_ABORTIFHUNG, 5000, pResult.cast());
  } finally {
    calloc..free(what)..free(pResult);
  }
}

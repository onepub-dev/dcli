/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:posix/posix.dart' as posix;

const _procPidTBsdInfo = 3;
const _maxCommandLength = 16;

final int Function(
  int pid,
  int flavor,
  int argument,
  Pointer<Void> buffer,
  int bufferSize,
)
_procPidInfo = DynamicLibrary.open('/usr/lib/libproc.dylib')
    .lookupFunction<
      Int32 Function(
        Int32 pid,
        Uint32 flavor,
        Uint64 argument,
        Pointer<Void> buffer,
        Int32 bufferSize,
      ),
      int Function(
        int pid,
        int flavor,
        int argument,
        Pointer<Void> buffer,
        int bufferSize,
      )
    >('proc_pidinfo');

/// Uses the POSIX null signal to determine whether [pid] exists.
bool isPosixProcessRunning(int pid) {
  try {
    posix.kill(pid, posix.Signal.none);
    return true;
  } on posix.PosixException catch (e) {
    if (e.code == posix.EPERM) {
      // The process exists, but we don't have permission to signal it.
      return true;
    }
    if (e.code == posix.ESRCH) {
      return false;
    }

    rethrow;
  }
}

/// Returns the macOS process creation time without spawning `ps`.
String? getMacOSProcessStartIdentity(int pid) {
  if (!Platform.isMacOS) {
    return null;
  }

  final info = calloc<_ProcBsdInfo>();
  try {
    final size = sizeOf<_ProcBsdInfo>();
    final bytesWritten = _procPidInfo(
      pid,
      _procPidTBsdInfo,
      0,
      info.cast(),
      size,
    );
    if (bytesWritten != size) {
      return null;
    }

    return 'macos:${info.ref.startTimeSeconds}:'
        '${info.ref.startTimeMicroseconds}';
  } finally {
    calloc.free(info);
  }
}

/// Mirrors Darwin's `proc_bsdinfo` from `<sys/proc_info.h>`.
base class _ProcBsdInfo extends Struct {
  @Array(12)
  external Array<Uint32> header;

  @Array(_maxCommandLength)
  external Array<Uint8> command;

  @Array(2 * _maxCommandLength)
  external Array<Uint8> name;

  @Array(6)
  external Array<Uint32> processDetails;

  @Uint64()
  external int startTimeSeconds;

  @Uint64()
  external int startTimeMicroseconds;
}

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../ffi/with_memory.dart';
import '../util/process_helper.dart';

/// Gets the process name for the given [processID] on
/// a Windows system.
/// @Throwing(UnsupportedError)
String getWindowsProcessName(int processID) {
  var name = '<unknown>';

  // Get a handle to the process.
  final hProcess = OpenProcess(
    PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
    false,
    processID,
  ).value;
  try {
    // Get the process name.
    if (hProcess.isValid) {
      withMemory<void, Pointer>(sizeOf<IntPtr>(), (phMod) {
        withMemory<void, Uint32>(sizeOf<Uint32>(), (pcbNeeded) {
          if (EnumProcessModules(
            hProcess,
            phMod,
            sizeOf<IntPtr>(),
            pcbNeeded,
          ).value) {
            withMemory<void, Utf16>(MAX_PATH * sizeOf<Uint16>(),
                (pszProcessName) {
              GetModuleBaseName(
                hProcess,
                HMODULE(phMod.value),
                PWSTR(pszProcessName),
                MAX_PATH,
              );

              name = pszProcessName.toDartString();
            });
          }
        });
      });
    }
  } finally {
    // Release the handle to the process.
    if (hProcess.isValid) {
      hProcess.close();
    }
  }
  return name;
}

/// Returns an identity derived from the creation time of [processID].
///
/// The identity changes when Windows reuses a process ID.
String? getWindowsProcessStartIdentity(int processID) {
  final hProcess = OpenProcess(
    PROCESS_QUERY_LIMITED_INFORMATION,
    false,
    processID,
  ).value;
  if (!hProcess.isValid) {
    return null;
  }

  final times = calloc<FILETIME>(4);
  try {
    final result = GetProcessTimes(
      hProcess,
      times,
      times + 1,
      times + 2,
      times + 3,
    );
    if (!result.value) {
      return null;
    }

    final creationTime =
        (times.ref.dwHighDateTime << 32) | times.ref.dwLowDateTime;
    return 'windows:$creationTime';
  } finally {
    calloc.free(times);
    hProcess.close();
  }
}

/// Returns the list of running processes on a Windows system.
/// This method has a hard coded limit of 2048 processes.
/// @Throwing(UnsupportedError)
List<ProcessDetails> getWindowsProcesses() {
  final processes = <ProcessDetails>[];
  // Get the list of process identifiers.

  withMemory<void, Uint32>(sizeOf<Uint32>() * 2048, (pProcesses) {
    withMemory<void, Uint32>(sizeOf<Uint32>(), (pReturned) {
      if (!EnumProcesses(
        pProcesses.cast(),
        sizeOf<Uint32>() * 2048,
        pReturned.cast(),
      ).value) {
        return;
      }
      // Calculate how many process identifiers were returned.
      final cProcesses = pReturned.value ~/ sizeOf<Uint32>();

      /// extrat the pids.
      for (var i = 0; i < cProcesses; i++) {
        final pid = (pProcesses + i).value;
        if (pid != 0) {
          processes.add(ProcessDetails(pid, getWindowsProcessName(pid), '0K'));
        }
      }
    });
  });

  return processes;
}

// int getWindowsParentPid(int pid)
// {
//     HANDLE h = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
//     PROCESSENTRY32 pe = { 0 };
//     pe.dwSize = sizeof(PROCESSENTRY32);

//     //assume first arg is the PID to get the PPID for, or use own PID
//     if (argc > 1) {
//         pid = atoi(argv[1]);
//     } else {
//         pid = GetCurrentProcessId();
//     }

//     if( Process32First(h, &pe)) {
//         do {
//             if (pe.th32ProcessID == pid) {
//                 printf("PID: %i; PPID: %i\n", pid, pe.th32ParentProcessID);
//             }
//         } while( Process32Next(h, &pe));
//     }

//     CloseHandle(h);
// }

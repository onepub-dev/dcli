// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../../util/exceptions.dart';

/// Internal class used to make calls to native dart methods
/// We cache the native call sites to improve performance.
class NativeCalls {
  static SendPort connectToPort(Uint8List msg) {
    if (msg.length != 8) {
      throw ProcessSyncException('Wrong message: $msg');
    }
    final portId = msg.buffer.asInt64List()[0];

    return _connectToPort(portId) as SendPort;
  }

  // cache a pointer to the native connectToPort method.
  static final Object Function(int) _connectToPort = _initNativeConnectToPort();

  /// Don't really know why but we go and find the
  /// native dart method to connect to a port.
  static Object Function(int) _initNativeConnectToPort() {
    final functions =
        NativeApi.initializeApiDLData.cast<_DartApi>().ref.functions;

    late Object Function(int) connectToPort;
    for (var i = 0; functions[i].name != nullptr; i++) {
      if (functions[i].name.toDartString() == 'Dart_NewSendPort') {
        connectToPort = functions[i]
            .function
            .cast<NativeFunction<Handle Function(Int64)>>()
            .asFunction();
        break;
      }
    }
    return connectToPort;
  }
}

final class _DartApiEntry extends Struct {
  external Pointer<Utf8> name;
  external Pointer<Void> function;
}

final class _DartApi extends Struct {
  @Int()
  external int major;

  @Int()
  external int minor;

  external Pointer<_DartApiEntry> functions;
}

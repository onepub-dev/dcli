import 'dart:ffi';
// import 'dart:io' show Platform;

import 'package:dcli/dcli.dart';

/// Experimental code to allow a script ran by sudo to
/// deescalate priviliges and then escalate them as required.
///

// on systems with _POSIX_SAVED_IDS defined
typedef setEffectiveUID_func = Int32 Function(Uint32 effectiveUID);
typedef setEffectiveUID = int Function(int effectiveUID);

/// on other systems.
/// sets the effective and real uids.
typedef setUID_func = Int32 Function(Uint32 realUID, Uint32 effectiveUID);
typedef setUID = int Function(int realUID, int effectiveUID);

/// geteuid
typedef getEffectiveUID_func = Int32 Function();
typedef getEffectiveUID = int Function();

/// getreuid.
typedef getRealUID_func = Int32 Function();
typedef getRealUID = int Function();

void main() {
  // var priv = Priviliges();
  // priv.descalate();
  // priv.escalate();
  // priv.descalate();

  // print("I'm priviliged");

  // touch('/tmp/me.my', create: true);

  // // copy('/tmp/me.my', '/tmp/me.good', overwrite: true);
  // "cp '/tmp/me.my' '/tmp/me.good".run;
  // 'ls -la /tmp/me.*'.run;

  // print('effective: ${priv.effectiveUID}');
  // print('real: ${priv.realUID}');

  // print('descalating');
  // priv.descalate();

  // print('effective: ${priv.effectiveUID}');
  // print('real: ${priv.realUID}');

  // print('escalating');
  // priv.escalate();

  // print('effective: ${priv.effectiveUID}');
  // print('real: ${priv.realUID}');

  // priv.withPrivileges(() {
  print("I'm priviliged");

  touch('/tmp/somefile.txt', create: true);

  copy('/tmp/somefile.txt', '/tmp/otherfile.txt', overwrite: true);
  'ls -la /tmp/*.txt'.run;
  // });

  // print("I'm not privileged");

  // touch('/tmp/me.special.my', create: true);

  // copy('/tmp/me.special.my', '/tmp/my.special.good', overwrite: true);
  // 'ls -la /tmp/me.special.*'.run;
}

class Privileges {
  static final Privileges _self = Privileges._internal();

  DynamicLibrary? dylib;

  // the logged in user's original UID
  int? userUID;

  /// true if we are running under sudo.
  bool? sudo;

  /// I'm confused.
  int? realUID;

  /// The user's effective UID when the script started.
  /// If they are running as sudo then this will be root.
  int? originalEffectiveUID;

  /// Used to track what UID is currently in effect.
  int? currentEffectiveUID;

  factory Privileges() => _self;

  Privileges._internal() {
    // var path = 'libc.so.6';
    // if (Platform.isMacOS) path = '/usr/lib/libSystem.dylib';
    // if (Platform.isWindows) path = r'primitives_library\Debug\primitives.dll';
    // dylib = DynamicLibrary.open(path);

    // realUID = _realUID;

    // var sudo_uid = env['SUDO_UID'];
    // if (sudo_uid != null) {
    //   sudo = true;
    //   userUID = int.tryParse(sudo_uid);
    // } else {
    //   /// we aren't running sudo
    //   sudo = false;
    //   userUID = realUID;
    // }

    // originalEffectiveUID = _effectiveUID;
    // currentEffectiveUID = originalEffectiveUID;
  }

  /// If the script was started as sudo then any [task]
  /// run within in the scope of this call will be
  /// run with escalated privileges.
  ///
  /// If the script wasn't run as sudo then there will
  /// be no changes to their privildege level.
  // void withPrivileges(void Function() task) {
  //   escalate();
  //   task();
  //   descalate();
  // }

  // int get effectiveUID => currentEffectiveUID;

  // void escalate() {
  //   if (sudo && currentEffectiveUID == userUID) {
  //     print(green('escalate'));
  //     _effectiveUID = originalEffectiveUID;
  //     currentEffectiveUID = originalEffectiveUID;
  //     // _realUID = originalEffectiveUID;
  //   }
  // }

  // void descalate() {
  //   /// if the real and original is the same then they
  //   /// mustn't be running under sudo so we can't help them.
  //   if (sudo && currentEffectiveUID != userUID) {
  //     print(red('descalate'));
  //     _effectiveUID = userUID;
  //     // _realUID = userUID;
  //     currentEffectiveUID = userUID;
  //   }
  // }

  // int get _realUID {
  //   final getuidPointer =
  //       dylib.lookup<NativeFunction<getRealUID_func>>('getuid');
  //   final getuid = getuidPointer.asFunction<getRealUID>();

  //   int uid = getuid();
  //   print('get real guid=$uid');
  //   return uid;
  // }

  // set _realUID(int realUID) {
  //   final setuidPointer = dylib
  //    .lookup<NativeFunction<setUID_func>>('setreuid');
  //   final setuid = setuidPointer.asFunction<setUID>();

  //   print(blue('settting realUID =$realUID'));
  //   var result = setuid(realUID, -1);
  //   if (result != 0) {
  //     throw PriviligesException('Unable to set the Effective UID: $result');
  //   }
  // }

  // int get _effectiveUID {
  //   final geteuidPointer =
  //       dylib.lookup<NativeFunction<getEffectiveUID_func>>('geteuid');
  //   final geteuid = geteuidPointer.asFunction<getEffectiveUID>();
  //   var uid = geteuid();

  //   print('get effiective guid=$uid');
  //   return uid;
  // }

  // set _effectiveUID(int effectiveUID) {
  //   print('setting effective to $effectiveUID');
  //   var result = -1;
  //   try {
  //     final seteuidPointer =
  //         dylib.lookup<NativeFunction<setEffectiveUID_func>>('seteuid');
  //     final seteuid = seteuidPointer.asFunction<setEffectiveUID>();

  //     print(blue('settting effectiveUID =$effectiveUID'));
  //     result = seteuid(effectiveUID);
  //   } on ArgumentError catch (_) {
  //     // seteuid isn't available so lets try setreuid

  //     final setreuidPointer =
  //         dylib.lookup<NativeFunction<setUID_func>>('setreuid');
  //     final setreuid = setreuidPointer.asFunction<setUID>();
  //     result = setreuid(-1, effectiveUID);
  //   }

  //   if (result != 0) {
  //     throw PriviligesException('Unable to set the Effective UID: $result');
  //   }
  // }
}

class PriviligesException extends DCliException {
  PriviligesException(String message) : super(message);
}

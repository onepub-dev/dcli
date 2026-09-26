import 'dart:convert';

/// Generates a dependency-free Dart launcher to compile to a native executable.
String nativeLauncherSource(String executableName) => _source.replaceFirst(
  '__ENTRYPOINT__',
  // JSON strings are Dart strings too, except that Dart interpolates dollars.
  jsonEncode(executableName).replaceAll(r'$', r'\$'),
);

const _source = r'''
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

const entrypoint = __ENTRYPOINT__;

Future<void> main(List<String> args) async {
  final launcher = File(Platform.resolvedExecutable);
  var name = launcher.uri.pathSegments.last;
  if (Platform.isWindows && name.toLowerCase().endsWith('.exe')) {
    name = name.substring(0, name.length - 4);
  }
  final executable = File.fromUri(launcher.parent.uri.resolveUri(
    Uri(pathSegments: ['.$name.bundle', 'bin', entrypoint]),
  )).path;
  if (!File(executable).existsSync()) {
    stderr.writeln('Missing application bundle: $executable');
    stderr.writeln('Keep the launcher and .$name.bundle directory together.');
    exit(127);
  }
  if (Platform.isWindows) {
    try {
      final process = await Process.start(executable, args,
          mode: ProcessStartMode.inheritStdio);
      exit(await process.exitCode);
    } on ProcessException catch (error) {
      stderr.writeln('Unable to launch $executable: $error');
      exit(126);
    }
  }

  // execv preserves the PID, environment, working directory, terminal, and
  // signal/exit behavior. No shell or resident forwarding process is needed.
  final libc = DynamicLibrary.process();
  final malloc = libc.lookupFunction<Pointer<Void> Function(Size),
      Pointer<Void> Function(int)>('malloc');
  final free = libc.lookupFunction<Void Function(Pointer<Void>),
      void Function(Pointer<Void>)>('free');
  final execv = libc.lookupFunction<
      Int32 Function(Pointer<Uint8>, Pointer<Pointer<Uint8>>),
      int Function(Pointer<Uint8>, Pointer<Pointer<Uint8>>)>('execv');
  final allocations = <Pointer<Void>>[];
  Pointer<Void> allocate(int bytes) {
    final pointer = malloc(bytes);
    if (pointer == nullptr) throw StateError('Unable to allocate launcher args');
    allocations.add(pointer);
    return pointer;
  }
  try {
    final arguments = [executable, ...args];
    final argv = allocate((arguments.length + 1) * sizeOf<Pointer<Uint8>>())
        .cast<Pointer<Uint8>>();
    for (var i = 0; i < arguments.length; i++) {
      final bytes = utf8.encode(arguments[i]);
      final string = allocate(bytes.length + 1).cast<Uint8>();
      string.asTypedList(bytes.length + 1)
        ..setAll(0, bytes)
        ..[bytes.length] = 0;
      argv[i] = string;
    }
    argv[arguments.length] = nullptr;
    execv(argv[0], argv);
    // A successful execv never returns.
    stderr.writeln('Unable to launch $executable');
    exitCode = 126;
  } finally {
    for (final allocation in allocations) {
      free(allocation);
    }
  }
}
''';

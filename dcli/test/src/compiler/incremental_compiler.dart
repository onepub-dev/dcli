// import 'dart:async';
// import 'dart:io' show Platform, Process, stdin;

// import 'package:dcli/dcli.dart';
// import 'package:frontend_server_client/frontend_server_client.dart'
//     show FrontendServerClient;
// import 'package:path/path.dart' as path;
// import 'package:stack_trace/stack_trace.dart' show Trace;
// import 'package:watcher/watcher.dart' show WatchEvent, Watcher;

// const String _platformDill = 'lib/_internal/vm_platform_strong.dill';

// /// Incremental compiler used
// /// by dcli compile --watch
// class IncrementalCompiler {
//   ///
//   IncrementalCompiler(this._pathToLibrary) {
//     _fileUri = Uri.file(_pathToLibrary);

//     _outputDill = path.join('.dart_tool', 'incremental_build.dill');
//   }

//   final String _pathToLibrary;

//   final _invalidated = <Uri>{};

//   late final Uri _fileUri;

//   late final String _outputDill;

//   late final FrontendServerClient _client;

//   /// Watch for file changes in the dart script
//   /// and re-compile it.
//   Future<void> watch() async {
//     final _executable = Platform.resolvedExecutable;
//     final _sdkRoot = path.dirname(path.dirname(_executable));

//     _client = await FrontendServerClient.start(
//         _pathToLibrary, _outputDill, _platformDill,
//         sdkRoot: _sdkRoot);

//     print('Watching $_pathToLibrary');

//     await _compile();
//     await _startFileWatch(_invalidated, const Duration(seconds: 1));

//     await _menu();
//   }

//   Future<void> _startFileWatch(Set<Uri> invalidated,
//       [Duration? pollingDelay]) async {
//     final root = DartProject.self.pathToProjectRoot;

//     print('started os watcher on $root');

//     final watcher = Watcher(root, pollingDelay: pollingDelay); // was lib

//     var waitForChanges = Timer(const Duration(seconds: 2), () {});
//     watcher.events.listen((event) {
//       if (!_excluded(event)) {
//         print(event);
//         invalidated.add(Uri.file(event.path));

//         // we wait at least 2 seconds for other file changes to
//         // come in before we start a compile.
//         waitForChanges.cancel();
//         waitForChanges = Timer(const Duration(seconds: 2), _compile);
//       }
//     });

//     return watcher.ready;
//   }

//   Future<void> _run(String pathToDill) async {
//     try {
//       print('generated $pathToDill');

//       final result = await Process.run(DartSdk().pathToDartExe!,
//          [pathToDill]);

//       if (result.stdout != null) {
//         print(result.stdout.toString().trimRight());
//       }

//       if (result.stderr != null) {
//         print(result.stderr);
//       }
//       // ignore: avoid_catches_without_on_clauses
//     } catch (error, trace) {
//       print(error);
//       print(Trace.format(trace));
//     }
//   }

//   Future<void> _compile({bool runAfter = true}) async {
//     print('compiling');
//     try {
//       final result = await _client.compile([_fileUri, ..._invalidated]);
//       _invalidated.clear();

//       if (result == null) {
//         print('no compilation result, rejecting');
//         return _client.reject();
//       }

//       if (result.errorCount > 0) {
//         print('compiled with ${result.errorCount} error(s)');
//         return _client.reject();
//       }

//       result.compilerOutputLines.forEach(print);

//       _client
//         ..accept()
//         ..reset();

//       print('recompiled...');
//       if (runAfter) {
//         await _run(_outputDill);
//       }
//       // ignore: avoid_catches_without_on_clauses
//     } catch (error, trace) {
//       print(error);
//       print(Trace.format(trace));
//     }
//   }

//   Future<void> _menu() async {
//     // ask('Print r to reload, q to quit, h for help',
//     //     validator: Ask.inList(['r', 'q', 'h']));
//     stdin.echoMode = false;
//     stdin.lineMode = false;

//     print('Print r to reload, q to quit, h for help');
//     final done = Completer<void>();
//     stdin.listen((bytes) async {
//       switch (bytes[0]) {
//         // r
//         case 114:
//           print('reloading...');
//           await _compile();
//           break;
//         // q
//         case 113:
//           done.complete();
//           //exit(0);
//           break;
//         // h
//         case 104:
//           print('usage: press r to reload and q to exit');
//           break;
//         default:
//       }
//     });

//     await done.future;
//   }

//   static const _excludedDirs = ['.dart_tool', '.git'];
//   bool _excluded(WatchEvent event) {
//     var excluded = false;
//     for (final excludedDir in _excludedDirs) {
//       if (event.path.contains(excludedDir)) {
//         excluded = true;
//       }
//     }
//     return excluded;
//   }
// }
// // ignore_for_file: avoid_print

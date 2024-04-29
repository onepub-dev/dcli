/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

// import '../../dcli.dart';
// import 'runnable_process.dart';

// ignore: dangling_library_doc_comments
/// used to pipe date from one proces to another.
// class Pipe {
//   ///
//   Pipe(this._lhs, this._rhs) {
//     _lhs.pipeTo(_rhs);
//   }

//   ///
//   Pipe operator |(String next) {
//     final pNext = RunnableProcess.fromCommandLine(next)
//       ..start(waitForStart: false);
//     return Pipe(_rhs, pNext);
//   }

//   final RunnableProcess _lhs;
//   final RunnableProcess _rhs;

//   ///
//   void forEach(LineAction stdout, {LineAction stderr = _noOpAction}) {
//     final progress = Progress(stdout, stderr: stderr);
//     _rhs.processUntilExit(progress, nothrow: false);
//   }

//   ///
//   List<String?> toList() {
//     final list = <String?>[];

//     forEach(list.add, stderr: list.add);

//     return list;
//   }

//   // void get run => rhs
//   //     .processUntilExit(Progress(Progress.devNull
//   //  , stderr: Progress.devNull));

//   /// pumps data trough the pipe.
//   void get run =>
//       _rhs.processUntilExit(Progress(print, stderr: print), nothrow: false);
// }

// void _noOpAction(String line) {}

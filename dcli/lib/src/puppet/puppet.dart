// or Interact
import 'dart:async';
import 'dart:collection';
import 'dart:io';

import '../../dcli.dart';
import 'stdin.dart';
import 'stdout.dart';

class Puppet<T> {
  Puppet({required this.spawn}) {
    _finalizer
      ..attach(_stdout, _stdout, detach: _stdout)
      ..attach(_stderr, _stderr, detach: _stderr);
  }

  /// use a finalizer to ensure _stdout and _stderr are cleanedup
  static final Finalizer<PuppetStdout> _finalizer =
      Finalizer((sink) => sink.close());

  Future<T> Function() spawn;

  final actionQueue = Queue<_Action>();

  final _stdin = PuppetStdin();
  // ignore: close_sinks
  final _stdout = PuppetStdout();
  // ignore: close_sinks
  final _stderr = PuppetStdout();

  T run() => IOOverrides.runZoned<T>(
        // ignore: discarded_futures
        () => waitForEx(_runActions()),
        stdin: () => _stdin,
        stdout: () => _stdout,
        stderr: () => _stderr,
      );

  Future<T> _runActions() async {
    final done = Completer<T>();

    await spawn().then(done.complete);

    for (final action in actionQueue) {
      action.run();
    }

    return done.future;
  }

  void expect(String expected, {void Function()? action}) {
    actionQueue.add(_ExpectAction(this, expected, action));
  }

  void send(String line, {void Function()? action}) {
    actionQueue.add(_SendAction(this, line, action));
  }
}

// ignore: one_member_abstracts
abstract class _Action {
  void run();
}

class _ExpectAction<T> extends _Action {
  _ExpectAction(this.puppet, this.expected, this.action);

  Puppet<T> puppet;
  String expected;
  void Function()? action;

  @override
  void run() {
    final line = puppet._stdout.readLineSync();
    if (line == expected) {
      action?.call();
    } else {
      throw PuppetException('Expected $expected, received $line');
    }
  }
}

class _SendAction<T> extends _Action {
  _SendAction(this.puppet, this.send, this.action);

  Puppet<T> puppet;
  String send;
  void Function()? action;

  @override
  void run() {
    puppet._stdin.writeLineSync(send);
    action?.call();
  }
}

class PuppetException extends DCliException {
  PuppetException(super.message);
}

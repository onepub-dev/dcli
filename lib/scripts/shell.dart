import 'dart:async';
import 'dart:cli';
import 'dart:convert';
import 'dart:io';

import 'package:file_utils/file_utils.dart';
import 'package:path/path.dart' as p;

import '../stack_list.dart';
import '../util/log.dart';

StackList<Directory> directoryStack = StackList();

bool _debug_on = false;
set set_debug_on(bool on) => _debug_on = on;

void mv(String from, String to) {
  File(from).renameSync(to);

  if (_debug_on) {
    Log.d("mv ${p.absolute(from)} -> ${p.absolute(to)}");
  }
}

String get pwd {
  return Directory.current.path;
}

void echo(String text) {
  print(text);
}

void cd(String path) {
  if (_debug_on) {
    Log.d("cd $path -> ${p.absolute(path)}");
  }
  Directory.current = path;
}

List<String> get fileList {
  List<String> files = List();

  if (_debug_on) {
    Log.d("fileList pwd: ${p.absolute(pwd)}");
  }

  Directory.current.listSync().forEach((file) => files.add(file.path));
  return files;
}

///
/// Returns the list of files in the cwd that
/// match the passed glob pattern.
///
List<String> find(String pattern,
    {bool caseSensitive = false,
    bool recursive = true,
    String root = ".",
    List<FileSystemEntityType> types = const [FileSystemEntityType.file]}) {
  List<String> files = List();

  if (_debug_on) {
    Log.d(
        "find: ${p.absolute(root)} pattern: ${pattern} caseSensitive: ${caseSensitive} recursive: ${recursive} types: ${types} ");
  }

  try {
    push(root);

    // scan current directory for files
    FileUtils.glob(pattern, caseSensitive: caseSensitive, notify: (path) {
      FileSystemEntityType type = FileSystemEntity.typeSync(path);
      if (types.contains(type)) {
        files.add(path);
      }
    });

    if (recursive) {
      fileList.forEach((path) {
        FileSystemEntityType type = FileSystemEntity.typeSync(path);

        if (type == FileSystemEntityType.directory) {
          // recursive call to find.
          List<String> found = find(pattern,
              caseSensitive: caseSensitive,
              recursive: recursive,
              root: path,
              types: types);

          files.addAll(found);

          if (_debug_on) {
            Log.d("find: found ${found.length}");
          }
        }
      });
    }
  } finally {
    pop();
  }
  return files;
}

void touch(String path, {bool create = true}) {
  if (_debug_on) {
    Log.d("touch: ${p.absolute(path)} create: $create");
  }
  FileUtils.touch([path], create: true);
}

////
/// Push the pwd onto the stack and change the
/// current directory to [path].
void push(String path) {
  if (_debug_on) {
    Log.d("push: new -> ${p.absolute(path)}");
  }
  directoryStack.push(Directory.current);
  Directory.current = path;
}

///
/// Change the working directory back
/// to its location before [push] was called.
void pop() {
  String path = directoryStack.pop().path;

  if (_debug_on) {
    Log.d("pop:  new -> ${p.absolute(path)}");
  }

  Directory.current = path;
}

void mkdir(String path, {bool createPath}) {
  if (_debug_on) {
    Log.d("mkdir:  ${p.absolute(path)} createPath: $createPath");
  }
  Directory(path).createSync(recursive: createPath);
}

bool isFile(String path) {
  FileSystemEntityType fromType = FileSystemEntity.typeSync(path);
  return (fromType == FileSystemEntityType.file);
}

/// true if the given path is a directory.
bool isDirectory(String path) {
  FileSystemEntityType fromType = FileSystemEntity.typeSync(path);
  return (fromType == FileSystemEntityType.directory);
}

/// checks if the given [path] exists.
bool exists(String path) {
  return File(path).existsSync();
}

///
/// Reads user input from stdin and returns it as a string.
String read({String prompt}) {
  if (_debug_on) {
    Log.d("read:  ${prompt}");
  }
  if (prompt != null) {
    print(prompt);
  }
  var line = stdin.readLineSync(encoding: Encoding.getByName('utf-8'));

  if (_debug_on) {
    Log.d("read:  result ${line}");
  }

  return line;
}

/// Prints the contents of the give file to stdout.
///
void cat(String path) {
  File sourceFile = File(path);

  if (_debug_on) {
    Log.d("cat:  ${p.absolute(path)}");
  }

  waitFor<void>(sourceFile
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .forEach((line) => print(line)));
}

void rm(String path, {bool ask}) {
  if (_debug_on) {
    Log.d("rm:  ${p.absolute(path)} ask: $ask");
  }

  bool remove = true;
  if (ask) {
    remove = false;
    var yes = read(prompt: "rm: remove regular file '${path}'? y/N");
    if (yes == "y") {
      remove = true;
    }

    if (remove == true) {
      File(path).delete();
    }
  }
}

enum Interval { seconds, millseconds, minutes }

void sleep(int duration, {Interval interval = Interval.seconds}) {
  if (_debug_on) {
    Log.d("sleep: duration: ${duration} interval: $interval");
  }
  Duration _duration;
  switch (interval) {
    case Interval.seconds:
      _duration = Duration(seconds: duration);
      break;
    case Interval.millseconds:
      _duration = Duration(microseconds: duration);
      break;
    case Interval.minutes:
      _duration = Duration(minutes: duration);
      break;
  }

  waitFor<void>(Future.delayed(_duration));
}

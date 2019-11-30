import 'dart:io';
import 'package:dshell/util/log.dart';
import 'package:file/memory.dart';

import 'package:path/path.dart' as p;

class TestZone {
  MemoryFileSystem fs;

  TestZone() {
    final FileSystemStyle style = FileSystemStyle.posix;
    fs = MemoryFileSystem(style: style);
  }

  void run<R>(R body()) {
    IOOverrides.runZoned(body,
        createDirectory: (String path) => fs.directory(path),
        createFile: (String path) => fs.file(path),
        createLink: (String path) => fs.link(path),
        getCurrentDirectory: () => fs.currentDirectory,
        setCurrentDirectory: (String path) => fs.currentDirectory = path,
        getSystemTempDirectory: () => fs.systemTempDirectory,
        stat: (String path) => fs.stat(path),
        statSync: (String path) => fs.statSync(path),
        fseIdentical: (String p1, String p2) => fs.identical(p1, p2),
        fseIdenticalSync: (String p1, String p2) => fs.identicalSync(p1, p2),
        fseGetType: (String path, bool followLinks) =>
            fs.type(path, followLinks: followLinks),
        fseGetTypeSync: (String path, bool followLinks) =>
            fs.typeSync(path, followLinks: followLinks),
        fsWatch: (String a, int b, bool c) =>
            throw UnsupportedError('unsupported'),
        fsWatchIsSupported: () => fs.isWatchSupported);
  }
}

class VirtualFile {
  MemoryFileSystem mfs;
}

///

class VirtualFileSystem {
  Directory _current = VirtualDirectory(p.canonicalize("."));

  // The root directory of this virtual file system.
  String virtualRootPath;

  Set<String> paths = Set();
  VirtualFileSystem({String virtualRootPath = "/tmp"});

  Directory get current => _current;

  set current(Directory current) {
    _current = current;
    Log.d("DirectoryOverride current=" + current.path);
  }

  Directory createDir(String path) {
    paths.add(path);

    return VirtualDirectory(path);
  }

  FileSystemEntityType getTypeSync(String path, bool followLinks) {
    return FileSystemEntityType.file;
  }
}

class VirtualDirectory implements Directory {
  String _path;

  VirtualDirectory(String path) : _path = p.canonicalize(path);

  @override
  Directory get absolute => this;

  @override
  Future<Directory> create({bool recursive = false}) {
    return null;
  }

  @override
  void createSync({bool recursive = false}) {}

  @override
  Future<Directory> createTemp([String prefix]) {
    return null;
  }

  @override
  Directory createTempSync([String prefix]) {
    return null;
  }

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) {
    return null;
  }

  @override
  void deleteSync({bool recursive = false}) {}

  @override
  Future<bool> exists() {
    return null;
  }

  @override
  bool existsSync() {
    return null;
  }

  @override
  bool get isAbsolute => null;

  @override
  Stream<FileSystemEntity> list(
      {bool recursive = false, bool followLinks = true}) {
    return null;
  }

  @override
  List<FileSystemEntity> listSync(
      {bool recursive = false, bool followLinks = true}) {
    return null;
  }

  @override
  Directory get parent => null;

  @override
  String get path => _path;

  @override
  Future<Directory> rename(String newPath) {
    return null;
  }

  @override
  Directory renameSync(String newPath) {
    return null;
  }

  @override
  Future<String> resolveSymbolicLinks() {
    return null;
  }

  @override
  String resolveSymbolicLinksSync() {
    return null;
  }

  @override
  Future<FileStat> stat() {
    return null;
  }

  @override
  FileStat statSync() {
    return null;
  }

  @override
  Uri get uri => null;

  @override
  Stream<FileSystemEvent> watch(
      {int events = FileSystemEvent.all, bool recursive = false}) {
    return null;
  }
}

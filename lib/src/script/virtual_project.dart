import 'dart:io';
import 'package:dshell/src/functions/env.dart';
import 'package:dshell/src/functions/read.dart';
import 'package:dshell/src/script/commands/install.dart';
import 'package:dshell/src/util/ansi_color.dart';
import 'package:dshell/src/util/truepath.dart';
import 'package:dshell/src/util/with_lock.dart';
import 'package:path/path.dart';

import '../../dshell.dart';
import '../functions/is.dart';
import '../pubspec/pubspec.dart';
import '../pubspec/pubspec_file.dart';
import '../pubspec/pubspec_manager.dart';
import 'pub_get.dart';

import '../settings.dart';
import 'dart_sdk.dart';
import 'script.dart';

/// Creates project directory structure
/// All projects live under the dshell cache
/// directory are form a virtual copy of the
/// user's Script with the additional files
/// required by dart.
class VirtualProject {
  static const String PROJECT_DIR = '.project';

  /// If this file exists in the VirtualProject directory
  /// then the project is using a local pubspec.yaml
  /// and we don't need to build the virtual project.
  static const USING_LOCAL_PUBSPEC = '.using.local.pubspec';
  static const USING_VIRTUAL_PUBSPEC = '.using.virtual.pubspec';
  static const BUILD_COMPLETE = '.build.complete';
  final Script script;

  String _virtualProjectPath;

  // The absolute path to the scripts lib directory.
  // The script may not have a lib in which
  // case this directory wont' exist.
  String _scriptLibPath;

  String _projectLibPath;

  // A path to the 'Link' file in the project directory
  // that links to the actual script file.
  String _projectScriptLinkPath;

  String _projectPubspecPath;

  String _localPubspecIndicatorPath;

  String _virtualPubspecIndicatorPath;

  // The absolute path to the projects lib directory.
  // If the script lib exists then this will
  // be a link to that directory.
  // If the script lib doesn't exist then
  // on will be created under the virtual project directory.
  String get projectCacheLib => _projectLibPath;

  /// The  absolute path to the
  /// virtual project's project directory.
  /// This is this is essentially:
  /// join(Settings().dshellCache, dirname(script), PROJECT_DIR)
  ///
  // String get path => _virtualProjectPath;

  /// The path to the virtual projects pubspec.yaml
  /// e.g. PROJECT_DIR/pubspec.yaml
  String get projectPubspecPath => _projectPubspecPath;

  // String _projectPubSpecPath;

  // String _runtimeLibPath;

  // String _runtimeScriptPath;

  String _runtimePubspecPath;
  String _runtimePath;

  bool _isProjectInitialised = false;

  /// The location of the pubspec.yaml file that will
  /// be used when running the project.
  ///
  /// See: runtimePath for how this is determined.
  String get runtimePubSpecPath => _runtimePubspecPath;

  /// The directory the project will be run from.
  /// For a project with an actual pubspec.yaml this
  /// will be the directory the pubspec.yaml file lives
  /// in (the same directory as the script). For
  /// a project that requires a virtual pubspec.yaml
  /// this will be in the projects cache directory
  /// located under ~/.dshell/cache....
  ///
  String get runtimePath => _runtimePath;

  NamedLock lock;

  /// Creates a virtual project's directory
  /// and calls initialiseProject.
  /// The create does NOT build the project (i.e. call pub get)
  static VirtualProject create(Script script) {
    var dshellCachePath = Settings().dshellCachePath;
    var project = VirtualProject._internal(dshellCachePath, script);

    if (project.usingLocalPubspec) {
      // we don't need a virtual project as the script
      // is a full project in its own right.
      // why do we have two lib paths?
      setLocalPaths(project, script);
      project._usingLocalPubspec = true;
    } else {
      // we need a virtual pubspec.
      // project._runtimeLibPath = project._projectLibPath;

      // project._runtimeScriptPath = project._projectScriptLinkPath;

      setVirtualPaths(project);
      project._usingLocalPubspec = false;
    }

    project.initialiseProject();
    return project;
  }

  /// loads an existing virtual project.
  static VirtualProject load(Script script) {
    var dshellCachePath = Settings().dshellCachePath;
    var project = VirtualProject._internal(dshellCachePath, script);

    if (project.usingLocalPubspec) {
      // why do we have two lib paths?
      setLocalPaths(project, script);
    } else {
      setVirtualPaths(project);
    }

    return project;
  }

  static void setProjectPaths(VirtualProject project, Script script) {
    project._projectLibPath = join(project._virtualProjectPath, 'lib');

    project._scriptLibPath = join(script.path, 'lib');
    project._projectScriptLinkPath =
        join(project._virtualProjectPath, script.scriptname);
    project._projectPubspecPath =
        join(project._virtualProjectPath, 'pubspec.yaml');
  }

  static void setVirtualPaths(VirtualProject project) {
    setProjectPaths(project, project.script);

    project._runtimePubspecPath = project._projectPubspecPath;
    project._runtimePath = project._virtualProjectPath;
  }

  static void setLocalPaths(VirtualProject project, Script script) {
    // project._runtimeLibPath = join(script.path, 'lib');

    // project._runtimeScriptPath = script.path;
    setProjectPaths(project, script);

    project._runtimePubspecPath = join(dirname(script.path), 'pubspec.yaml');

    project._runtimePath = dirname(script.path);
  }

  bool _usingLocalPubspec;

  bool get usingLocalPubspec {
    _usingLocalPubspec ??=
        script.hasPubSpecYaml() && script.hasPubspecAnnotation;
    return _usingLocalPubspec;
  }

  VirtualProject._internal(String cacheRootPath, this.script) {
    // /home/bsutton/.dshell/cache/home/bsutton/git/dshell/test/test_scripts/hello_world.project
    _virtualProjectPath = join(cacheRootPath,
        script.scriptDirectory.substring(1), script.basename + PROJECT_DIR);

    _localPubspecIndicatorPath = join(_virtualProjectPath, USING_LOCAL_PUBSPEC);
    _virtualPubspecIndicatorPath =
        join(_virtualProjectPath, USING_VIRTUAL_PUBSPEC);

    _isProjectInitialised = exists(_virtualProjectPath) &&
        (exists(_localPubspecIndicatorPath) ||
            exists(_virtualPubspecIndicatorPath));

    lock = NamedLock(
        lockSuffix: 'virtual_project.lock',
        lockPath: dirname(_virtualProjectPath));
  }

  /// Creates the projects cache directory under the
  ///  root directory of our global cache directory - [cacheRootDir]
  ///
  /// The projec cache directory contains
  /// Link to script file
  /// Link to 'lib' directory of script file
  ///  or
  /// Lib directory if the script file doesn't have a lib dir.
  /// pubsec.yaml copy from script annotationf
  ///  or
  /// Link to scripts own pubspec.yaml file.
  /// hashes.yaml file.
  void initialiseProject() {
    lock.withLock(() {
      if (!exists(_virtualProjectPath)) {
        createDir(_virtualProjectPath, recursive: true);
        print('Created Virtual Project at ${_virtualProjectPath}');
      }

      if (usingLocalPubspec) {
        // create the indicator file so when we load
        // the virtual project we know its a local
        // pubspec without having to parse the script
        // for a pubspec annotation.
        if (exists(_virtualPubspecIndicatorPath)) {
          delete(_virtualPubspecIndicatorPath);
        }
        touch(_localPubspecIndicatorPath, create: true);

        // clean up any old files.
        // as the script may have changed from virtual to local.
        if (exists(_projectScriptLinkPath)) {
          delete(_projectScriptLinkPath);
        }

        if (exists(_projectLibPath)) {
          delete(_projectLibPath);
        }

        if (exists(_projectPubspecPath)) {
          delete(_projectPubspecPath);
        }
      } else {
        if (exists(_localPubspecIndicatorPath)) {
          delete(_localPubspecIndicatorPath);
        }
        touch(_virtualPubspecIndicatorPath, create: true);

        // create the files/links for a virtual pubspec.
        _createScriptLink(script);
        _createLib();
        PubSpecManager(this).createVirtualPubSpec();
      }
      _isProjectInitialised = true;
    });
  }

  /// We need to create a link to the script
  /// from the project cache.
  void _createScriptLink(Script script) {
    if (!exists(_projectScriptLinkPath, followLinks: false)) {
      var link = Link(_projectScriptLinkPath);
      link.createSync(script.path);
    }
  }

  ///
  /// Builds the project.
  /// This essentially means that we run pub get
  /// however if the project hasn't been initialised
  /// then we initialise the project as well.
  /// if [background] is set to true then we
  /// run the build as a background process.
  /// [background] defaults to [false]
  ///
  void build({bool background = false}) {
    /// Check that dshells install has been rum.
    if (!exists(Settings().dshellCachePath)) {
      printerr(red(
          "The dshell cache doesn't exists. Please run 'dshell install' and then try again."));
      printerr('');
      printerr('');
      throw InstallException('DShell needs to be re-installed');
    }

    lock.withLock(() {
      try {
        if (!isInitialised) {
          initialiseProject();
        }
        if (background) {
          // we run the clean in the background
          // by running another copy of dshell.
          print('DShell clean started in the background.');
          // ('dshell clean ${script.path}' | 'echo > ${dirname(path)}/log').run;
          // 'dshell -v clean ${script.path}'.run;
          'dshell -v=${join(Directory.systemTemp.path, 'dshell.clean.log')} clean ${script.path}'
              .start(detached: true, runInShell: true);
        } else {
          print('Running pub get...');
          _pubget();
          _markBuildComplete();
        }
      } on PubGetException {
        print(red("\ndshell clean failed due to the 'pub get' call failing."));
      }
    }, waiting: 'Waiting for clean to complete...');
  }

  /// Causes a pub get to be run against the project.
  ///
  /// The projects cache must already exist and be
  /// in a consistent state.
  ///
  /// This is normally done when the project cache is first
  /// created and when a script's pubspec changes.
  void _pubget() {
    lock.withLock(() {
      var pubGet = PubGet(DartSdk(), this);
      pubGet.run(compileExecutables: false);
    });
  }

  // Create the cache lib as a real file or a link
  // as needed.
  // This may change on each run so need to able
  // to swap between a link and a dir.
  void _createLib() {
    // does the script have a lib directory
    if (Directory(_scriptLibPath).existsSync()) {
      // does the cache have a lib
      if (Directory(projectCacheLib).existsSync()) {
        // ensure we have a link from cache to the scriptlib
        if (!FileSystemEntity.isLinkSync(projectCacheLib)) {
          // its not a link so we need to recreate it as a link
          // the script directory structure may have changed since
          // the last run.
          Directory(projectCacheLib).deleteSync();
          var link = Link(projectCacheLib);
          link.createSync(_scriptLibPath);
        }
      } else {
        var link = Link(projectCacheLib);
        link.createSync(_scriptLibPath);
      }
    } else {
      // no script lib so we need to create a real lib
      // directory in the project cache.
      if (!Directory(projectCacheLib).existsSync()) {
        // create the lib as it doesn't exist.
        Directory(projectCacheLib).createSync();
      } else {
        if (FileSystemEntity.isLinkSync(projectCacheLib)) {
          {
            // delete the link and create the required directory
            Directory(projectCacheLib).deleteSync();
            Directory(projectCacheLib).createSync();
          }
        }
        // it exists and is the correct type so no action required.
      }
    }

    // does the project cache lib link exist?
  }

  void get doctor {
    print('');
    print('');
    print('Script Details');
    colprint('Name', script.scriptname);
    colprint('Directory', privatePath(script.scriptDirectory));
    colprint('Virtual Project', privatePath(_virtualProjectPath));
    print('');

    print('');
    print('Virtual pubspec.yaml');
    read(_projectPubspecPath).forEach((line) {
      print('  ${makeSafe(line)}');
    });

    print('');
    colprint('Dependencies', '');
    pubSpec().dependencies.forEach((d) => colprint(d.name, '${d.rehydrate()}'));
  }

  String makeSafe(String line) {
    return line.replaceAll(HOME, '<HOME>');
  }

  void colprint(String label, String value, {int pad = 25}) {
    print('${label.padRight(pad)}: ${value}');
  }

  ///
  /// reads and returns the project's virtual pubspec
  /// and returns it.
  PubSpec pubSpec() {
    return PubSpecFile.fromFile(_runtimePubspecPath);
  }

  /// Called after a project is created
  /// and pub get run to mark a project as runnable.
  void _markBuildComplete() {
    /// Create a file indicating that the clean has completed.
    /// This file is used by the RunCommand to know if the project
    /// is in a runnable state.

    touch(join(_virtualProjectPath, BUILD_COMPLETE), create: true);
  }

  /// Returns true if the projects structure has
  /// been intialised. An initialised project
  /// is one where the virtual project directory has been created
  /// a pubspec.yaml exists any required links have been created.
  ///
  /// See: isRunnable to see if a project is in a runnable state.
  bool get isInitialised => _isProjectInitialised;

  /// Returns [true] if the project has been intialised
  /// and a [build] has been run (which essentially calls
  /// pub get).
  bool get isRunnable {
    return _isProjectInitialised &&
        exists(join(_virtualProjectPath, BUILD_COMPLETE));
  }
}

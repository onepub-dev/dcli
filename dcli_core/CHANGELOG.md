# 1.35.1
- Fixed a bug in the ask regex validator that was forcing results to lowercase.
- Released 1.35.0.
- moved min sdk to 2.17 as required to support the current set of dependencies. Upgraded to scope 3.0.0 to fix sync/async bug in withEnvironment.

# 1.35.0
- moved min sdk to 2.17 as required to support the current set of dependencies. Upgraded to scope 3.0.0 to fix sync/async bug in withEnvironment.
- Released 1.34.1.
- Released 1.34.1.
- Changed sudo dcli install  instructions after hint from @RandalSchwartz that -E does the same as env "PATH=$PATH"
- Upgraded to dart_posix 4.0.1 to fix a bug #202 dcli install fails on macos.
- Released 1.34.0.
- Released 1.34.0.
- Add missing nothrow after changin the ScriptRunner run command to using start internally.
- change the test tag 'sudo' to 'priviliged'
- Added code to the test_file_system to activate dcli into the file system. reduced supurfluous unit test output.
- remove a verbose setting from the run hello world tests.
- Added unit_test scope to work with the dcliExit code so it knows when we are in a unit test.
- repack the full/install.dart.
- spelling.
- Added start method to DartScript.
- fixed unit test where they named the temp .pub-cache directory inconsistenty.
- Change the test tag sudo to privileged to reflect how we us it.
- replaced calls to exit with dcliExit to stop calls to exit() shutting down the unit test framework.
- renamed dclizone to capture. Wrapped parts of unit tests in capture to reduce extraneous output.
- Added additional error test for the find function - errno 5 on linux with can occur when running in a vm or with fuse.
- Merge branch 'master' of github.com:onepub-dev/dcli
- improved the project creation from template code. We now more tightly target package name updates.
- excluded the settings.yaml from the template.
- Added support for excluding resources when packing.
- Improved the full sample template.
- GitBook: [#176] No subject
- updated full template
- Released 1.33.2.
- Released 1.33.2.
- replaced the full project template with a complete working example.
- change the labels using doctor to all lower case.
- corrected the chmod doc example for execute permission.
- Merge branch 'master' of github.com:onepub-dev/dcli
- Added additional files to not publish.
- removed the creation of read.me in the docker dcli_cli.df.
- Found additional cirumstances when we must run as priviledged on linux so remove the check that we are running on windows to require priviledged operation.
- If the install dir doesn't exist we may need to be privildged to create it so we now run withPrivileges.
- GitBook: [#175] No subject
- GitBook: [#174] No subject
- upgrraded win32 version to 2.7.0
- released 1.33.1
- Released 1.33.1.
- upgraded to settingsyaml 3.4.2 to get the latest bug fixes.
- Released 1.33.0.
- Released 1.33.0.
- updated to pubspec2 2.4.1.
- Upgraded to pubspec 2.4 as 2.3 would clear out executable values in the pubspec.yaml.
- Released 1.32.1.
- Released 1.32.1.
- The glob parser now supports the escape character ^ inside nested quotes.
- Correct name used in documenation for run.
- Fixed the link to the contributing guide on the readme page.
- Added additional pathToXXX to DartProject so we cover each of the standard directories and files.
- Released 1.32.0.
- Released 1.32.0.
- Fixed a bug on copy_test that wasn't checking for an existing file.
- moved to dart_console2 util dart_console gets an upgrade.
- Upgraded to posix 4.0, ffi 2.0, dart_console 2.0.0
- removed redundant template code as we now use our own 'dart pack' command to pack assets.
- Released 1.31.3.
- Released 1.31.3.
- Released 1.31.3.
- Released 1.31.3.
- Released 1.31.4.
- updated pub to dart pub
- updated pub to dart pub
- Fixed the global activate command syntax.
- add os matrix
- updated pub to dart pub
- re-packed templates
- Merge branch 'master' of github.com:onepub-dev/dcli
- relaxed the dcli version in the project templates.
- removed some nulls from  platforms in pubspec.yaml
- relaxed the ffi version.  Upgraded mocktail version. Removed the dshell_upgrade exe.
- Fix: the project create code was printing out the wrong script name (main.dart) when we actually create a script called <projectname>.dart.
- upgraded to the lates version of circular_buffer.
- Updated the DartProject documentation.
- repacked resources after updating the lint_hard version.
- ignored all .packages directories.
- upgrade to lint_hard 2.0 for dcli_core
-  removed verbose output for the purge tool.
- disabled verbose output on unit tests.
- change find_test to just output counts rather than every filename.
- Fix: added check in find for missing directory when running under windows.
- upgraded to lint_hard 2.x
- changed windows_mixin_test to assume it is running in a privildged session.
- Fixed a bug in the start with progress unit test on windows. The echo psuedo command was being treated as a command so was failing to run.
- Fixed a startup bug in the windows mixin test.
- Fixed a windows bug on the test_file_system which didn't account for the different exe extension of .exe.
- Fixed the read_test for windows. It wasn't taking into account the different line endings.
- Fixed bug in dart_project warmup on windows. We try to recursivly delete dirs in a find which just doesn't work on windows.
- Fixed the dart_script_test so it works on windows. The .exe extension was causing tests to fail.
- Change the symlink copy test to create the symlinks as on windows when pulling from git we get files not symlinks.
- Changed _windowsIsRunning to use the win32 vesrion of getWindowsProcesses. Fixed a bug in _getWindowsProcessesOld caused by change in the cvs library we use.
- removed unused var.
- set the dcli version to ^1.0.0 for the templates as dart will find the most recent compatible version.
- Merge branch 'master' of https://github.com/noojee/dcli
- Fix: on window dcli install was failing as we were deleting directories whilst doing a recursive find when re-installing the templates.
- upgraded to latest version of pubspec.
- repacked resources.
- applied updated version of lint_hard
- improvements to documentation.
- added copyright notices.
- Released 1.31.2.
- Released 1.31.2.
- Fixed a bug in the Settings.setVerbose(true) method. Each time setVerbose was called it added an additional logger resulting in multiple log lines per logging event. Fixed a bug in Settings.setVerbose(false) - it was cancelling all loggers even ones we hadn't created.
- Released 1.31.1.
- Released 1.31.0.
- Released 1.31.0.
- upgraded to pubspec 2.2.0 to get the latest bug fixes.
- excluded tests that require sudo.
- regenerated packed templates.
- updated the template pubspec.yaml so the sdk contstraint matches dcli's.
- Released 1.30.3.
- Released 1.30.3.
- Merge branch 'master' of github.com:bsutton/dcli
- updated win32 version as causing compatibitlity problems on older sdks.
- improved the project create from template logic so that we update the dcli version dependency to match the version of dcli the user is running.
- GitBook: [#168] No subject
- GitBook: [#167] No subject
- GitBook: [#166] No subject
- GitBook: [#164] No subject
- GitBook: [#163] No subject
- GitBook: [#161] No subject
- GitBook: [#160] No subject
- GitBook: [#159] No subject
- experiemental work on delete_tree. Untested!
- removed redundant argument.
- corrected messages in move_tree that used the word copy instenad of move. Truely a 'copy' paste bug.
- renamed Settings.appname to Settings.dcliAppName
- improved the doco for replace.
- Added a better error message for the copy command if the from path is a directory.
- Released 1.30.2.
- corrected platform to platforms in pubspec.yaml
- Released 1.30.2.
- Merge branch 'master' of github.com:bsutton/dcli
- dart sdk version issue.
- added platform tag into pubspec.yaml
- Update README.md
- Released 1.30.1.
- upgraded to latest version of posix for the new group related functions.
- removed unused vars.
- removed redundant imports.
- Fixed for releasePriviliges as it wasn't correctly  setting HOME, SHELL, USER or LOGNAME when transitioning between modes.
- Released 1.30.0.
- Released 1.30.0.
- Correctly set the base sdk to 2.16
- Fixed lint warnings re tear offs.
- formatting.

# 1.34.1
- Changed sudo dcli install  instructions after hint from @RandalSchwartz that -E does the same as env "PATH=$PATH"
- Upgraded to dart_posix 4.0.1 to fix #202 dcli install fails on macos.

# 1.34.0
- Added start() method to DartScript.
- renamed dclizone to capture and remove the 'experiemental' comment.
- Added additional error test for the find function - errno 5 on linux with can occur when running in a vm or with fuse.
- improved the project creation from template code. We now more tightly target package name updates.
- Added support for excluding resources when packing.
- Improved the full sample template.

## Unit test improvements
- Added code to the test_file_system to activate dcli into the file system. reduced supurfluous unit test output.
- Added unit_test scope to work with the dcliExit code so it knows when we are in a unit test.
- fixed unit test where they named the temp .pub-cache directory inconsistenty.
- Wrapped parts of unit tests in capture to reduce extraneous output.
- replaced calls to exit with dcliExit to stop calls to exit() shutting down the unit test framework.
- change the test tag 'sudo' to 'priviliged'

# 1.33.2
- Synchronous release with dcli.

# 1.33.1
- Synchronous release with dcli.

# 1.33.0
Synchronous release with dcli.

# 1.32.1
- The glob parser now supports the escape character ^ inside nested quotes.
- Correct name used in documenation for run.
- Fixed the link to the contributing guide on the readme page.
- Added additional pathToXXX to DartProject so we cover each of the standard directories and files.

# 1.32.0
- Upgraded to posix 4.0, ffi 2.0, dart_console 2.0.0
- moved to dart_console2 util dart_console gets an upgrade.
- Fixed a bug on copy_test that wasn't checking for an existing file.

# 1.31.3
- Fixed a failed release.

# 1.31.2
- Fixed a bug in the Settings.setVerbose(true) method. Each time setVerbose was called it added an additional logger resulting in multiple log lines per logging event. 
- Fixed a bug in Settings.setVerbose(false) - it was cancelling all loggers even ones we hadn't created.

# 1.31.0
- upgraded to pubspec 2.2.0 to get the latest bug fixes.
- excluded tests that require sudo.
- regenerated packed templates.
- updated the template pubspec.yaml so the sdk contstraint matches dcli's.

# 1.30.3
- updated win32 version as causing compatibitlity problems on older sdks.
- improved the project create from template logic so that we update the dcli version dependency to match the version of dcli the user is running.
- experiemental work on delete_tree. Untested!
- removed redundant argument.
- corrected messages in move_tree that used the word copy instenad of move. Truely a 'copy' paste bug.
- renamed Settings.appname to Settings.dcliAppName
- improved the doco for replace.
- Added a better error message for the copy command if the from path is a directory.

# 1.30.2
- dart sdk version issue.
- added platform tag into pubspec.yaml
- Update README.md

# 1.30.0
- Correctly set the base sdk to 2.16
- restored the 2.16 throwsWithStackTrace in wait_for_ex now we have fixed the 2.12 based release.
- fixed the named_lock test by using the core withTempDir which is actually async.

# 1.20.0
- Cleaned up the resource_registry so the generated file matches the dart source formatter. This stops git seeing a change every time we release and run pack.
- restored the 2.16 throwsWithStackTrace in wait_for_ex now we have fixed the 2.12 based release.
- fixed the named_lock test by using the core withTempDir which is actually async.

# 1.18.1
- second atttempt at a 1.18 release

# 1.18.0
- Fixed a bug with the install when running in a docker container as it assumed it could alter the paths and we don't support that in a docker container.
- minor improvements to the test docker cli. Added dart into the container
- Added new method Shell.canModifyPath so you can check if a given shell supports modifying the PATH environment var. If you call any of the PATH related methods on a shel they will now all throw UnsupportedError if canModifyPath returns false so check that first.
- Bump minDartSdk constraint to 2.16

# 1.17.5
- Fixed a bug in withTempDir. If the action was async withTempDir wouldn't wait for the action to complete.

# 1.17.4
- improved the doco formatting for createTempDir.

# 1.17.3
- updated the dcli_crore dependency

# 1.17.2
- fixed createTempDir as it assumed that /tmp always exists which isn't the case in a docker container.
- reverted changes for 1.17 release after backpedling to create a 1.16 release.

# 0.0.7
changed to using scope package.


# 0.0.6-beta.3
- reverted to dart 2.12 

# 0.0.6-beta.1
- release candidate for 0.0.6

# 0.0.6-dev.2
- Fixed the isRead/write/owner methods which broke after moving to posix.
- Fixed a bug in settings where hierarchicalLoggingEnabled logging was not always been enabled.
- Fix: copyTree was hanging since the update to dcli_core.
- Added new argument to withTempDir to allow the caller to provide the temp dir.
- ENH: Added method withEnvironment allow users to create a scoped environment
- Moved log related settings from dcli to dcli_core.Settings
- added setter for Pubspec.name.
- moved to importing dcli_core with as core.

# 0.0.6-dev.1
- ENH: Moved to using logging package for log output.

# 0.0.5
- simplified the basic template.
- add workingDirectory support to toParagraph and toList
- improved dcli tab completion for the compile command by only showing files that end in .dart.
- Improved the stacktrack logging when using waitForEx. If verbose is on we now log a fully merged stack trace.
- Added a tool to make it easy to launch a script in profile mode.
- Fixed a memory consumption problem caused by find.forEach not pausing the stream.
- Made the bytesAsReadable static method of Format into a instance method for consistency.
- Cleaned up the top level directory post dcli_core merge.
- Implemented LimitStreamController to stop the find command causing us to rum out of memory.
- restructured templates to be in a separate package and now use dcli pack to ship them.
- modified activate_local so you can run it from within the project.
- experiements in incremental compilation. Unfortunately you can only incrementally compile to a dill.
- BREAKING: chmod now calls the posix chmod if posix is available. Change the order of the chmod args and made permission a named argument  to match chown args.
- renamed the resources directory to resource and the templates directory to template in keeping with the dart directory naming conventions.

# 0.0.4
- Added method Env().exists which checks if an environment variable exists.

# 0.0.3
- removed unecessary code from line_file
- fix: tail was deadlocking when straming.
- Fix: find was consuming larges amounts of memory as it would keep scanning even when the consumer was paused. We now pausing scanning to allow the consumer to keep up.
- Fixed a bug in copy_tree. We were prematurely canceling the subscription with the result the tree wasn't being copied.
- added missing sub.cancel to replace function.
- Added missing subscription cancellation.
- Breaking: changed exists, isFile, isDirectory, isLink to synchronous functions due to slow async lint warning recommending use of Sync versions for performance.
- removed call to slow async method in touch
- copy_tree : Added missing close for the controller. Possible memory leak.
- Breaking: change lastModified to return syncrhonously by recommendation of dart lints - slow async.
- changed the PATH global variable to include 'empty' paths because on linux and empty path means the current directory.
- added the overwrite flag value to the verbose logging for copy and move.

# 0.0.2
- isLink was failing as we were missing the followLinks: false argument which caused it to return the type of the linked entity rather than the link.
- Fixed the X11 bug again. The find command mustn't traverse down symlinks as this can cause looping.
- Fixed stream listener logic in copyTree, replace and tail. You need to pause the subscription whilst processing an event otherwise events occur simultenaously which is not good thing when manipulating files.
- removed unnecessary await in backup.dart
- increased timeout for find_test so it could complete a full system scan.
- changed the witOpenLineFile method to use an async action as we were getting overlapping io operations because we were not waiting for the prior opration to finish.
- Moved to using the stacktrace_impl package.
- changed to async File.copy
- ported copy fixes from pre-core copy.
- Added asList method to the StackList class.

## 1.0.0

- Initial version.

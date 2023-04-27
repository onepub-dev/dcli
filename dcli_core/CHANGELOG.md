# 1.36.2
- updated the pubcach pathToHosted to deal with working in 2.19 environments as the hosted path in pub-cache changed locations.

# 1.36.0
- back ported the dcli lock command.
- added pubspec_lock to deps.

# 1.35.7
- Upgraded to dart_console2 2.0.1 to fix bug on when running in docker.

# 1.35.6
- Fix: pack command fails when no 'excluded' clauses.
- renamed InvalidArgumentsException to to InvalidArgumentException.

# 1.35.5
- Fix: back ported mac_os install fix.
- Fix: PubCache.findPrimaryVersion fails if the .pub-cache/hosted/pub.dartlang.org doesn't exist.
- reverted the dcli install instructions to use sudo env as suod -E doesn't seem to work in some instances.

# 1.35.4
- release after failed 1.35.3 multi release
# 1.35.3
- Upgraded to posix 4.1.0 to fix macos gecos npe.
- fixed lint warnings about incorrect use of async.

# 1.35.2
- second attempt at 1.35 release as the original publish attempt failed.

# 1.35.1
- Fixed a bug in the ask regex validator that was forcing results to lowercase.
- Released 1.35.0.
- moved min sdk to 2.17 as required to support the current set of dependencies. Upgraded to scope 3.0.0 to fix sync/async bug in withEnvironment.
- Upgraded to dart_posix 4.0.1 to fix a bug #202 dcli install fails on macos.

# 1.35.0
- moved min sdk to 2.17 as required to support the current set of dependencies. Upgraded to scope 3.0.0 to fix sync/async bug in withEnvironment.

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

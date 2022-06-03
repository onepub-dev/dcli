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

# 4.0.1-beta.4
- added back in the missing nothrow arg to start method.
- Fixed running of detached processes. We were trying to get the exit code which would never work.
- Added some missing async statements when using named locks. Fixed a bug in dart_project when running in a unit test. It was getting the platformComfig which was a uri of the form file:// but then trying to process it as a simple path.
- moved message_response to its own file. Added a processor for exceptions as we were dumping exceptions generated in the isolate on the ground. Fixed a bug when we call start in with mode terminal. We were still trying to attach to the stdio stream when the don't actually exist. The same goes for detached. added json encoding to DCliException and RunException so we can pass them over the isolate boundary via a mailbox.
- changed namedLock to async until tsavoc has a chance to merge in his sync version.  We may need a sync and async version to
 allow for async callbacks.
 - still no action on async validation methods for 'ask'.

Most unit tests are now working and most of the common process execution paths appear to be working.


# 4.0.1-beta.2
- upgraded to the latest version of dart_console.
- migrated back to dart_console as I'm now the maintainer.
- down graded max win32 version to 5.3 to avoid deprecation notices.
- renabled support for terminal mode on the start command. Still needs more testing.
- minor code refactor.
- Reverted the use of win32  to constansts deprecated from 5.4.0 to improve our compatability window.



# 4.0.1-beta.1
## Breaking
- fetch/fetchMulti are now async.


Still a chunk more to do but the core 'good' paths seem to be mostly working when running processes.
Optimistically this will get most people over the hump whilst we clean up the few remaining problems.

There are still some concerns around running a process in 'terminal' or 'detached' mode and I've not done any testing (and there is a path missing) of
getting stdin attached to the process. This is probably the remaining 'big' issue but I think I can see a path through this.

Take it for a spin and let us know how you go. I will try to priorities the issues that are burning people the most.

# 4.0.1-alpha.13

# 4.0.1-alpha.12

# 4.0.1-alpha.11
- merged #234 from tsavo-at-pieces which provides windows support for 
synchronous process calls. Big thanks for the work on this Tsavo!!!
- migrated away from custom implementation of mailboxes to the native_synchronization package. Big thanks to @mraleph for his massive contributions and trial conversion of dcli to dart 3.x which most of my
work is based off.
- The sleep function is now fully syncronous and blocks all async code from running.
 This is a BREAKING change as the previous version of sleep allowed async
 code to keep running. Use sleepAsync to allow async code to run. Note:
 code in other isolates is unaffected by calls to sleep.

# 4.0.1-alpha.8
- fixed the sdk range for dcli_common
- switch to activating dcli_sdk instead of dcli.

# 4.0.1-alpha.7
- upgrade settings_yaml version.

# 4.0.1-alpha.6
- failed released - so did it again

# 4.0.1-alpha.5
- upgraded to latest version of pubspec_manager.
- removed conflict for Platform definition.
- Added support ot the Ask function to validate urls.
- Fixed a null check in the new inDocker method.
- updated the DockerShell to use /proc/1/cgroup to determine if we are in a docker container as the test for .dockerenv no longer 

# 4.0.0
- BREAKING - removed the PubSpec class. We now recommend that you use the
package pubspec_manager which provide similar (better) functionality
We have also migrated dcli from using pubspec2 to pubspec_manager.
- withTempDir is now async. The sync version was dangerous because
  if the callback was async dart didn't warn you and we could delete
  the temp dir before the action completed.
- core.which is now synchronous.
- core.restoreFile is now synchronous
- core.tail now returns a List<String> rather than a stream.
- fetch is now async 

Special thanks to Vyacheslav Egorov for contributing most of the work
required to remove waitFor.

# 3.1.0
Fixed for broken dart 3.x release.

# 3.0.3
- upgraded to pubspec2 2.5
- Fixed a bug in dcli_core where you couldn't access the parent scope in
withEnvironment.

# 3.0.2
- second attempt at a 3.x release

# 3.0.1
- no changes from prior release. This release is to fix a whole in the release resulting in  missing support dart 2.19.
- this release will be followed by a final 2.x release that will provide dart 2.19 support.

# 2.2.4
- upgraded to latest package versions
- updated min sdk to 3.x for all sub packages.
# 2.2.3
- change the path to the pub-cache to reflect the new path at hosted/pub.dev which changed from 2.19

# 2.2.2
- upgraded all package dependencies to the latest.

# 2.2.1
- upgraded to settings_yaml 6.0

# 2.2.0
- upgraded to dart 3.
- updated script_test to reflect windows exe names end with .exe.
- updated the dart sdk test to reflect the directory name change in .pub-cache.
- made which_test case insensitive on windows.
- removed expect for the .packages directory as dart 3.x no longer creates it.


# 2.1.0
- Updated to system_info2 3.0.2
- modified withTempFile and withTempDir to take an action that returns a Future rather than FutureOr. Now we are moving to a fully async model Futue catches more errors for the library user.
- upgraded to lint_hard 3.0. Cleaned up lints.

# 2.0.1
- stable release now that 2.19 has been released.

# 2.0.0-beta.21
- upgraded to latest 2.19 beta.
- Fixe for DartSdk.installFromArchive as it was choosing the wrong archive in 
some circumstances -e.g. ripi.


# 2.0.0-beta.20
- due to failed .19 release

# 2.0.0-beta.19
- Added test for dcli compile --package
- Fixed a bug in the pub cache path as with dart 2.19 google has renamed it from pub.dartlang.org to pub.dev
- Fixed a bug in compile --package that incorrectly reported that the package wasn't installed.
- Added a check to the compile --package command to ensure that dcli has been installed as we expect that the ~/.dcli directory exists and is on the path.
- moved to latest version of lint_hard and fixed lints.
- updated dcli as in dart 2.19 the hosted url has change from pub.dartlang.org to pub.dev

# 2.0.0-beta.18
- upgraded to file 6.1.4 for dart 2.19 compatability.
- updated to lint_hard 3.x

# 2.0.0-beta.17
- upgraded to dart_console 2.0.1 to fix a bug retriving the cursor position in a docker container.

# 2.0.0-beta.15
- Fixed: dart pub publish incorrectly allows the pubspec_override.yaml to be published which breaks compiles from pub-cache. We now explicitly exclude the override file from the temp compile directory.
- Add: new method to PubCache.findVersion to find the path to a specific  version of an installed package.
- Added: Added support for selecting a specific version to compile from pub-cache. 


# 2.0.0-beta.14
- brought the dcli_cli docker container up to date.
- Fix: bug in pub_cache.dart when .pub-cache/hosted/pub.dartlang.org doesn't exist. We now just return null form findPrimaryVersion of the directory doesn't exit.
- change withEnvironment to async so you can pass in an async callback.
- Fixed: capture was failing to flush the streams and the last two lines where not be captured.
- changed capture() to be async and dealt with the ripple affect up through the unit tests.
- Fix: caputure wasn't reliably waiting for the action to complete.
- explicitly added path to pubspec.yaml as dcli no longer exports.
- upgraded args package to 2.3.1
- explicitly included the args and path package into template projects now that we no longer ship it.
- Added an pubspec_override.yaml to each template so that they compile clean in develoment mode. Excluded the pubspec_overrides.yaml from the packed resources as they are for local dev only.


# 2.0.0-beta.13
- BREAKING: removed the args and path package exports from the dcli lib. The orginal design doesn't feel like the correct approach and does add to namespace pollution. To fix this you need to add `path` and `args` to your pubspec.yaml and `import` each package into any dart
library that depends on them. 
- FIX: mac os install issue. core problem is that the home directory wasn't being set correctly as the mac getpwd command doesn't reutrn the users home directory.
- FIX: a bug in macosinstall. It had the logic on testing if dart was installed backward but this was protected by a second bug that allowed the install to continue even when dart isn't installed.
- Fix: a  late final error in posix_shell.
- Added ability to pass a specific version to the global activate command.
- Added better error handling for the package compile option.
- Added experimental command to lock the pubspec versions to ensure released code always runs.
- Moved the command package up to the root of src.
- Added additional logging to the release and restorePrivileges functions.
- Added a verbose flag to the PubCache.globalActivate function to aid debugging.
- Added verbose logging to the which funciton.
- Added exception handler at top level for install exceptions so we get clean errors out.
- Improved the logging of the exists function.
- renamed InvalidArgumentsException to InvalidArgumentException
- re-ordered the seteuid calls so that we are still privileged when we call them.
- reverted the sudo install instructions as sudo -E doesn't seem to work in all cases. The PATH doesn't seem to work in findling dcli.
- repackaged templates.
- Fixed to settings_test, now that logger is more verbose.
- upgraded to dart_posix 4.1.0 to fix macos gecos issue.

# 2.0.0-beta.12
- FIX: bug in ask regex validator that was pushing results to lowercase.
- change capitalisation for the dcli doctor output for consistency.

# 2.0.0-beta.10
- BREAKING: renamed the menu arg defaultValue to defaultOption to reflect that we are selecting an option.
- BREAKING: change the prompt argument for the menu function from a named argument to a positional argument for consistency with ask and confirm.
- BREAKING: Changed the signature to the customPrompts so that the hidden field is positional rather than named as this makes using them more intuitive.
- BREAKING: improved the compile from package option. It's now a switch and visible in the help.
- FIX: the project creation code so it updates dcli_core version as well as the dcli version.
- FIX: a bug on Windows when we are using dart from the flutter install. flutter ships both dart and dart.bat. The dart version is actually a bash script that isn't used but which confused our path detection process.
- FIX: Upgraded to dart_posix 4.0.1 to fix a bug #202 dcli install fails on macos - thanks to @RandalSchwartz 
- split confirm out into its own library. 
- Changed sudo dcli install  instructions after hint from @RandalSchwartz that -E does the same as env "PATH=$PATH"
- moved pubspec overrides into their own file.
- improvements to the DartScript  unit tests.
- moved puppet/minion code into its own project.
- improved the help for the create command.
- improved the command help
- improved the pack command description.
- upgraded to latest version of lint_hard

# 2.0.0-beta.9
 - Fix for detection of the dart.bat exe on Windows.

# 2.0.0-beta.8
- Added lint_hard to the script template.
- Fixed a bug in the pack command which would fail if the pack.yaml was missing an excluded section.
- Fixed a bug in capture. If you passed a progress the captured output wasn't being given a chance to flush through the system.
- Added logic to the project creation to update the executables: key in the generated pubspec.yaml to reflect the main script name. 

# 2.0.0-beta.7
- change the release process to update all of the templates we ship, with the latest dcli version and sdk constraint.
- deprecated pubspec.saveToFile creating a new method 'save'. saveToFile was unnecessarily verbose.
- removed ExitException from the public interface as it is only intended for unit tests.

# 2.0.0-beta.6
- upgraded to settings_yaml 5.0.0-beta.1. This had to be done stepwise.

# 2.0.0-beta.5
- changed createTempDir to create all the temp files under /tmp/.dclitmp to make clean up easier after a app crashes. A user can just delete /tmp/.dclitmp/*
- updated settings_yaml version.

# 2.0.0-beta.2
Fixed failed release.

# 2.0.0-beta.1
- Added the ability to customise the prompt for ask, confirm and menu.
- removed the package stacktrace_impl and replaced it with googles stack_trace package.
- upgraded code base to dart 2.18 and fixed a mirid of async call issues.
- Fixed a bug in withOpenFile as it it was making async calls but wasn't declared as async.
- Fixed a bug in withOpenFile as it it was making async calls but wasn't declared as async.
- rationalized the waitForEx code as we no longer support pre 2.16 so the logic is now much simpler.
- The settings .verbose  and the verbose function now both output the file and line number that invoked the verbose command.

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
- replaced the full project template with a complete working example.
- change the labels using doctor to all lower case.
- corrected the chmod doc example for execute permission.
- For the install found additional cirumstances when we must run as priviledged on linux so remove the check that we are running on windows to require priviledged operation.
- If the install dir doesn't exist we may need to be privilged to create it so we now run withPrivileges.
- upgrraded win32 version to 2.7.0

# 1.33.0
- BREAKING: the Exectuable class has had a name change from pathToscript to scriptPath. This is
  because we are using the actual Executable class from pubspec2 rather than wrapping it.
- BREAKING: migrated to the pubsec2 package as the pubspec package was not releasing frequently enough.  Imports of 'package:pubspec/pubspec.dar' should now be 'package:pubpsec/pubspec2.dart'.
 We don't plan on reverting back.
- Upgraded to pubspec 2.4.1 as 2.3 would clear out executable values in the pubspec.yaml.

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
- Fix: added check in find for missing directory when running under windows.
- Fix: the project create code was printing out the wrong script name (main.dart) when we actually create a script called <projectname>.dart.
- Fix: a bug in the start with progress unit test on windows. The echo psuedo command was being treated as a command so was failing to run.
- Fix: a startup bug in the windows mixin test.
- Fix: a windows bug on the test_file_system which didn't account for the different exe extension of .exe.
- Fix: the read_test for windows. It wasn't taking into account the different line endings.
- Fix: bug in dart_project warmup on windows. We try to recursivly delete dirs in a find which just doesn't work on windows.
- Fix: the dart_script_test so it works on windows. The .exe extension was causing tests to fail.
- Fix: on window dcli install was failing as we were deleting directories whilst doing a recursive find when re-installing the templates.
- set the dcli version to ^1.0.0 for the templates as dart will find the most recent compatible version.
- Changed _windowsIsRunning to use the win32 version of getWindowsProcesses. Fixed a bug in _getWindowsProcessesOld caused by change in the cvs library we use.
- relaxed the dcli version in the project templates.
- removed some nulls from  platforms in pubspec.yaml
- relaxed the ffi version.  Upgraded mocktail version. Removed the dshell_upgrade exe.
- upgraded to latest version of circular_buffer.
- upgraded to latest version of pubspec package.
- upgraded to latest version of lint_hard
- Updated the DartProject documentation.
- changed windows_mixin_test to assume it is running in a privildged session.
- Change the symlink copy test to create the symlinks as on windows when pulling from git we get files not symlinks.
- improvements to documentation.
- added copyright notices.

# 1.31.2
- Fixed a bug in the Settings.setVerbose(true) method. Each time setVerbose was called it added an additional logger resulting in multiple log lines per logging event. 
- Fixed a bug in Settings.setVerbose(false) - it was cancelling all loggers even ones we hadn't created.

# 1.31.1
- Fixed links to doco in readme

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

# 1.30.1
- Fixed for releasePriviliges/restorePriviliges/withPriviliges as they were not correctly  setting HOME, SHELL, USER or LOGNAME when transitioning between modes.

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
- Bump minDartSdk constraint to 2.16
- Added platforms spec as pub.dev has it wrong.
# 1.17.5
- Fixed a bug in withTempDir in dcli_core. If the action was async withTempDir wouldn't wait for the action to complete.

# 1.17.4
- improved the doco formatting for createTempDir.

# 1.17.3
- updated the dcli_crore dependency

# 1.17.2
- fixed createTempDir as it assumed that /tmp always exists which isn't the case in a docker container.

# 1.17.1-beta.1
- BREAKING: moved sdk to a minimum of 2.16 to fix long outstanding issue with curtailed stack
  traces when throwing through waitForEx.
- BREAKING: moved chmod and chown to posix package.
- added method to run dart doc to the DartSdk.
- the unit test setup now runs pub get on dcli.
- fixed a dependency in the compile test.
- Added extended details to command line help messages. Improved pack error messages.
- moved from di_zone2 to scoped package.
- setup dcli up as a multi package project for pub_release.

# 1.16.3-beta.1
- attempted fix so that fetchsdk works on mac arm.
- improved the pack command error messages when the resouce and/or pack.yaml files don't exist. Fixed a bug where the pack command wouldn't run if there were only external resources to pack and the resource directory didn't exist.
- added extended description option for when user gets details command help.
- moved from di_zone2 to scope.
- Removed Env.mock as we are now using Scopes.
- Added verbose statement to calculateHash
- Improved doco on FileSync
- Added versbose statement to calculateHash
- Tweaked the menu defaultOption error when it can't find a match to call toString on the default option.
- moved chmod and chown libraries into posix directory.

# 1.16.2
- Cleaned up the logic around how we get the DartSdk version. DartSdk().version no longer returns null but will throw a DCliException if it can parse the dart sdk version - which should never happen.

# 1.16.0
- rewrite of the dcli create command. Now supports creating scripts and projects from a templates.
- added dcli create --list switch to list available templates.
- fixed all unit tests.

# 1.15.5
- Add test to the resource unpack command to throw if the target exists but isn't a file.
- Change the isXX set of functions to call the posix stat function rather than spawning the stat command. If the posix call fails we fall back to spawning stat.
- improved the doco on DartProject and DartScript.
- Removed win32 from the windows barrel file as it polluted the api documenation. Formatting improvements to the windows registry.dart
- Created a separate barrel file for docker.
- Fixed a bug when packing resources. If the pack wasn't done from the package root the resources would end up under the current directory.
- Fixed the basic tempate.

# 1.15.0
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


# 1.14.1
Fixed dependency issue with csv library.

# 1.14.0
- upgraded to dcli_core 0.0.3
- Fix: large memory consumption when using find. Now expect the controller not just the sink so we can pase the source.
- Made the 'is' methods synchronous based on lint advice.
- Fixed for the tail command deadlocking on the stream.
- improved isGloballyActivated by checking the global list rather than just relying on the presence of the exe which could have been deleted but the package is still considered active.
- Moved the package activation related methods into PubCache
- Merge pull request #179 from AdnanAlshami/master

# 1.13.6
- Added firstLine to FindProgress for backward compatiblity with the original Progress.

# 1.13.5
- Added windows specific shells to windows.dart barrel file.
- Move posix specific methods into separate barrel file posix.dart so that users are concious of the fact they are using a posix specific method.

# 1.13.4
- Fixed: #178 when creating a project with a script that contains a path we were doubling up the path name.
- documented each of the PackedResource fields.
- re-ordered the fields in the generated packed resource libraries so that the checksum and the resourcepath are at the top and therefor easier to find.

# 1.13.3
- Fix: #172 Changed the doco on warmup to indicate that it does a pub get. For the moment I've left the warmup command intact but will consider removing it.
- Fix: #178 when creating a script which include a directory in the path. If the path didn't exist an exception would be thrown. We now test if the dir exists and print an appropriate error.
- Added a file checksum and original path to the PackedResource. The checksum allows the user to easily determine of the unpacked resource needs to be updated. Added the name of the original resource to the packed resource to make it easy to identify the origin of the packed resource.
- Fixed the signature on the DigestHelper.hexEncode method as we do not need to pass a byte list as the Digets already has it.
- reduced generated line to < 80 chars.

# 1.13.2
- FIX: #173  move wasn't passing the overwrite flag down.

# 1.13.1
- Fixes: 171 CastError running dcli doctor

# 1.13.0
Dispite the version no. this is a major update to dcli.

Whilst there are few changes to the dcli api this is the first version that relies on dcli_core.

DCli Core is a new library that now holds asynchronous version of many of the functions exposed by DCli as synchrouns functions.

The original premise behind dcli was that the api should be fully synchronous to avoid developers having to deal with futures and awaits which in CLI apps offered little advantage and lots of pain.

A number of user however have asked for async version of some of the functions we expose hence the creation of DCli Core.

DCli Core is fully async and does not use waitFor.
This means that it can be used in any dart project that supports dart:io.

This means that you can now use DCli Core in a flutter app.

As flutter web doesn't support dart:io you can't use DCli core in a flutter web app.

This version of DCli includes a very early version of DCli core so some caution is advised.

As result of work done to create DCli Core we have achived significant performance improvements with the find function which previously was unable to scan a full disk without running out of ram. This is no longer an issue.

- Added in shell detection for a fake docker shell to handle when we are running as proc 1 in docker and no shell actually exists. The DockerShell provides sensible defaults.
- Moved to using the stacktrace_impl package.
- FIXED: the unknownShell was not calling the action on withPrivileges. It can do anything about the priviliges but there is no reason to not call the action.  This issue came up within docker that calls the exe without a shell.
- Added support for an escape character '^' in command lines as well as bringing the treament of quotes in line with how bash treats quotes that appear in a word. --name="fred" is now parsed as a single word rather than three separate words.
- Documented TailProgress methods.
- Documented FetchProgress members.
- experiment changing which to use a Stream rather than a callback.
- Given we require at least one option to be passed, change the menu function to return the first option (when no terminal attached) and no defaultOption provided rather than throwing an ArgumentError as in most cases the first option is probably the most common one to be selected.
- exposed win32.dart from windows.dart 
- Change to directly altering the Windows registry for the dart file association for dcli rather than using ftype and assoc.
- Added regKeyExists and regKeyCreate to registry.dart.
- Added the ability for the fetch command to 'post' data using a FetchData object to descrirbe the data to be sent.
- Fixed bug where a no. of registry methods were failing to pass down the accessRights. Added 'defaultRegistryKey' to facilitate adding values to the (Default) valueName. Added method to set a value using REG_NONE.
- Documented the fetch headers.
- Added support for sending headers to fetch.

# 1.12.4
- FIXED: stopped indentifyShell looping endlessly on docker when no shell is in the process tree.

# 1.12.3
- Fixed a bug when running under docker with no shell. loggedInUser was returning null. We now return 'root'. Hopefull this doesn't cause problems in other scenarios. If it does I think we can just add more shell types for specific scenarios.

# 1.12.2
- upgraded posix 2.2.1 for a bug fix.
- Added option to withPriviliged to allow it to be called even when we aren't priviliged. This is to allow apps that can run with and without priviliges to run without complicated code paths.
- Added progress messages to pack command.

# 1.12.1
- upgaded to posix 2.2.0
- started using the posix getppid to get the parent pid so we less reliant 
  on the 'ps' command being installed.

# 1.12.0
- Added the ability for dcli to 'pack' resource files into an application.
- Fixed waitForEx exception handling. It wasn't letting non DCliExceptions through.
- Fixed a bug where find was following symlinks.

# 1.11.0
- Fixed the command line parsing to retrain nested quotes. We had stripped out all quotes but it turns out that a bash retains nested quotes so we need to as well.
- Fixed a bug in the copy command when copying symlinks. It was copying the symlink when it should have been copying the file that the symlink pointed to.  This is in keeping with the gnu 'cp' command.
- Fetch - added specific tests  for host not found under linux as the error is different to windows.
- Added method to DartScript inUnitTest wich can be used to detect if a dart script is being run within a unit test.
- Added logic to StackTraceImpl to pick up the source type of the frame (package or file based). This help fixed the isUnitTest method and allows us to get the correct script path when running in a unit test.
- Fixed critical test hook paths.
- Added default exclusion of sudo test for critical_test.
- Moved the logic for whether the test was compiled from the setup method into the isPrivilged test as it was shutting down the entire testsuite even when the sudo tests where excluded.

# 1.10.0
- Implemented support for escaping in command lines as well as support for command words that contain quotes. Previously we separated out the quoted section into a separate word which doesn't match what bash does. --arg="quote me" is no treated as a single word.
- Fixed file_sync unit test to work on windows. the \r\n on windows caused a different file size to be returned.
- added asList method to stack_list.

# 1.9.6
- Fetch now throws a FetchException if a HTTP error occurs. Previously it would complete normally.  Even if an error occurs we try to download the body as many http errors also provide a body.
- Fixed a bug in isLink as it was resolving the link and checking if the resolved path was a symlink rather than the passed path.
- Fixed a bug where the copy command would fail if we tried to copy a symlink. We now check for a symlink and create a new symlink rather than trying to copy it.
- Added unit tests for the collection of symlink functions.
- Fixed problems with copying and deleting symlinks. Logic was manipulating the target file rather than the actual symlink.
- Fixes to a number of unit test
- Improved Format.limitString and added unit tests.
- Corrected documentation for the run method.
- Added additional unit tests for the isXXX collection of functions.
- Improved formating of comments that include a 'See:' section.
- removed pedantic as we have moved to lints.
- removed the need for exceptions derived from DCliExceptions to overload copyFrom. waitForEx can now repair the stacktrace without using copyFrom.

# 1.9.4
- Added additional verbose statements to findPrimaryVersion.
- exposed the verbose function so dcli users can use the same logging mechanism as dcli.

# 1.9.3
- fixed a bug in DartScript().self.scriptName. ScriptName which wasn't being initialised.


# 1.9.2
- Add method ProcessHelper().getProcessesByName 

# 1.9.1
- Improvements to the Fetch command progress options.
- Work on getting DartScript to return the correct paths for each mode
- that the script can exist in (local, compiled, pub global).


# 1.8.23
- 'command'.start() now returns a progress.


# 1.8.22
- made tests OS specific.
- Fixed duplication of windows paths during install issue.
- test script for path manipulation.
- move pub_cache back to util.
- restored the correct pathSeparator method and renamed it pathDelimiter to make it clearer what its purpose is.

# 1.8.21
- Work on improving the windows installer.
- Exposed the Env class as it has a number of useful PATH related methods.
- Windows Installer now checks that developer mode is enabled so we can use symlinks.

- Added resets between pub-cache tests. Looks like join recognizes both slashes so no need to use platform specific slash.
- marked reset method in a number of classes as only visible for unit testing. renamed pubcache unitTestrest to reset for consitency.
- Looks like c:\ is prefixed also need to reset pubcache between tests.
- removed pathSeparator as it duplicated dart Platform functionality.
- Fixes for bugs with locating pub cache on windows and added unit tests.
- Added addition paths to the windows PATH.
- Added pathPutIfAbsent. Also renamed all the path functions to begin with 'path'.
- Added pubcache and .dcli/bin to path.
- Fixed a bug in the format of setx.
- Added dcli path and now launches bash shell to do dev in. Not certain its what we need.
- incomplete docker script to do local dev.
- Added logic to delete the install dir if it already exists.
- Added a check for install preconditions. If they are not met the installer will exit. For powershell we now check that developer mode is enabled as we require this for symlinks. We nolonger allow an install from the old command shell.
- Added methods to manipulate the path.
- Removed a sperious print statement.

# 1.8.20
Fixed a bug in the default script which had an extra /

# 1.8.19
- Work on getting dcli to install under alpine docker image.
- reduced progress messages when ansi not supported.
- Added logic to move the dart-sdk to the write directory after expanding it. Added execute permissions to files in dart/bin directory. reduced the no. of progress messages.
- Now printing out the dir dart is installed into.
- Terminal: added method to check if ansi escapses are supported.
- suppressed asking the user to confirm the install path.
- Fixed a bug where moveTree wasn't actually recursive.
- Added a fallback mechanism on linux system to install from the archive if apt isn't found.

# 1.8.18
- Fixed a number of bugs around shell detection when one can't be determined.
- exists() - added test for null or empty path.
- dcli install - added a --nodart option to suppress installation of dart.
- Fixed bugs in windows stackframe parsing.
- Added install link for windows dcli_install.

# 1.8.17
another script path error.

# 1.8.16
Fixed for doctor when some paths missing.

# 1.8.15
- Created github actions to generated linux and windows installer for dcli and dart.
- Change copyDir to copyTree.
- Changed moveDir to moveTree.
- Created new simplified moveDir that just moves the top level dir.
- Created a 'fetch' method for downloading files.
- add logic to check if shell has a start script. Only trys to add a path when it does.
- Fixed a npe when who doesn't return a user.
- trying to improve the error message with .run is called and fails.
- fixed an npe if the SHELL env var doesn't exist.
- change paths to use truepath for consistency.
- fixed broken brackets in readme.md
- Developed code to download dartsdk from google archive and wrote test for same.
- refactored the ansi classes and introduced additional methods for controlling a terminal.
- added method to format a double as a percentage.
- added cursor management.
- dart_install for linux
- workflow to create installer each time we do a release.

### 1.8.14
- moved mockit to dev dependencies.
- For the moment I've wound back the privileged requirements for install as it makes unit tests fail.
- fixed unit tests to deal with unordered file lists.
- Added logic to handling moving files between partitions. We fallback to doing a copy then delete.
- Added .dcli/bin to path during install.
- work on improving shell detection
- Now using our own version of recase.
- now using official pub_release.
- changed writeToFile to saveToFile as felt it was more evocative.
- removed dependancy on recase as was causing conflicts and we only use one line from it.
- now exporting pubspec_file as its a useful class.
- Added nothrow option to string start method.
- restructured shell related classes as part of work to improve shell detection.
- incorrect case in help.
- seplling.
- Fixed a bug where running 'dcli help <command>' wouldn't print the command help but did print the entire usage.
- made the path columns wider.
- colour coded the shell name.
- fixed warning.
- v 0.1.0 of docker cli for dcli.
- Work on installing dcli using sudo and as a root user. Added priviledged required message.
- The default script was using a relative path when it should be using a package.

# 1.8.14-dev.3
Added null check around sourcePath.

# 1.8.14-dev.2
Removed ReCase as a dependency as its used in lots of other project causing dependency conflicts.

# 1.8.14-dev.1
- Work on improving shell detection.
- Added nothrow to string_as_process start method.
- Exposed PubSpec_File class as part of the public api.

### 1.8.13
- fixed indentation problem. released 1.8.13
- exposed SortDirection required for FileSort.
- applied effective dart.
- Had max/min back to front for Menu options.

### 1.8.13-dev.1
- [ENH] Work on a docker based cli for dcli.
- [FIX] unknown shell no returns false for priviliged user to avoid npe.
- [Fix] for macos which by default only supports 127.0.0.1.
- [ENH] added logic to fix permission when dcli rans as root.
- [FIX] bug when determing pub-cache path if environment variable set.
- [ENH] added new methods loggedInUser and isPrivilegedUser.
- [ENH] released dcli_install as a binary so people could easily install dcli.

### 1.8.12
- [ENH] created a command to upgrade dcli.
- [DOC] cleaned up the public interface by making a number a items private.
- [IMP] changed color for command messages for consistency.
- [IMP] removed clean all as when you first install as there should be no projects. dcli upgrade on the other hand does need to do a clean all.
- [IMP] cleaned up invalid argument processing.
- [FIX] Fixed a bug which allowed install to be run from sudo.

### 1.8.11
- [enh] adding validation to ask.
- [imp] moved the cleanall after the install has completed so that compile errors don't stop the install completeing.
- [bug] Fix for Service.getIsolateID returning null in compiled script. The hashcode should be a stable substitute. The question is why is getIsolateID only failing in some compiled scripts.

### 1.8.10
Fixed bug in glob expansion where a relative path with ../ was mistaken for a hidden path.

### 1.8.9
second go at fixing the compile install bug.

### 1.8.8
[BUG] dcli compile was failing to install due to move bug.

- reformatted error so you can copy paste cmdline for testing.
- bug in move as overwrite did not have a default value.

### 1.8.7
[ENH] added copyDir and moveDir functions.

### 1.8.6
[BUG] bug in the quote handling of startsWithArgs

### 1.8.5
- [ENH] Exposed NamedLock as part of the official dcli api.
    - Tidied up the NamedLock documentation and removed internal implementation from the api. 
- [ENH] changed how we handle quoted arguments when the startWithArgs method is called. We no longer strip quotes from passed arguments because if you pass quotes you probably really need them to be there. This differs from passing cmdLine where we need to strip the quotes as bash does.
- [ENH] added logic to suppress color codes if terminal doesn't support them.
- [ENH] added support for backspace when entering hidden text for ask.
- [CLEANUP] dog fooding the internals of VirtualProject.

### 1.8.4

- This release is primarily about getting dcli to work correctly under windows.
- There is still a no. of significant issues that need to be resolve for windows.
- This release however has sufficient improvements for general dcli users that I thought it was time for a release.
- The core windows issues is that dart2native doesn't support symlinks so compilation doesn't work.
- This is affecting unit tests so its a little hard to evaluate just how stable the windows release.
- Having said that it does look like dcli is broadly working under windows.
- I will be attempting to resolve these issues over the next week or so.

- This release also fixes an issue that Mac uses had that stopped them compiling dcli.
- It appears that the logger package has a problem (Invalid cid) that stopped compilation on Mac, windows and Rasp Pi. I've removed this package and now compilation seems to work fine.




### 1.8.3
- [fix] Compile fixes when project has local pubspec.yaml.
- [enh] Added experimental parser to string_process which allows reading and parsing a number of common file formats.
- [enh] Added glob expansion when running command lines.
- [enh] New NamedLock class provides an inter isoloate and inter process locking mechanism.
- [enh] Improvements to documentation.
- [enh] New method on FileSync to create a temp file.
- [enh] Version of start which takes a command and an arg array to provide a simplified path
- when complex escaping is involved.
- [fix] For unit test so that all test can now complete in a single run.
- [fix] Start was not passing the Progress down.
- [fix] Bug in tab completion when expanding scripts.
- [fix] Two compiler bugs. It was trying to compile scripts in subdirectories when we are only meant to compile scripts in the current directory.  Fixed bug where local pubspec.yaml was being ignored.

### 1.8.3
Added start method which takes an arg array to avoid escaping lots of quotes.


# 1.8.0
* upgraded to dart 2.14

There are a number of minor breaking changes would should not affect most users.

* Added new byte level read/write methods to FileSync

* Changed Remote to have a factory Constructor and each method from a static to an instance method.
* Changed Recase to have a factory Constructor and each method from a static to an instance method.
* Changed EnumHelper to have a factory Constructor and each method from a static to an instance method.
* Changed StdLog to have a factory Constructor and each method from a static to an instance method.* 
* Change the Format methods from static to instance and added a factory constructor to Format.
* Added extension to Platform Platform.eol
* Replaced \n with Platform().eol so that the line terminators for append and write are now platform specific.
Fixes:

* ask(hidden: true) wasn't working on windows as windows generates 13 rather than 10 when the enter key is used.  Also we have to set the lineMode to true before echoMode on windows.
* Spelling of milliseconds as millseconds on the sleep command thanks to whoizit


# 1.7.3
- Fixed the replace test to work correctly with windows line delimiters.
- corrected version no.
- Added method isProcessRunning to the ProcessHelper class.
- Fixed typo in doco - thanks to @whoizit
.
- Fixed a bug in DartSdk.globalActivate - it was ignoring the passed package and always installing dcli :)

# 1.7.1
- Added verbose statement to DartScript.

# 1.7.0
- Changed findPrimaryVersion to run null if package doesn't exist in pub-cache. This makes error handling easier than when an exception was being throw. We previously through a StateError and this wasn't really an error.
minor doco changes.
- Added working directory to runexception to aid the user in diagnosing the cause of the run failure.

# 1.6.3
- improved the messaging when dcli isn't on the path. improved colour coding of installer.
- Added toParagraph method to the progress. Returns the output as a single string joined by the platform specific line delimitier.

# 1.6.2

# 1.6.1
- organised imports.
- Added method to find the primary version of a package installed into pubcache.
- Added skip when not running on windows for the windows process helper tests.
- Change the code which loads a list of processes to use windows api calls rather than spawning tasklist. There is a slight regression in that we can't get the memory used but I think thats not a feature that people will be using as yet.
- method to allocate/free memory for ffi calls.
- Released 1.6.0.
- Fixed the isCompiled method so it also works on windows.
- reimplemented isPrivilegedUser with ffi calls.

# 1.5.12
- Fixed a bug in the call to chmod during the dart sdk install from archives.

# 1.5.11
- Fixed a a path that we use to look for dart during installation.
- Removed use of ansi chars to show dart sdk progress as having problems in a docker container. Now just print a '.' each time data arrives.

# 1.5.10
- Added code to catch error if we attempt to read the cursorPosition if stdin is closed.

# 1.5.9
- Changed the installer so it no longer uses apt to install dart as the apt package is always stale. Now always install from the dart archives.
- Also fixed a bug where the installer failed to install dart as it incorrected thought that dart was installed.

# 1.5.8
- Added back in the global activation of dcli as we have removed the sudo requirement which means that https://github.com/dart-lang/sdk/issues/46255 no longer applies.
- Added documenation on  using chmod. Added Windodws support by making the call a noop.
- Changed DartProject.isReadyToRun to use DartSdk.isPubGetRequired as this does a more complete check.

# 1.5.7
FIXES: 
 - Fixed a bug in the namedLock class. If a lot of threads where trying to get a hard lock then then thread with the  lock couldn't get a hard lock to release it. Threads without a lock now check for a valid file lock before trying to get a hard lock. Fixed lock tests so they now work every time.
 - unit tests for project_create_test.dart now work correctly.
 - Fixed the ask test. The message now is wrapped in ansi red encoding which is why it started failed.
 - NamedLock - Fixed a bug with the wait loop for taking a hard lock that was waiting 30secs * 30secs rather than just 30 secs.
suppressed lint.

IMPROVEMENTS:
 - Added verbose statement when exception is thrown in named lock. 
 - Changed logging to directly use verbose to improve performance.
 - removed an verbose logger in the progress as it was generating execessive logs.
 - added detached and terminal options to DartSDK.run method.
 - Added details on Pub Cache to doctor and some general formatting cleanup.
 - removed refernces to the dcli cache as its no longer used.
 - Improved the code the checks that a package name conforms to a dart indentifier.
 - critical_tests setup hook now exists with a non-zero exit code if not running as a privilged user under windows.
 - removed the isPriviliged requirement unless we are running on windows.
 - Added method runPubGet to the DartScript class. Fixed the run_test.dart unit test which failed to run pub get after creating the script.
 - added calls to pub get for each of the test packages to ensure they are ready to run
 - Added method to check if pub get needs to be run DartScript.isPubGetRequired
 - Added logic to critical_test startup prehook to run pub get on all test packages.
 - NamedLock - Moved from a raw socket to a tcp socket and change the port no. to a value below 10000 (9003) as this is what is requierd to work on Windows. 
 - Added logic to remove empty strings from the PATH which can occur if the path contains two adjacent delimiters;

# 1.5.6
updated documentation link.

# 1.5.5
Updated the homepage.

# 1.5.4
removed the dcli symlink for sudo as it just wasn't going to work. 

# 1.5.3
- performance improvements for unit tests.
- restricted the privileged requirements on install to windows.
- Merge branch 'master' of https://github.com/bsutton/dcli
- GitBook: [master] 67 pages modified
- Fixed the named lock trash test so it shuts down cleanly.

# 1.6.0-beta.1
- improved performance of unit tests by removing unnecessary testfilesystem.
- Fixed a bug in the new extensionSearch which was returning the full path to the found exe rather than just the basename as passed in.
- removed debugging code.
- Merge branch 'master' of https://github.com/bsutton/dcli
- Fixed a major bug in find. When a directory contained more than 100 child directories all child directories were returned but the contents of every second directory (after the first 100)  where not returned.
- Added extensionSearch to start function.
- Fixed bug in createScript as it was ignore the project path.
- Changed ask and confirm to return immediately if no terminal is attached.
- added checks that we are running as a privliged users.
- Added windows registry methods regIsOnUserPath and regPrependtoPath
- Added extensionSearch argument to which function. The argument only affects windows and causes the which command to search the set of possible extensions defined in PATHEXT.
- deprecated addToPATHIfAbsent in favour of appendToPath which now does a check before adding the path.

# 1.5.2
Added
 - Added working directory option to DartScript.compile.
 - Added method to instantiate a DartProject from .pub-cache.

Fixed
  - a bug were we throw if the template folder doesn't exist. We now print a message asking the user to install dcli.

Removed the call to globally activate dcli. We are not currently supporting the standalone dcli_install exe and there appears to be a bug in dart that stops us form do a global activate whilst running under sudo. https://github.com/dart-lang/sdk/issues/46255

Change the arguments to DartScript.run so that 'args' is an optional name paramter. 
I don't think this is in regular usage as yet so shouldn't cause too many issues and it will result in a compile error which is easy to fix.

# 1.5.1
Deprecated DartProject.current in favour of DartProject.self and DartScript.current in favour of DartScript.self. 
   Current was ambigous; for a project was it the current running project or the one in the current directory. Change DartScript to self for consistency.

Fixed a bug caused by the dart_console. If you try to get the screen dimensions when no terminal is attached it causes the app to hang.

Changed the rootPath so it returns 'C:\' on windows.

# 1.5.0
This release largely focuses on fixes for Windows.

Changes: 
 - update dart version to 2.13 so we can use the latest win32.
 - dcli install now updates the PATH registry settings and notifies all top level windows.

Added:
- A set of registry functions to set/get registry keys.
- Added method loggedInUsersHome for WindowsMixin
- Added new methods to Terminal() 
 - writeline with text alignment.
 - cursorUp/Down/Left/Right
 - get/set current column/row cursor position.
 - support for running .dart scripts from the command and power shell prompts. You can now rung `hello.dart` rather than `dart hello.dart`
 - Created new function withOpenFile that opens a file for the duration of a callback.
 - Created new function fileLength that returns the length of a file.

Deprecated:
  - Deprecated methods in Terminal
    - previousUp in favor of cursorUp
    - lines in favour of rows.

Fixes:
- numerous issues with ansi/terminal under windows. Now use the dart_console package to handle the windows setup.
- Stopped the terminal trying to get the cursor position when we don't have a terminal as this just caused the app to hang.
- a bug in Ansi.isSupported which was testing stdin for ansi support when we should have tested stdout. Ansi colors now work on windows.
 - the uri construction for accessing assets so it works under windows.
- a bug in sleep function. Was using microseconds when milliseconds was passed.
- detection of pub_cache location. Should now work on all versions of windows.
- the root prefix when privatising paths on windows.
- bug where dcli doctor wasn't finding the dcli path as we were searching for the wrong name.
- the cmd shell was incorrectly reporting that it had privileges.
- Attempt to fix the problem with DartScript.scriptName when running globally activated. 
    We have been getting a dart version no. in the scriptName which I'm now stripping out. Hopefully this is the correct action.
- fixed path building so that createTempDir now works correctly on windows.

# 1.3.0
Added new methods
 - withFileProtection. Allows you to back a collection of files/directories run an action and then restore any changes to those files/directories. Handy when implementing dry run type features.
 - restorePrivileges. Implemented to complement  restorePrivileges
 - calculateHash. Generates an sha256 checksum on a file.


Changes
 - all internall calls to Settings().verbose have been changed to verbose to reduce logging overheads.
 - Upgraded to dart 2.13 - google tells me that this still allows older packages to work with dcli.
 - Added `keep` arguments to withTempFile and withTempDir to preseve the temp directories. Handy for examining problems with unit tests.
 - Changed truepath to call normalize rather than canonicalize as canonicalize changes the case of paths on Windows. I believe this should be non-breaking.
 - Added support for windows \ path separator in the find function.

Fixes:
 - Fixed a bug where `find` failed if an absolute path was prepended to the pattern. Now works for no path, a relative path and an absolute path prefixed to the pattern.
 - Improvements to the DartProject and DartScript path detection when running unit tests under windows.


Known Problems:

Note we have found a problem using forEach with the start function.

```dart
start('ls *.txt').forEach( print);
```

Currently this works and look like it is going to have to be part of the process re-org we are working through.
In the mean time you can use:

```dart
for (final line in start('ls *.txt', progress: Progress.capture().lines) {print(line);}
```


# 1.2.3
Added new methods:
- withTempDir - Allows you to run a callback with access to a temporary directory which is automatically cleaned up when the callback completes.
- withTempFile - Allows you to run a callback with access to a temporary file which is automatically cleaned up when the callback completes.
- createTempFilename

Changes:
- Deprecated FileSync.tempFile in favour of createTempFilename
- updated unit tests to reduce reliance of TestFileSystem to speed up the unit tests.
- depcrecated FileSync.tempFile in favour of creaeTempFilename updated to use teh new createTempFilename
- Added ignoreMissing arg to backupFile. Now throws a BackupFileException if the backup file is missing and ignoreMissing is not set.

Fixes:
- Fixed the Ansi.strip command as the unit tests were falely reporting that they worked.

Experimental:
- Added method to ProcessHelper to obtain a complete list of running processes. Not currently supported on osx.


# 1.2.2
Reverted method names on DartScript from pathToDartScript to pathToScript and similar to reduce api breakage.

# 1.2.1
- Fixed accidentail breakage. renamed some methods to use 'library' rather than 'script'.
- Changed Ansi.strip to a static method to match convention used for other Ansi methods.
- Added overwriteLine to Terminal class. Added Ansi().strip method to stripout ansi escape sequences from a string.
- Changed run to print stdout and stderr to the console rather than devNull so it was consistent with other functions.
- Added run method to make it easy to run the dart exe. Change runPub to print stderr and stdout to the console rather than supress it.
- Changed startFromArgs to print stderr and stdout by default so it is consistent with outer functions.
- formatting.

# 1.2.0
**Breaking Change**:
- Renamed Script to DartScript to make way for integration with cli_script.
- As Script was labelled as an internal class this hopefully shouldn't be too disruptive.
- DartScript is now part of the public api.
- Code changes should simply required changing Script to DartScript as the api is identical.

- Progress ctor now setting _includedStd(out, err) based on whether devNull is passed as the relevant LineAction. Previously _includeStderr wasn't  being enabled if a LineAction was passed.
- Improvements to processing of 'detached' processes.
- Added sudo tag to tests so these can be run separately.
- Fixed a bug where nothrow was not being passed down pubRun.
- Improved doco on detached argument to start.
- Changed the installer (yet again) to require privileges to be run. We now releasePrivileges to and withPrivileges to provide more precise control over what we execute with privileges.

# 1.1.1
Fixed a bug in the menu function when the passed 'limit' argument is greater than the no. of options.

# 1.1.0
**Breaking Change**: 
Change the 'search' argument on DartProject.fromPath to default to true rather than false.  
On looking at the documentation and the common usages the search logic is assumed to be on.
This should only affect a small no. of people as you would only want search off if you are creating a dart project from scratch.

New:
- simple backup and restore methods backupFile and restoreFile.
- getters in DartProject for the common paths in a dart project folder.
- Added columns and lines methods to Terminal
- Unit tests for copy function. 

Changes:
- Improved the exception  messages for the copy function when things go bad as the OS errors are ambiguous.
- Documentation improvements.


# 1.0.9
Fixed a bug in the createTempDir method and added unit test for same.

# 1.0.8
Exposed method createTempDir.

# 1.0.7
BUG: runPubGet was not passing down the Progress so you couldn't dump the output if so desired.

# 1.0.6
Updated readme.

# 1.0.5
Deprecated ProgressWithCapture and moved the capture logic into the base Progress class. Use Progress.capture() instead.

- Modified startFromArgs to NOT print any output by default.
- This is to bring it in line with start.
- If you currently use startFromArgs and want to continue with the original behaviour you will need to change how you call startFromArgs

```dart
startFromArgs('ls', ['-la']);

becomes

startFromArgs('ls', ['-la'], progress: Progress.print);
```
This change is in response to issue #134


- Switched to using critical_test package for running unit tests.
- Added method runPub to DartSdk.
- Improved the code doco for find
- Added unit tests for progress methods toList and forEach

# 1.0.4
Update README.md

# 1.0.3
Enhancements:
- Added method isPrivilegedPasswordRequired to test if the sudo password is currently cached.
- For the installer added logic to suppress the sudo requirement if the link path is already writable or we are already privileged. If we are going to prompt - for the password we now warn the user.

# 1.0.2
Fixed a bug in the shell detection logic.

# 1.0.1
Replace now takes a Pattern so you can do a Regx replacement as well as a simple string replacement.

# 1.0.0
No major changes. The api is now stable enough for us to consider this a 1.0 release :)
upgraded to release versions os csv,  equatable and ini package.


# 0.51.10
Fixed a bug ith the install when 'pub' command is not on the path. Now correctly uses dart pub.

# 0.51.9
- Added createTempDir.
- Added a regex validator.

# 0.51.9
- Merge branch 'nullsaftey' into master as nnbd migration is now complete.
- Added createTempDir.
- Added a regex validator.

# 0.51.8
- Added class ProgessWithCapture thanks to @passsy for the contribution and suggestions.
- You can now use the start function and capture the output with a simple progress.
- Allowed the priviliged flag to work on osx as well as linux for the start function. 
- Improvements to documenation.
- Fixed the import path for dcli on the templates which I broke when fixing lints.

# 0.51.7
Added work around for "Invalid Argument' when using the find command over a steam directory tree. We just log the path and keep on trucking.

# 0.51.6
Added code to return the exit code even when running a process in a terminal. This is to resolve #100. However I'm not certain if the exit code will be meaningful as it might just be the terminals exit code.

- Added new createTempDir thanks to @Reductions
- Moved to only support 2.12 and not the beta.

- tweaked the template expander to remove any lint warnings. Updated the expander so that it updates the dcli and package versions.
- Remove the lock logic around creating as testfile system as its no longer needed and greatly  slows down testing.
- Change default shell detection expected as mostly we run it from the cli.
- Added logic so that the template builder updates the dcli and dependency versions to match the current versions used by dcli.
- Migrated to full set of lint rules in lint package. First pass revert to 80chars.
- moved back to using pubspec now that nnbd version has been released.
- moved to official validators library.

# 0.51.5
Hack to get around getIsolateID nndb bug.

# 0.51.4
- Updated to latest readme content from gitbooks
- Improved the Env documentation.

# 0.51.3
Updated template pubspec.yaml to have the correct args package. Updated the installer so that it replaces the templates when a new version of dcli is installed.

# 0.51.2
removed hard coded verbose:true statement

# 0.51.1
Fixed the toList String extensions so that it never returns nulls.

# 0.51.0
Extended version ranges for ini.

# 0.51.0
Moved to temporary validators2 which I published so dcli can be full nndb. Hopefully the validators authors will update their package shortly.

# 0.50.2
re-added ini support. Upgraded to latest packages.

# 0.50.1
re-added args as a transitive dependency. I'm still uncertain if this is a good idea.

# 0.50.0
First full nnbd release.

- Removed support for 32bit installs until system_info releases a nnbd version.
- Changed to pubspec2 until pubspec is released with nnpd.
- changed createScript to expect a script name not a full path.
- Fixed the exception handling for dcli exceptions that I screwed up.
- Moved to using posix to get parent pid. Impoved exception handling.
- Used late final to do delayed initialisation. Added exceptions when pub get or dart not installed.
- updated doco
- removed ini support as the upstream package doesn't appear to be maintained.
- Finalised nnbd migration by bringing the validators class into the project.
- Fixed bug in version if dart not installed.

# 0.50.0-nullsaftey.0
- First pass at nullsaftey.
- removed suffix as no longer supported.

# 0.41.16
Reverted posix and intl upgrades as they required 2.12.

# 0.41.15
upgraded intl.

# 0.41.14
- Upgraded dcli to latest version of equatable.
- removed unnecessary log statement in symlink.

# 0.41.13
- Added logging for symlink related funcitons.
- Improvements to documentation.

# 0.41.12
Added verbose output when setting environment vars.

# 0.41.11
Exposed isXXX members that were being hidden for no good reason.

# 0.41.10
- Improved the move error message when the target directory doesn't exist.
- grammar improvements in script.dart's doco.

# 0.41.9
Removed code in env which tried to update the platform.environment settings which of course is impossible.

# 0.41.8

# 0.41.7
- Added documentation for compile method.
- Added version to help message.

# 0.41.6
Release due to bug in pub_release that was not updating the 'latest' tag

# 0.41.5
Fixed bug in getlogin (Shell.loggedInUser) when running in docker. Now corretly returns 'root' as before it was seg faulting in the posix code. 

# 0.41.4
With pub_release fixed so it can upload assets this release is to take advantage of that

# 0.41.3
Testing of pub_release uploading exes.

# 0.41.1
- Improved documentation around waitForEx stack traces and added a test for same.
- Added test for wait_for_ex exceptions.
- Added cause to dcliexception.

# 0.41.0
- **BREAKING CHANGE**: renamed the find argument 'root' to ' workingDirectory'. As I'm using the api I've found that I naturally go to use workingDirectory as its used everywhere else. So this feels more consistent.
- Implemented chown using the posix api via ffi.
- Added protection for a number of anomalies that can occur when scanning a full file system.

# 0.40.6
- Implemented chown using the posix api via ffi.
- changed find's root to workingDirectory
- exposed chmod.
- Added protection for a number of anomoulies that can occur when scanning a full file system.
- **BREAKING CHANGE**: renamed the find argument 'root' to ' workingDirectory'. As I'm using the api I've found that I naturally go to use workingDirectory as its used everywhere else. So this feels more consistent.
- released 0.40.5

# 0.40.5
- Added release hook to activate published version of dcli.
- sorted dependencies.
- Fixed the isReadyToRun method as it was looking for .dart_code rather than .dart_tool

# 0.40.4
- exposed the PosixShell.
- Added tests for loggedInUsersHome.

# 0.40.3
- reverted to returning null for a non-existing key as the changes were too destructive and end up with rather ugly code.
- Added logging of the pub-cache path.

# 0.40.2
Minor changes to progress messages.

# 0.40.1
Introduced isPrivilegedProcess so we can always tell if we started with privilegese. Changed isPrivilegedUser back to its original semantics in that it reflects the current effective user id. Fixed withPrivileges so it uses isPriviliegedProcess to correctly determine if privileges exist. Fix the 'start' function so that it interats correctly with wiithPrivileges and releasePrivileges.

# 0.40.0
- **BREAKING CHANGE**: Accessing an environment key which doesn't exists now throws EnvironmentKeyNotFound rather than returning a null. This is in prepare for nnbd.
- Updated doco for Env.
- Changed from using whoami to to using getuid for posix systems.

# 0.39.10

Implemented Shell.current.releasePrivileges and Shell.current.withPriviliges 

# 0.39.9
- Made the Script.isCompiled method more reliable. 
- Fixed the Script.pathToScript path when in a compiled exe. It was just returning the pwd.
- replaced calls to absolute with truepath
- Moved the verbose statement in the copy function up so we will see it even if an exception is thrown.
- removed the --suffix switch as no longer supported from git_release hook.

# 0.39.8
- Fixed unit testing bugs.
- Changed logic that obtains the scripts path to handle more scenarios.
- Updated the asset builder to change the dcli version in the pubspec.yaml template as it creates the expander.
- Moved docker files under tools as per the dart conventions.

# 0.39.7
Added additional checks for version nos.

# 0.39.6
Added method to check if the script is running from pub-cache.

# 0.39.5
- Fixes #126 - Does not like dashes in directory name. We now replace any invalid chars in the project name with _.
- Relaxed the requirement that the default value had to pass the validator. It made it hard to initialise the default from an uninitialised settings file.

# 0.39.4
- Fixed a bug where the fetch caused an app to not shutdown as we failed to close the client.
- Adding fish shell support 
- the method is a getter.
- Code no longer exludes proc et el directories if running 2.10 or later as bug is fixed.

# 0.39.3
Fixed a bug on osx where the install was looking for dart in the wrong place.

# 0.39.2
- tried removing the futures now we fixed the core problem with the stackoverflow.
- work on stackoverflow - tried leaving the subscription until after the progress event returns.
- attempt to fix the stackoverflow caused by fetch progress events that use the echo function. The progress events are now async which I hope will resolve the issue.

# 0.39.1
Fixed bug for windows cmd shell when running isPriviligedUser

# 0.39.0
- Removed the development mode requirement for dcli as we no longer symlink under windows.
- Added notes on the symlink methods for running under windows.
- Improved the version message when dcli install hasn't been run.

# 0.38.0
change calls to  'pub' to 'dart pub'.

# 0.37.2
finally fixed the clearLine method. Looks like it was the flush in the echo method that was causing the problem. Now using stdout.write directly.

# 0.37.1
- Updated the path to use a test script rather than the eample directory.
- Fixed a bug with resolving symbolic links when the link was to a directory.

# 0.37.0
- We now take pub from the PATH rather than calculating it from the dart directory as on some systems its not in the dart-sdk dir.
- moved from pedantic to lint and removed all of the lint warnings.

# 0.35.0
We now test if dart compile is supported (2.10 onwards) and use that rather than dart2native.

# 0.34.6
- Added support in the find method for patterns that contain a partial path.
- added lint to warn about incorrect usage of await.
- Fixed the doco on the append method as it incorrectly states that newline is a bool.

# 0.34.5
renamed example/readme.md to example/example.md as looks like the doco I found was wrong on what name was required.

# 0.34.4
Created an examples/readme.md to highlight additional examples.

# 0.34.3
Fixed code that was using find and forgetting to turn recursion off.

# 0.34.2
Added exception handler to find to deal with files being deleted during the find operation.

# 0.34.1
- Fixed two bugs in the NamedLock which effectively made it totally non-functional. The lock name had changed to have a leading '.' which meant the find command didn't find the locks and the parser no longer parsed the pid from the lock file name. 
- Added new unit test that can now detected if a lock isn't taken correctly.

# 0.34.0
Added methods to encode environment vars to json and then restore them from json.

# 0.33.8
- Added 'entries' and 'addAll' methods to Env.
- removed save as you can't update the Platform.environment.

# 0.33.7
Added method to save the environment back to the platform.

# 0.33.6
command line completion for dcli cli: added test for an invalid path. Added logic to quote paths that contains spaces. Added bash option so it won't add a space after directory names.

# 0.33.5
tweak tab completion so that dir/ matches the ls behaviour.

# 0.33.4
Simplified the logic and doing a better job of directory expansion. Still has a problem with two matching directories.

# 0.33.3
tab completion now works with a complete directory name as the search word.

# 0.33.2
work on improving the tab completion when a partial path is entered.

# 0.33.1
Fixed a bug in confirm as it needs to explictly set required .

# 0.33.0
- upgraded package versions for dart 2.10 compatability.
- moved humanReadable into Format class and made it part of the public api. Changed Format.percentage to static.
- Modifyed the prompt argument to accept an empty string rather than null to make way for null safety
- Added 'required' parameter to ask.
- Update windows_installer.yml

# 0.32.6
- Update windows_installer.yml

- Fixes for unit tests
 - the root dir was not deterministic for testing so changed to a path we own.
 - removed the bash launcher and changed expect to sh.
 - added missing default.
 - add arg to suppress dcli install.
 - removed the @pubspec as we no longer support it.
 - Added option to test file system to no install dcli so we can test installing dcli.
 - Moved to using the Shell install method.

# 0.32.5
- dcli create - improved doco and made the creating script prompt green.
     - Fixed a bug in the creation of the analysis_options path.
- Added a dot before the name of the lock so it is hidden.
- dart_project: centralise the lock filename,  
- pubspec.yaml.template: upgraded the min dcli and sdk versions.
- exists - added verbose logging.

# 0.32.4
- Updated DartProject.current so that it works somewhat intelligently for compiled scripts.
- As a compiled script doesn't have a pubspec.yaml we will return the current working directory.

# 0.32.3
Added DartProject.current which will return the current script's dart project.

# 0.32.2
Fixed git_release script so that it stores the settings in a config file.

# 0.32.1
Fixed a bug with the logic to check for dart. Had the found logic inverted.

# 0.32.0
exported the Dependency class.

# 0.31.0
- Changed which again. It now returns a specific class (Which) that contains information specfic to the which command which makes it much more intuitive to use.
- Which: improved the doco.
- Added the progress to the Which class.

# 0.30.0
Breaking Change: Changed the which function to return an list of paths rather than a progress as users expect to diretcly access the list.
Added an hours interval to sleep.

# 0.29.2
Exposed the 'Interval' enum used by the sleep method.

# 0.29.1
somehow I reverted the code to remove the workingdirectory.

# 0.29.0

# 0.29.0
- breaking change: PubSpec now returns a map for dependencies and dependency overrides rather than a list.
- renamed the default.dart template to basic.dart as default is a dart keyword and was causing conflicts in the asset generation.
- optimised the unit test by using a shared file system.
- Fixed a bug in the unit test runner as we need to run with a bash shell rather than  sh as a number of unit tests expect to find bash.
- fixed a unit test as dependencies have changed fro ma list to a map.
- change from env to loggedInUser as this will be more cross platform.
- reverted logic that had the script being run from the script directory as it doesn't allow people to select the directory they want to run the script in.
- removed references to syslog as it doesn't exists in the docker test environment.
- updated name in pubspect to match directory.
- added version no. to the install started message.
- changed to using the newist patToProjectRoot
- copyTree: Changed the default for the [recursive] argument. It is now true by default (it recurses). The command is copyTree which implies its recursive.
- renamed directory test_scripts to test_script in line with dart conventions.
- Fix: create was ignorning the passed templatename.
- fixed bug as clean now works on projects not scripts.
- added test for warmup.
- removed the --package switch as we no longer need it as we have removed virtual projects.
- re-implemented touch using native dart libs.
- install: fixed bug where we were trying to use chmod to change ownership :<

# 0.28.0
- This release includes significant changes to the dcli command line.
- The command 'clean' has been renamed to warmup.
- There is now a new 'clean' command which now does what the label says. It removes all build artifiacts.
- Find: Added static properties for file, directory and link which can be used a short hand for FileSystemEntityType.
- exposed the pub cache environment variable.
- Added a method clean to DartProjects.
- Added method warmup to DartProjects.
- Added method to PubCache to set the .pub-cache path to an alternate location.
- Improved the Move exception error.
- Fixed the compile install option which was using the wrong source path.
- Fixes to the docker unit tests.
- Added test for integer validator.
- Added compile entry point to Script and updated unit tests to use it.
- Added a 'run' method to Script so users can easily run a script from the dcli api.
- Fixed a bug in the compiler. Even if you agreed to overwrite the exe during the install it would still report an error.

# 0.27.1
- Exposed DartProject class as part of the public api
- Added color tests.

# 0.27.0
- Small breaking change:
- For each of the color function we have changed the argument bgcolor to background. 
- Abbreviations go against the coding guidelines and this one wasn't even very mature.

# 0.26.1
- ENH: Added bold option to ansi colors and made it the default for the set of built in colors e.g. red(), green()
- ENH: Added a compile method to DartProject and Script so that users can do compiles without spawning a new process.
- removed dart_project until we decide how much to expose.
- FIX: Fixed a number of bugs in dcli create,clean and compile after we stripped out virtual projects.
- Fixed a bug where the pubspec name ended up as '.' when the script was created in the current directory.
- Fixed a bug when trying to create a script in the local directory which was also the projectRoot.
- FIX: Modified runDart2Native to take a full path to the executable file that is to be created and modified the dart2native call so it now runs in the scripts directory.

# 0.26.0
- In a docker shell SUDO_USER isn't defined so we need to default back to 'root'
- Improved the sudo detection.
- Fixed the install so it will work for a root usage such as in a docker container.
- Added ask and confirm examples to the script

- PubSpecFile has been replaced with PubSpec.
- Reduced pubspec to a single class now we have removed virtual projects.

# 0.25.0
This is a major update which has removed support for virtual pubspecs and pubspec annotations.
The reality was that in production we used neither of these as ide's don't work with out an actual pubspec and in as the code built up we would
normally cluster files into a single directory so having a pubspec wasn't an issue.

Change dcli create to generate a pubspec.yaml and an analysis_options.yaml. Also now generates a more complex sample using a template.

- Ask: Added logic to hide default hidden values when logging.
- Ask: Fixed bugs in the Ask.any method. Exposed valueRange and removed all of the validator classes from the public api.
- AnsiColor: made AnsiColor class and static properties public so that you can actually use the background colours.
- Clean: Added logic to stop pub get occuring when running under sudo.
- PubspecFile: Added support for executables back in now the pubspec 0.1.5 has been released.
- Improved the process of detecting the dartsdk by resolving sym links.
- Fixed the paths so that dcli will run under sudo. The logic to find the dcli exe assumed it was on the path and that won't be the case during install.
- updated the links to the dcli manual

# 0.24.1
Updated readme to refer to the new gitbook manual.
touch : now returns the path that was passed in.
Documentation improvements. Added Ask.any and Ask.all. Exposed all of the built in validators as methods.

# 0.24.0
added method to get overriden dependencies.

# 0.23.0
**Breaking changes**:
- Added requirements for privileges when installing so we can set up paths for sudo usage of dcli. Also added option to disable the requirement primarily for unit testing.
- Changed the names of all validators to start with AskValidator. The aim is to make auto completion in ide's work better.

Non breaking changes
- Rewrote the find command so that it works even if a directory contains a file for which we don't have permissions.
- Performance improvements for the find command by reducing the amount of heap allocation going on. We now re-use arrays as much as possible. We can process 1.3M files in 3 seconds. The performance problems start when we push the files into the Progress stream.
- Updated doco to remove any references to setEnv
- Changed from Platform.isWindows to Settings().isWindows so that we can mock the platform when unit testing.
- createDir now returns the path that it created.
- Marked some tests as skip until we work out what tests are required now we have changed how we handle pubspec.yaml

# 0.22.0
removed env() and setEnv() and replaced them with operators env[] and env[]=

# 0.21.2
Fixed a bug in the Progress.stream mehthod. It was only outputing stdout and it needs
to also output stderr. It now does.

# 0.21.1
- renamed _pubCacheBinDir to _pubCacheBinPath for consistency.
- Changed the default stream method so that it now includes stderr by default as this is generally what people expect (e.g. stream what I would normally see).
- Fixed the verbose messages that mis-reported why stream output was being ignored.

# 0.21.0

**Breaking changes**:
- Refactored methods names related to paths. They now all start with a pathTo prefix. 
- The aim is to make it easier to find the methods and for ide auto-completion to be more useful.

All methods that refer to the PATH environment variable now use the capitalised word PATH in the method name.

# 0.20.2
Pubspec - Added support for fetching a list of executables.

# 0.20.0
Renamed dshell to dcli to better reflect its functionality and improve its discoverability on the pub.dev store.

Also took the opportunity to change the version no. to 0.x to reflect the fact that the api is still in flux.



# 7.1.0

# 7.0.2
- updated to code to conform to the lates lint_hard lints. Work on the 'pack' command to ensure it generates code that conforms with the latest lint rules.
- changed the ask call to readlineSync to use the newer utf8 global var.

# 7.0.1
- Merge pull request #255 from davidmartos96/archive_v4 - thanks for the patch
- Support archive v4

# 7.0.0
- BREAKING: copyTree now copies empty directories and symlinks. To get the original behaviour pass in 'includeEmpty: false' and 'includeLinks: false'.
- deprecated symlink in favour of createSymLink

# 6.1.2
- 6.1.1. released failed so here we are again.

# 6.1.1
- Added new method withPrivilegesAsync
- forced native_synchronisation to 0.7.1
- Fixed bug on windows which resulted in the projectRootPath being /C:/

# 6.1.0
- upgraded to archive 3.6.1 to overcome dart 3.5 compatibility issue. 
- upgraded all packaages to scope 5.x 
- upgraded to native_syncronization_temp 0.7.1 to fix macos and windows compatiability issues.


# 6.0.3
- upgraded to archive 3.6.1 to overcome dart 3.5 compatibility issue. upgraded all packaages to scope 5.x upgraded all packages to lint_hard 5.x
- lint fix.

# 6.0.0
- Breaking
The AskValidator now takes an additional argument 'customErrorMessage'. This will only affect
users that have built custom ask validators.
change `String validate(String line) ` to `String validate(String line, {String? customErrorMessage})`
  and then return the customErrorMessage rather than you usual error message if the customErrorMessage is not null.
  When outputing an error from you validator you should use `customErrorMessage??'my original error'`
Thanks to Emad Beltaje for the contribution!

- Upgraded to win32 v5 to fix an issue with a deprecated api for dart 3.5.
# 5.0.0
- Breaking
-- Removed a number of the withXX sync functions in favour of withXXAsync
as the sync versions were dangerous as it was too easy to make async 
calls within the callback and then the withXXX method would return
before the callback completed.

We have left stub methods for the old withXXX form that are marked as deprecated and will throw an UnsupportedError if you call them.

-- withTempDir replaced by withTempDirAsync
-- withTempFile replaced by withTempFileAsync
-- withFileProtection replaced by withFileProtectionAsync


- Removed a number of redundant methods from the dcli package that
were just pass throughs to the dcli_core package.  As the dcli barrel
file now exports the dcli_core functions for these methods there should 
be no noticiable difference in the API.

- Added new method PubCache::pathToGlobalPackage

- Fixed a bug in NamedLock which was causing a dead lock if the an existing
lock file was found but the owning process was no longer runnimg.
- upgraded to settings_yaml 8.2.0
- removed the DCLIFunction wrapper for a number of functions as it serves no purpose. 
- removed move_tree as it was just a wrapper for dcli_core method of the same name.
- moved the move and moveDir wrapper functions and exposed the dcli_core versions.
- replaced all occurances of withTempFile with withTempFileAsync
- move to using native_sychronisation_temp until the official release.

# 4.0.5
- change the dependency to native_sychronisation_temp until the offical 
package is released.

# 4.0.4
- Added additional command line options.

# 4.0.3
- fix ProgressMixin.firstLine throwing if there are no lines - contributed by @sstasi95

# 4.0.2
- removed overridden dep.
- Added a sync test for exitCode.
- temporary cleanup of the withLock methods until we get a real fix for the runtime lock package.
- update version.
- turned off debugging, cleaned old code.
- removed old startIsolate and renamed startIsoalte2 to startIsolate.

# 4.0.0
- Rewrote large chunks of the code to remove dependency on waitFor which is now deprecated.
- Split the code based up into 5 small packages to make it easier for users to uses 
  just specific APIs without including the entire DCLI code base.
- fetch/fetchMulti are now async.
- Refactored NamedLock.withLock
- Update Full Template to not require flutter
- Remove awaits from DartProject.warmup()
- The | Pipe operator has been deprecated - look out for the up coming release of HalfPipe for a replacement.
- fixed a bug in the windows wmic line parser.
- fixed regGetExpandedString as it appears that we were passing the wrong flags for the data we were trying to get back.
- removed sink and process as we are replacing these with halfpipe.
- removed pipeTo as we are moving to use halfpipe.
- updated printerr to take an Object? as does print as it makes it more flexible.


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
- add new ask option

# 4.0.1-beta.1
## Breaking
- fetch/fetchMulti are now async.


Still a chunk more to do but the core 'good' paths seem to be mostly working when running processes.
Optimistically this will get most people over the hump whilst we clean up the few remaining problems.

There are still some concerns around running a process in 'terminal' or 'detached' mode and I've not done any testing (and there is a path missing) of
getting stdin attached to the process. This is probably the remaining 'big' issue but I think I can see a path through this.

Take it for a spin and let us know how you go. I will try to priorities the issues that are burning people the most.


# 4.0.1-alpha.11
- merged #234 from tsavo-at-pieces which provides windows support for 
synchronous process calls. Big thanks for the work on this Tsavo!!!
- migrated away from custom implementation of mailboxes to the native_synchronization package. Big thanks to @mraleph for his massive contributions and trial conversion of dcli to dart 3.x which most of my
work is based off.


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


# 1.0.0
 - moved out the dcli project as you can no longer publish a sub project.
 - updated to dcli 3.x
# 0.0.5
 - updated to latest dcli to fix a bug in DartScript().scriptName where it wasn't being initialised.
# 0.0.3
added --script switch to print all of the DartScript class properties.

# 0.0.2
added --platform switch to print all of the Platform class properties.

# 0.0.1
First release.


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


# 4.0.1-alpha.11
- merged #234 from tsavo-at-pieces which provides windows support for 
synchronous process calls. Big thanks for the work on this Tsavo!!!
- migrated away from custom implementation of mailboxes to the native_synchronization package. Big thanks to @mraleph for his massive contributions and trial conversion of dcli to dart 3.x which most of my
work is based off.

# 4.0.1-alpha.10
- update the validators package to 5.x

# 4.0.1-alpha.9
- moved formatting and ansi otutput to the dcli_terminal package.

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

# 4.0.1-alpha.3
- Fixed the move function as well. It now also falls back to copy/delete on any error.
- added new projects to the replease process.

# 0.0.1-alpha.1
- initial release.

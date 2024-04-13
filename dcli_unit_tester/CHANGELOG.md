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


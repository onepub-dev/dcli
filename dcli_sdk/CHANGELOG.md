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
- ignored .failed_tracker
- dry run of dcli_sdk release.
- moved buid_templates in the dcli_sdk package as that is where they are now used.
- created a basic readme for the dcli_sdk package.
- Fixed up classes names from the pubspec_manager package as they had changed.
- removed a binary
- updated package deps
- added required repository statement.
- updated the description.

# 4.0.1-alpha.6
- removed a binary
- updated package deps
- added required repository statement.
- updated the description.

# 4.0.1-alpha.3
- Fixed the move function as well. It now also falls back to copy/delete on any error.
- added new projects to the replease process.



## 1.1.0-dev.1
Implemented dshell doctor to dump out system config to help with diagnosing issues.

Continuing work on getting docker contains configured to run test units.

Added support for a new symlink function.

Removed support for CD/Push/Pop as they just encourange bad practices and 'join' does a better job.


## 1.0.45
Enhancements to ask. Now has option 'hidden' for password entry.
Added method 'confirm' to accept yes/no answers.

Started work on docker containers for unit testing.

## 1.0.44
Fixed .run yet again. Added unit tests for same.

## 1.0.43
Fixed an NPE on start of a script with no args caused by the change to the command parser.

## 1.0.42
Improved the command line parser for string_as_process so we cam handle arguments with spaces.

## 1.0.41
Fixed a bug in run. We were printing the output rather than adding it to the foreach.
.start can now capture command not found errors for detached processes.
Added unit tests for .start

## 1.0.40
Fixed a bug where .run wasn't writing output to the console.
Introduced a new method printerr which prints to stderr.

## 1.0.39
Added the 'start' method to string_as_process to allow a detached process to be created.
e.g. 'longrunning.sh'.start(detached: true);
The dshell create command now enforces a .dart extension on the script name.

## 1.0.38
Implemented the 'run' method on the Pipe class so that ('ls' | 'head -n 5').run works.
Completed work on moving the script install option from the install command to the compile command.

## 1.0.37
dshell tab completion is now installed.

## 1.0.36
Fixed a bug in the pubspec pointing to the wrong completion name.

## 1.0.35
Updated to pubspec 0.1.3
Compiles to native should now work.

## 1.0.34
Added support of dependency_overrides in dependency.yaml and pubspec annotations.
Improved support for windows and mac.
Exposed additional help env methods PATH and HOME.
Initial work on command line completion for dshell.

## 1.0.32
updated to latest verson of recase.

## 1.0.31
Fixed the pubspec package dependancy problem.

## 1.0.30
Numerous dsort bug fixeds.
Fixed a bug with dshell incorrectly changing the working directory when a script is launched.

## 1.0.29
Fixed bug where dsort was dependant on internal dshell classes.

## 1.0.28
Change install so that it runs a cleanall so that dshell scripts use the latest version of dshell.

## 1.0.27
Improvements to dsort usage message and fixed a startup bug.

## 1.0.26
Looks like we still can't determine dshell version from the installed files.

## 1.0.25
Added dsort example which implements a merge sort.

## 1.0.24
Updated notes on creating your first script and modify dshell create to facilitate the doco.
More advanced examples will be introduced via templates.


## 1.0.23
Fixed a couple of major bugs in the create and run commands.
The create use an incorrect relative path to dshell.
The run command was using an incorrect package-root path. I think this was an misunderstanding of the 2.7 changes.
Updates to readme on how dependencies are managed.

## 1.0.22
Hide some additional path functions, tweak the why dshell readme.

## 1.0.21
Fixed links in toc. Cleanup of examples to bring them in line with public api.

## 1.0.20
Reduced the current api to what is actually supported.

## 1.0.19
refactored directories to move most libraries into lib/src to remove them from the public api.

## 1.0.18
Fixed some formatting issues and upgraded to logger 0.8.0

## 1.0.17
Update the getting started instructions to include install and create commands.

## 1.0.15
Tweeks to keep dart packager happy

## 1.0.14
Fixes for dshell create - now sets execute permissions.
Implemented basic dshell install.
Improvements to dependancy injection. Additional testing required.
We need (in theory) support dependency.yaml in the .dshell directory.
Documenation improvements.

## 1.0.13
And now actually removed the do not use warning.

## 1.0.12
Removed the do not use warnings and cleaned up some lint warnings.

## 1.0.11
Oh lots of changes.
Usage now outputs useful information if you get a command wrong.
Added an ansi-color library to allow output to have colors and use it in usage.
Added an option to allow progressive output when running a command.
Implemented additional commands.
dshell compile <script> now works.
A chunk of restructuring.
More unit tests.
Fairly confident that create, clean and clean all are safe but will leave the warning for the moment.


## 1.0.9
NOTE THIS PACKAGE IS CURRENTLY CONSIDERED DANGEROUS TO RUN.
Initial implementation of command line actions
create
clean
cleanall

## 1.0.7
Added some missing examples.
Fixed bugs in echo and ask.

## 1.0.5
Refactored apis so that we now consistently use forEach with a stream
for handling both stdout and stderr.
Added additional unit tests.
All unit tests now pass.
Added IOOverrides so cd/push/pop can be ran as part of unit tests.
Reworked find and now building own pattern matching. More unit tests required.
Added updated example.
Documentation cleanup.
Added examples to all built-in commands.

## 1.0.4
 Core features are mostly working. Find still has a major bug.
 Still experiementing with the final synatx.

## 1.0.3
 Documentation formatting.

## 1.0.2
 Tweaks to the documenation.

 Provided an example.dart

## 1.0.1

- Initial release.

## 1.0.0

- Initial version, created by Stagehand

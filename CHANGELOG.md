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

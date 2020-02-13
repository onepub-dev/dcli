### 1.8.0
[FIX} Fixed a major bug when a script had a local pubspec.yaml. If you are using vscode then vscode creates a local pubspec.lock and dshell also create a pubspec.lock. This resulted in dshell getting confused. Now if a local pubspec.yaml exists a virtual pubspec is not created and we run directly from the local pubspec.yam. This makes more sense as if you have a local pubspsec.yaml then you really have a full dart project.
### 1.7.0
[ENH] added global function to clear the screen and clear a line. clearScreen() and clearLine()
Highlighted the failed command by coloring it red.

### 1.6.3
[FIX] Fixed a bug in menu and cleaned up the documentation.

### 1.6.2
[ENH] Added (y/n): to the confirm prompt automatically.

### 1.6.1
Added an opton to control which end of a limited list the menu displays from.
suppressed the output of the format command.

### 1.6.0
Added a new menu function which displays a console based menu of selectable options.

### 1.5.2
A little cleanup of documentation and progress messages.

### 1.5.0
[ENH] dshell clean and compile command can now take a list of scripts to compile.
If no scripts are specified DShell will compile all scripts in the current directory.

### 1.4.3
Exposed devNull which makes it eash for a forEach to supress output to stdout.

### 1.4.2
[ENH] Added support  for all dependency ref types.

### 1.4.1
[FIX] had to move the cache test up as locks were artifically re-creating the cache.

### 1.4.0
[FIX] doctor was reporting the scripts path rather than the virtual project path.
[FIX] had a bug where a local pubspec.yaml was not being written to the virtual project.
unused import.
[ENH]Added an install exception if the clean found a missing cache directory. We now instruct the
user to run dshell install again.
[ENH] added logic to spawn an editor to allow the user to edit the change log as part of the release process.
Added an option to reset Settings() when we are doing unit testing.

### 1.3.0
[ENH] Added a background option for dshell create so we can run pub get in the background when creating a project. 
When creating a project the clean is now run in the background so you have immediate access to edit the script. If you try to run the script before the clean is complete it will wait until the clean is done.
[ENH] dshell create now has a --foreground flag to force the pub get back into the foreground if necessary.
[ENH] Added global cli option to log verbose logs to a log file. -v=<logpath>
We had to paths to the dart binary so choose one and deleted the other.
[ENH] added method to allow verbose mode to be turned on/off at runtime.
[ENH] Added experimental nothrow option to toList to allow it access error messages written to stdout/stderr even if a non-zero exit code is produced.
re-added windows process detection.
[ENH] When checking a path is no the PATH we canonicalize both paths to get a valid comparision.
[ENH] New dshell installer which is able to install dart on an apt based systeml.
[ENH] exposed a replace function that does a simple file content search and replace.
[ENH] moved replace into its own library and exposed it as part of public interface.
[ENH] Improved the dart detection logic to deal with dshell being compiled.
[FIX] Cleaned up the help message alignment.
[FIX] And now the sdk detect actually works.
[FIX] copy method did not pass down the overright flag. Reported by Renato Athaydes.
[FIX] chmod needed to quote paths to handle paths which contain a space.
[FIX] The exception when the PS command can't be found.
removed old version of createDir.
Logic to run the dart installer if its not already installed.
The project build complete file creates another file in the v.project.
Fixed a bug in the build completion logic. A build is complete when pub get completes.
Tweaked tests that assumed dshell create runs clean in the foreground.
changed logs to use verbose.
fun with root.
tool to compile dshell_install. Only used for dev purposes.
### 1.2.0
[ENH] toList now has optoin to skipLines to help bypass lists with a heading.
[ENH] changed run so that it always is attached to a terminal.
added another log message. tests scripts for terminal access.
[ENH] exposed experimental ProcessHelper.
Added ability to skip the first 'n' lines on toList.
added experimental note.
[ENH] add arg to skip the first 'n' lines from a list.

### 1.1.3
added terminal flag to pub publish start so it can ask user to publish.
removed unused imports.

### 1.1.2
added missing default value for terminal.
removed unused import.
[ENH] showEditor which will launch a system terminal.
[ENH] added terminal option to start.
added logic to retrieve the uncommited lists a second time.
[FIX] fixed a bug where dshell wasn't passing tty down to a spawned process.

### 1.1.2-dev-5
formatting.
[ENH] dshell doctor now dumps .dshell/dependencies.yaml and can dump the details of a script.
release notes for ### 1.1.2-dev.4

### 1.1.2-dev.4
removed unused import.
[ENH] completed work on a release script.
[FIX] workingDirectory was not being passed down.
released 1.1.2-dev.4
[FIX]  set version has to regenerate a new immutable pubspec which it did but then failed to assign it.
released 1.1.2-dev.2
script to add a local dshell override.
formatting
[ENH] changed pipeTo to pipe both stdout and stderr to the next process.
fixed minor typo.
Added logic to sett the Settings() scriptPath on start.
[FIX] Ask with the hidden option now checks if a terminal is present and if not doesn't try to use the hidden feature.
[ENH] improved performance of dshell clean by suppressing the compile executaable option which was re-compiling dshell each time.
Moved start logic into Run class.
[ENH] activate local now assumes it is run from the tools directory and goes looking for the correct dshell path.
removed unused import.
[ENH moved the start logic into the Run class and change the default operation of start so that it ouputs the process writes unless the process is started detached.
[ENH] add property to return the scripts path.
[FIX] dependencies don't recognize ~ so changed to full path.
Renamed line to value to better reflect its contents.
Moved process related methods into own class.
[FIX] change <group> to <user> in permission line so it was more obvious that the group owner was the user.
[FIX} Changed log.e to printerr as was a true error.
[TEST] Test code for processing pipes as binary data and streaming stderr to stdin for pipes.
[ENH] added logic to format code before releasing it.
[FIX] Changed log.d to settings.verbose as i should be.
[ENH] New tool to allow dshell developer to run from the local source.
[FMT] Formatting.
[FIX] improvements to the shell detection and install logic. code was adding tab complete to zsh which doesn't use the same mechanism as bash.
[FIX] added required path var and remove extranious lines.
[FIX] updated name of docker file to match actual file for install.clone.dart.
Test for binary piping  of stdout and stderr.
formatting
experiment with vscode console:terminal setting.
released ## 1.1.2-dev.1
[ENH] Added verbose logging to  process.start
change the tagname created to match the pubspec version no. as required by pub.dev.
[FIX] NPE if USERNAME environment variable is missing.
[FIX] Spelling.
documentation improvements.
[ENH] work on an automated release script.
[FIX] removed an unecessary getter.
[TEST] additional unit tests for path overrides.
[ENH] added an option to pass a working directory to the start command.
[DOC] improvements.
[FIX] bug in parser that didn't handle quotes within a word.
[FIX] renamed method from loadFromFile to fromFile to be more consistent.
[DOC] improved documentation.
Added optoin to load globaldependeies from a specific path for testing.
ran drtformat.
released 1.1.1
changes to accomodate the new start logic. Pipes need to be wired immediately.
added convenience method lastLine.
coloured the command required to install tab completion.
improved formatting fixed a couple npes.
changed to passing a Progress. Fixed a bug where we were not waiting for the start future and the exist future separately. The result is that an exception could be thrown outside of the watiForEx scope. This result in an uncaught exception occuring on the microtask stack. The end result was tha the shell shutdown in an uncontrolled manner if an exe failed to start.
added unit tests for firstLine and lastLine.
exposed devNull so it could be used by other functions. Changed toList to include but stdout and stderr as that appears to be what users are expecting.
changed to use the standard RunnableProcess rather than its own custom code.
Changed processUntilExit to take a Progress rather than individual action so it could be used bu additional functions.
test code used to understand with with .run.
exposed DartSdk class as it has a no. of useful methods.
changed to correct docker file.
added catch blocks incase ps not supported and some lgging. Implemented new method to get the shell .rc file.
Added shell .rc file to output.
Fixed a bug where when running dshell directly the shell was reported incorrectly.
removed any the usersname and home directory from the output.
work on improving the logic to install dshell to the path.
renamed PID to SHELL
removed unused import.
ran dartfmt over code.
Merge branch 'master' of github.com:bsutton/dshell
released 1.1.1-dev.2
removed unsed import.
added logic to dectect the shell and install the paths accordingly.
removed unfinished code.
scritp to activate dshell on you local path when you are contributing to dshell.
typeo.
added pid class to export list.
added log of 'real' shell.
Update run_unit_tests.yml
Update run_unit_tests.yml
Delete dart.yml
Rename run_unit_tests to run_unit_tests.yml
Create run_unit_tests
created a helper to access PID data.
added firstLine
wrote a tool to run unit tests serially as vscode runs two isolites.
Added new method firstLine which retuns just the first line writtent to stdout.
Fixe for #45 - but I don't have a mac so can't test it.
experimental tool to automate release of dshel
release 1.1.0
reverted back to simpler form as manipulating the env vars of PUB_CACHE and HOME where having some very wierd affects on dart an pub.
test to dump out env vars.
removed unused import.
added getter for path env var.
path reorg.
removed testing log output.
added test that directory exists.
removed the clean. will do in docker.
added call to TestPaths to each library to ensure they are initialised correctly.
added test dshell/bin to front of path so unit tests find the correct version.
changed back to a relative path.
Added logic to do an install of dshell when the test suite starts.
Fixed a bug where printerr was not writing a newline.
Fixed the path to use the new TestPaths
work on unit tests paths using ENV vars so we can run them safely on a local machine.
created truepath method.
added dart:io to default script.
added dart.io to default script as it is very common in dshell scripts.
correct the expected value.
Created the class PubCache to proxy operations/access to .pub-cache. We now honour the PUB_CACHE environment variable.
fixed some unit tests to run on CI server.
release 1.1.0-dev.3
Fixed a bug where a simple file name match was failing. Also improved performance.

## 1.1.2-dev.1
Fix for NPE in doctor when username env variable not available.
Added verbose logging to Process.start.


## 1.1.1
Added support for .zshrc
Added PID class to help get parent pid and shell names. Not certain this is the right structure.
Now have a dshell script that can sucessfully run the unit tests.
Removed data of a private nature from dshell doctor output.
Added new method lastLine on string as process.
Exposed DartSDK class.
Some fixes for shell detection.

## 1.1.1-dev.1
Fix for #45

## 1.1.0
Added support for PUB_CACHE environment var.
Added dart:io to default script we create.
Added check on install to ensure user isn't running as root.
Core unit tests will now succeed in a single pass.


## 1.1.0-dev.3
Fixed a bug where find didn't find a match on a simple file name.

## 1.1.0-dev.2
Added a check if .bashrc exists and create it if it doesn't.
Clean up on the help output.
Improved create error message.
Added --noclean flag to install.
Mad stat method a global function.
Added notes on performance.
Documente envionment variables.

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

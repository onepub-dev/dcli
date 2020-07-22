# 1.9.11
Fixed defaults for runInShell and nothrow for string_as_process stream.

# 1.9.11
Fixed defaults for runInShell and nothrow.

# 1.9.10
Added stream option to string_as_process.
Added the ability to return a stream from a progress.

# 1.9.9
Fixed the fetch unit tests as the download path had moved after re-org of test directory.
Unit tests for VirtualProject.doctor to address #71
Fixed a bug in split where it always tried to create a project even when it already exists.
Added method createOrLoad.  Fixed a bug in the loading of local projects where the pubspec path was not being set correctly.
Fixed doco. Changed getProjectRoot to a getter.
wording.

# 1.9.8
Exposed the Script class as part of the public api as it has some useful methods.
experiments with generating coverage.
Minor documentation fix.

# 1.9.7
FIX: split command now works!

tweaked doco on pubspec locations.
Fixes for activatelocal.dart We now compile the local dshell and set the path correctly. We also change the version no. so you can see that we are running the local version.
added unit tests for annotated pubspecs.
Added tests for the more liberal parsing of annotations.
removed color coding on verbose output as it was distracting.
updated doco to reflect that [local] pubspec also have a projectRootPath that is actual.
Fixed a bug which stripped required indentation on pubspec annotations.
Added unit test for pubspec annotations and enhanced the parser to handle more commenting styles.
Added support for install quiet option to the tab completion installer.
Added printStdErr progression which only prints to stderr.
Added a quiet option to the installer to suppress progress messages.
restructured test folders to match src folders

# 1.9.6
Added a method to remove a symbolic link.


# 1.9.5
enhanced the logic for tradititional builds to work even if the file is deeply nested under a prescribed directory.

# 1.9.4
Fixed lints.

# 1.9.3
Fixed the compile path to .packages for the traditional projects.

# 1.9.2
Dshell was failing to return non-zero exit codes.

# 1.9.1
Fixed a bug in the call to setVerbose when disabling verbose.

# 1.9.0
Added support for running scripts from a standard dart project structure. We now detect the correct pubspec.yaml and run from there.
This is a fairly significant change as it fixes a long standing hole in dshells execurtion model.

Fixed a bug where the releaseLock would be called even when the lock had failed.
Improved the timeout exception so that you actually know the locked timed out. Change the retry interval to 100ms (down from 1s). Now guarentee that at least one lock attempt will be made even if the timeout is less then 100ms.
reverted start returning a progress as that doesn't work as the stream has already been processed by the time start returns. Added a unit test for same.

# 1.8.23
'command'.start() now returns a progress.


# 1.8.22
made tests OS specific.
Fixed duplication of windows paths during install issue.
test script for path manipulation.
move pub_cache back to util.
restored the correct pathSeparator method and renamed it pathDelimiter to make it clearer what its purpose is.

# 1.8.21
Work on improving the windows installer.
Exposed the Env class as it has a number of useful PATH related methods.
Windows Installer now checks that developer mode is enabled so we can use symlinks.

Added resets between pub-cache tests. Looks like join recognizes both slashes so no need to use platform specific slash.
marked reset method in a number of classes as only visible for unit testing. renamed pubcache unitTestrest to reset for consitency.
Looks like c:\ is prefixed also need to reset pubcache between tests.
removed pathSeparator as it duplicated dart Platform functionality.
Fixes for bugs with locating pub cache on windows and added unit tests.
Added addition paths to the windows PATH.
Added pathPutIfAbsent. Also renamed all the path functions to begin with 'path'.
Added pubcache and .dshell/bin to path.
Fixed a bug in the format of setx.
Added dshell path and now launches bash shell to do dev in. Not certain its what we need.
incomplete docker script to do local dev.
Added logic to delete the install dir if it already exists.
Added a check for install preconditions. If they are not met the installer will exit. For powershell we now check that developer mode is enabled as we require this for symlinks. We nolonger allow an install from the old command shell.
Added methods to manipulate the path.
Removed a sperious print statement.
# 1.8.20
Fixed a bug in the default script which had an extra /

# 1.8.19
Work on getting dshell to install under alpine docker image.
reduced progress messages when ansi not supported.
Added logic to move the dart-sdk to the write directory after expanding it. Added execute permissions to files in dart/bin directory. reduced the no. of progress messages.
Now printing out the dir dart is installed into.
Terminal: added method to check if ansi escapses are supported.
suppressed asking the user to confirm the install path.
Fixed a bug where moveTree wasn't actually recursive.
Added a fallback mechanism on linux system to install from the archive if apt isn't found.

# 1.8.18
Fixed a number of bugs around shell detection when one can't be determined.
exists() - added test for null or empty path.
dshell install - added a --nodart option to suppress installation of dart.
Fixed bugs in windows stackframe parsing.
Added install link for windows dshell_install.

# 1.8.17
another script path error.

# 1.8.16
Fixed for doctor when some paths missing.

# 1.8.15
Created github actions to generated linux and windows installer for dshell and dart.
Change copyDir to copyTree.
Changed moveDir to moveTree.
Created new simplified moveDir that just moves the top level dir.
Created a 'fetch' method for downloading files.
add logic to check if shell has a start script. Only trys to add a path when it does.
Fixed a npe when who doesn't return a user.
trying to improve the error message with .run is called and fails.
fixed an npe if the SHELL env var doesn't exist.
change paths to use truepath for consistency.
fixed broken brackets in readme.md
Developed code to download dartsdk from google archive and wrote test for same.
refactored the ansi classes and introduced additional methods for controlling a terminal.
added method to format a double as a percentage.
added cursor management.
dart_install for linux
workflow to create installer each time we do a release.

### 1.8.14
moved mockit to dev dependencies.
For the moment I've wound back the privileged requirements for install as it makes unit tests fail.
fixed unit tests to deal with unordered file lists.
Added logic to handling moving files between partitions. We fallback to doing a copy then delete.
Added .dshell/bin to path during install.
work on improving shell detection
Now using our own version of recase.
now using official pub_release.
changed writeToFile to saveToFile as felt it was more evocative.
removed dependancy on recase as was causing conflicts and we only use one line from it.
now exporting pubspec_file as its a useful class.
Added nothrow option to string start method.
restructured shell related classes as part of work to improve shell detection.
incorrect case in help.
seplling.
Fixed a bug where running 'dshell help <command>' wouldn't print the command help but did print the entire usage.
made the path columns wider.
colour coded the shell name.
fixed warning.
v 0.1.0 of docker cli for dshell.
Work on installing dshell using sudo and as a root user. Added priviledged required message.
The default script was using a relative path when it should be using a package.

# 1.8.14-dev.3
Added null check around sourcePath.

# 1.8.14-dev.2
Removed ReCase as a dependency as its used in lots of other project causing dependency conflicts.

# 1.8.14-dev.1
Work on improving shell detection.
Added nothrow to string_as_process start method.
Exposed PubSpec_File class as part of the public api.

### 1.8.13
fixed indentation problem. released 1.8.13
exposed SortDirection required for FileSort.
applied effective dart.
Had max/min back to front for Menu options.

### 1.8.13-dev.1
[ENH] Work on a docker based cli for dshell.
[FIX] unknown shell no returns false for priviliged user to avoid npe.
[Fix] for macos which by default only supports 127.0.0.1.
[ENH] added logic to fix permission when dshell rans as root.
[FIX] bug when determing pub-cache path if environment variable set.
[ENH] added new methods loggedInUser and isPrivilegedUser.
[ENH] released dshell_install as a binary so people could easily install dshell.

### 1.8.12
[ENH] created a command to upgrade dshell.
[DOC] cleaned up the public interface by making a number a items private.
[IMP] changed color for command messages for consistency.
[IMP] removed clean all as when you first install as there should be no projects. dshell upgrade on the other hand does need to do a clean all.
[IMP] cleaned up invalid argument processing.
[FIX] Fixed a bug which allowed install to be run from sudo.

### 1.8.11
[enh] adding validation to ask.
[imp] moved the cleanall after the install has completed so that compile errors don't stop the install completeing.
[bug] Fix for Service.getIsolateID returning null in compiled script. The hashcode should be a stable substitute. The question is why is getIsolateID only failing in some compiled scripts.

### 1.8.10
Fixed bug in glob expansion where a relative path with ../ was mistaken for a hidden path.

### 1.8.9
second go at fixing the compile install bug.

### 1.8.8
[BUG] dshell compile was failing to install due to move bug.

reformatted error so you can copy paste cmdline for testing.
bug in move as overwrite did not have a default value.

### 1.8.7
[ENH] added copyDir and moveDir functions.

### 1.8.6
[BUG] bug in the quote handling of startsWithArgs

### 1.8.5
[ENH] Exposed NamedLock as part of the official dshell api.
    Tidied up the NamedLock documentation and removed internal implementation from the api. 
[ENH] changed how we handle quoted arguments when the startWithArgs method is called. We no longer strip quotes from passed arguments because if you pass quotes you probably really need them to be there. This differs from passing cmdLine where we need to strip the quotes as bash does.
[ENH] added logic to suppress color codes if terminal doesn't support them.
[ENH] added support for backspace when entering hidden text for ask.
[CLEANUP] dog fooding the internals of VirtualProject.

### 1.8.4

This release is primarily about getting dshell to work correctly under windows.
There is still a no. of significant issues that need to be resolve for windows.
This release however has sufficient improvements for general dshell users that I thought it was time for a release.
The core windows issues is that dart2native doesn't support symlinks so compilation doesn't work.
This is affecting unit tests so its a little hard to evaluate just how stable the windows release.
Having said that it does look like dshell is broadly working under windows.
I will be attempting to resolve these issues over the next week or so.

This release also fixes an issue that Mac uses had that stopped them compiling dshell.
It appears that the logger package has a problem (Invalid cid) that stopped compilation on Mac, windows and Rasp Pi. I've removed this package and now compilation seems to work fine.




### 1.8.3
[fix] Compile fixes when project has local pubspec.yaml.
[enh] Added experimental parser to string_process which allows reading and parsing a number of common file formats.
[enh] Added glob expansion when running command lines.
[enh] New NamedLock class provides an inter isoloate and inter process locking mechanism.
[enh] Improvements to documentation.
[enh] New method on FileSync to create a temp file.
[enh] Version of start which takes a command and an arg array to provide a simplified path
when complex escaping is involved.
[fix] For unit test so that all test can now complete in a single run.
[fix] Start was not passing the Progress down.
[fix] Bug in tab completion when expanding scripts.
[fix] Two compiler bugs. It was trying to compile scripts in subdirectories when we are only meant to compile scripts in the current directory.  Fixed bug where local pubspec.yaml was being ignored.

### 1.8.3
Added start method which takes an arg array to avoid escaping lots of quotes.



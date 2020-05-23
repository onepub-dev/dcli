### 1.8.13
exposed SortDirection required for FileSort.
applied effective dart.
Had max/min back to front.

### 1.8.13
applied effective dart.
Had max/min back to front for the menu class options.

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



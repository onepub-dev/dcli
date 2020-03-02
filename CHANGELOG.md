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

### 1.8.3-dev.5
[fix] Change package paths to point directly to the .packages file. Hopefull this will allow compile to work correctly for both local and virtual pubspecs.
[enh] Renamed RunnableProcess ctors to make it clearer what each one does.
[fix] NamedLock changed arg from lockSuffix to name
[enh] Added toJson method. Added doco on glob expansion.

### 1.8.3
[fix] Change package paths to point directly to the .packages file. Hopefull this will allow compile to work correctly for both local and virtual pubspecs.
[enh] Renamed RunnableProcess ctors to make it clearer what each one does.
[fix] NamedLock changed arg from lockSuffix to name
[enh] Added toJson method. Added doco on glob expansion.

### 1.8.3-dev.4
change the lambda description to the more consisely named format.
Improved the documentation on avoiding cd/pushd/popd.
Added which.dart as used by test scripts.
Added logic so we don't try to add to the stream after it is closed.
rework of run.
Fixed the reset logic for mocks.
Fixed the reset logic. Added logic so that callen setEnv with a null value removes the key from the map.
Added validation that the passed argument is a script.

### 1.8.3-dev.3
[fix] glob expansion needed to use the workingdirectory to expand the correct files.
updated the doco on dependency injection to reflect the fact that we don't inject if there is an actual pubspec.yaml.
Documented the 'includeHidden' param.
[fix] Fixed a number of unit test so the work correctly under the TestFileSystem.

### 1.8.3-dev.2
[enh] Creation of a inter-process and inter-isolate locking mechanism [NamedLock]. Improved locking documentation and added logic to release locks when exceptions occur.
[enh] Added ability to share a single TestFileSystem amoungst multiple tests. Speed up the unit testing by copying the primary .pub-cache to each test file system. Also sets the path and Settings to point to the test file system.
[fix] start() was not passing down 'progress' arg if passed.
[fix] Fixed glob expansion and added expansion of ~.
[fix] Extended test timeouts to deal with longer runtime when using TestFileSystem.
[fix] bug in tab completion with expanding scripts.
[enh] Improvements to doco for find()
[fix] Creation of new TestFileSystem designed to allow unit tests to run in an somewhat isolated file system so they don't damage the dev environment.
[enh] improved the error message when start can't find the executable on the path.
[fix] Fixed a bug where the processed args for glob expansion were being dumped on the ground.
[enh] Added logic to reset Settings() paths after HOME is reset.
optimistically a working interprocess locking system.
[enh] moved install tests into main test dir as with the new TestFileSystem they can be run as part of the normal test suite.
[imp] Moved the parser into its own dart file along with initial work on glob expansion.
[enh] Added a method to FileSync to generate a temp file.
[enh]Added a file to indicate a successful install.
[exp] experiments in creating a dshell dev env within a docker container.

### 1.8.3-dev.1
Added start method which takes an arg array to avoid escaping lots of quotes.

### 1.8.3
Added start method which takes an arg array to avoid escaping lots of quotes.


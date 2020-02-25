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


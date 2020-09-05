# Managing Files And Directories

## Manage files and directories

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

DCli provides a complete set of tools for manipulating files and directories.

DCli also includes the [paths](https://pub.dev/packages/path) package that provides tools for manipulating file paths.

A fundamental task of most CLI applications is the management of files and directories. DCli provides a large set of tools for file management.

### pwd

The getter 'pwd' returns the present working directory.

```dart
print(pwd);
```

Whilst you can change your working directory we don't recommend it. Read the section on the [evils of cd](the-evils-of-cd.md).

If you think you need to change your working directory check to see if the DCli function takes a 'workingDirectory' argument.

If you need to spawn another cli application that needs to run in a specific directory use the '[start](calling-apps.md#start)' function.

If you really think you have no alternative the you can use the dart method Directory.current.

### Find

The find command lets you explore your file system by searching for files that match a glob \(wildcard\).

```dart
List<String> results = find('[a-z]*.jpg').toList();
```

The find command starts from the present working directory \(pwd\) searching for any files that start with the lowercase letters a-z and ending with the extension '.jpg'.

The default action of find is to do a recursive search. 



```dart
List<String> results = find('[a-z]*.jpg', root: '\' ).toList();
```

If you need to do a search starting from a location other than you current directory you can use the 'root' argument which controls where the find starts searching from.



```dart
List<String> results = find('[a-z]*.jpg', root: '\', hidden: true ).toList();
```

The find command will ignore hidden files \(those starting with a '.'\) and directories. If you need to scan hidden files and directories then pass 'hidden: true'.



```dart
var progress = Progress((file) => print(file));
find('*.jpg', root: '\'
  , types:[FileSystemEntityType.directory, FileSystemEntityType.file]
  , progress: progress);
    
```

If you are process a large amount of results you may want to process them as you go rather than waiting for the full result list to be available.

By passing a progress into the find your progress will be called each time a matching file is found allowing to display the progressive results to the user.

### fileList

Returns the list of files and directories in the current working directory. Used the 'find' function to get a list of any other directory.

```dart
List<String> entities = fileList;
```

### copy

The copy function copies a single file to a to a directory or a new filename.

```dart
copy("/tmp/fred.text", "/tmp", overwrite=true);
copy("/tmp/fred.text", "/tmp/fred2.text", overwrite=true);
```

The first example will copy the file 'fred.text' to the '/tmp' directory, the second file also copies the file to the '/tmp' directory but renames the file as it goes.

If the 'overwrite' is not passed or is set to false \(the default\) an attempt to copy over an existing file will cause an exception to be thrown.

### copyTree

The copyTree function allows you to copy an entire tree or selected files from the tree to another location.

The copyTree function takes an optional 'filter' argument which allows you to selectively copy files. On those files that match the filter are copied.

```dart
copyTree("/tmp/", "/tmp/new_dir", overwrite:true, includeHidden:true
   , filter: (file) => extension(file) == 'dart');
```

The above copyTree only copies files that have an '.dart' extension.

### move

The move function copies a single file to a path or a file. If the 'to' argument is a file then the file is renamed.

The move function tries to use the native OS 'rename' function however if the destination is on a different device the rename will fail. In this case the move function performs a copy then delete.

```dart
move('/tmp/fred.txt', '/tmp/folder/tom.txt');
```

### moveTree

The moveTree function allows you to move an entire tree or selected files from the tree to another location.

The moveTree function takes an optional 'filter' argument which allows you to selectively move files. Only those files that match the filter are moved.

```dart
moveTree("/tmp/", "/tmp/new_dir", overwrite: true
   , filter: (entity) {
   var include = extension(entity) == 'dart';
   if (include) {
     print('moving: $file');
   }
  return include;
);
```

Like the move function the moveTree attempts an OS level rename but if that fails it resorts to performing a copy followed by a delete.

### delete

The delete function deletes a file.

```dart
delete("/tmp/test.fred", ask: true);
```

If you pass the 'ask' argument to the delete function then the user will be prompted to confirm the delete action. 

### deleteDir

The deleteDir function deletes a directory.

```dart
deleteDir("/tmp/testing";
```

If the directory isn't empty then a DeleteDirException will be thrown.

You can delete an entire directory tree using the recursive option:

```dart
deleteDir("/tmp/testing", recursive=true);
```

### createDir

The createDir function creates a directory.  If the directory already exists then a CreateDirException will be thrown.

```dart
if (!exists('/tmp/fred/tools')) {
    createDir("/tmp/fred/tools");
}
```

If the parent path doesn't exists then a CreateDirException will be thrown, to avoid this pass the recursive argument

```dart
createDir("/tmp/fred/tools", recursive: true);
```

### touch

The touch function updates the last modified date/time stamp of the passed file. If the 'create' argument is passed and the file doesn't exists then the file will be created.

```dart
touch('fred.txt, create: true');
```

### exists

The exists function checks if a file, directory or symlink exists.

```dart
if (exists("/fred.txt"))
```

### isWritable

Test if a file or directory is writable.

```dart
if (isWritable('/fred.txt'))
```

### isReadable

Test if a file or directory is readable.

```dart
if (isReadable('/fred.txt'))
```

### isExecutable

Test if a file or directory is executable.

```dart
if (isExecutable('/fred.txt'))
```

### isFile

```dart
if (isFile('/fred.txt'))
```

### isLink

```dart
if (isLink('/fred.txt'))
```

### isDirectory

```dart
if (isDirectory('/fred.txt'))
```

### setModified

Sets the last modified date/time stamp on give path..

```dart
setLastModifed('/fred.txt', DateTime.now());
```

### lastModified

Returns a DateTime reflecting the last modified date/time stamp of the given path.

```dart
DateTime modified = lastModifed('/fred.txt');
```


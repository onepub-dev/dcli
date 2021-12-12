# Posix

Linux and MacOS both include a posix subsystem. This essentially means that they have a set of APIs and commands that conform to the posix stands.

DCli exports a number of posix specific commands.

To access these commands you need to import DCli's posix library.

```dart
import 'package:dcli/posix.dart';
```

## DCli posix specific functions

### chmod

Sets the permissions on a file on posix systems.

### chown

Sets the owner of a file on posix systems.


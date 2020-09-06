# Added DCli to your project

If you are just using the DCli API \(and not the DCli tools\) then adding DCli to your existing app is like adding any other Dart package to your app.

Go to [pub.dev](https://pub.dev/packages/dcli/install), find the section 'Depend on it' and copy the indicated dcli dependency into your pubspec.yaml:

```text
dependencies:
  dcli: ^0.24.0
```

From the same directory that your pubspec.yaml lives in run:

```text
pub upgrade
```

Now in your Dart code, you can use:

```text
import 'package:dcli/dcli.dart';
```

You now have access to the full DCli API.


# Ship a DCli app in Docker

DCli is designed to work with docker and makes for an easy method of developing a Docker based app.

The following is an example Dockerfile showing how to ship a single DCli app in Docker

```docker
FROM google/dart as build

RUN mkdir /src
WORKDIR /src
RUN git clone https://github.com/noojee/pci_file_monitor.git

# remove the git clone and uncomment this lines for local dev.
# COPY pci_file_monitor /src/pci_file_monitor

WORKDIR /src/pci_file_monitor

RUN dart pub get
RUN dart compile exe /src/pci_file_monitor/bin/pcifim.dart -o /pcifim


# Build minimal  image from AOT-compiled `/pcifim`
FROM build
COPY --from=build /pcifim /pcifim
WORKDIR /
RUN /pcifim install

# Run a base line and schedule scans.
ENTRYPOINT ["/pcifim", "--quiet", "--no-colour", "cron", "--baseline", "30 22 * * * *"]

# remove the ENTRYPOINT and uncomment this line to enable interactive debugging.
# CMD ["bash"]

```

The above example use the `pci_file_monitor` project to show the steps required to run a DCli app in docker.

{% embed url="https://github.com/noojee/pci_file_monitor" %}

`pci_file_monitor` is a real app and a useful reference.

Of particular note `pci_file_monitor` includes its own cron daemon which allows it to schedule itself without requiring the Docker image to contain cron (which is rather difficult to do).

To build the docker image run:

```
docker build -t <imagename> .
```

`To run the docker image:`

```docker
docker run <imagename>
```

To debug the image, comment out the 'ENTRYPOINT' and uncomment 'CMD'

You can now connect to the docker image:

```docker
docker run -it <imagename> /bin/bash
```

### Publish your docker image

The following DCli script is from the dcli\_scripts project and automates pushing your app into docker hub.&#x20;

You will need a docker hub account.

Place the script in your dart project tool directory (or alternatively activate dcli\_scripts).

```dart
#! /bin/env dcli

// ignore_for_file: file_names
import 'dart:io';

import 'package:dcli/dcli.dart';

void main(List<String> args) {
  var parser = ArgParser()
    ..addOption('repo',
        abbr: 'r',
        mandatory: true,
        help: 'The name of the docker repository to publish to.');
  var project = DartProject.fromPath('.', search: true);
  var projectRootPath = project.pathToProjectRoot;
  print('projectRoot $projectRootPath');

  ArgResults parsed;
  try {
    parsed = parser.parse(args);
  } on FormatException catch (e) {
    printerr(red('Invalid CLI argument: ${e.message}'));
    exit(1);
  }

  var repo = parsed['repo'] as String;
  var projectName = project.pubSpec.name;
  var version = project.pubSpec.version;
  var name = '$repo/$projectName';

  var imageTag = '$name:$version';
  print('Pushing Docker image $imageTag.');

  print('docker path: ${findDockerFilePath()}');
  print(green('Building $projectName docker image'));
  'docker build -t$imageTag .'.start(workingDirectory: findDockerFilePath());
  print(green('Pushing docker image: $imageTag and latest'));
  var latestTag = '$name:latest';
  'docker image tag $imageTag $latestTag'.run;
  'docker push $imageTag'.run;
  'docker push $latestTag'.run;
}

String findDockerFilePath() {
  var current = pwd;
  while (current != rootPath) {
    if (exists(join(current, 'Dockerfile'))) {
      return current;
    }
    current = dirname(current);
  }
  return '.';
}

```

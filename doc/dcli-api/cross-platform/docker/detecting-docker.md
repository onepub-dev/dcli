# Detecting Docker

The DCli api allows you to detect if you are running in a Docker container

## DockerShell

DCli has the ability to detect which shell (bash, powershell, zsh etc) that you are running under.

If you DCli app is used as the Docker ENTRYPOINT then your parent won't be a shell.

In this case calling Shell.current will return a DockerShell:

```dart
DockerShell shell = Shell.current;
```

Attributes of DockerShell.

* shell name is 'docker'&#x20;
* loggedInUser = 'root'
* isPrivilegedUser will always be true

## Detecting if you are running in a Docker&#x20;

Using DockerShell to detect if you are in a Docker container is not reliable as in some circumstances you DCli app will be run from within a standard shell (bash etc) within Docker

Instead use:

```dart
if (DockerShell.inDocker)
{
    /// do something docker
}
```

This method looks for the presence of /.dockerenv which Docker guarantee will exist.

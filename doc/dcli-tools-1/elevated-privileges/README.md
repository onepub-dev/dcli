# Elevated Privileges

Often you need to run a script with elevated privileges.

On Linux and OSX this means using sudo, on Windows it means using 'Run as Administrator'.

DCli abstract Linux/OSX sudo and Windows Administrator into a single concept of 'elevated privileges'.

In DCli you can check if your script is running with elevated privileges by calling isPrivilegedUser

```text
 if (!Shell.current.isPrivilegedUser) {
    printerr(
       'Please restart ${Script.current.exeName} using with elevated privileges');
    exit(1);
  }
```

## Windows

Under Windows elevated privileges are pretty simple.

If any part of your script needs to run with elevated privileges then just use the 'Run as Administrator' option in windows.

You should add a call to `Shell.current.isPrivilegedUser` at the start of the script and force users to restart with the required privileges.

## Linux/OSX

Under Linux/OSX privileged operations for more problematic.

If you need the entire script to run escalated then use the above `isPrivilegedUser` method however often you will want to only use escalated privileges in some of your script in which case the `isPrivilegedUser` check doesn't make sense.

Read the page on [sudo](sudo.md) for additional details and some of the problems you will encounter and how to solve them.




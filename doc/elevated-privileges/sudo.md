# Sudo

You will often want to run a DCli script using sudo.

Using sudo can complicate things:

There are two core issues:

1\) on debian (and probably other distros) sudo has its own path which is unlikely to include the dart or dcli paths.

2\) when trying to run a dart script you may cause the pub cache to be update at which point it will be owned by root and your normally user account won't be able to access it.

If you do this by mistake you can run the following command to fix the problem.

```bash
sudo chmod -r $USER:$USER ${HOME}/.pub-cache
```

3\) You only want parts of your script to run as privileged.

{% hint style="info" %}
The following dart code also works on Windows. The privilege options simply check that you are running as an Administrator and throw an exception if you are not. Running as a Windows Administrator does not have the same problems that sudo introduces.
{% endhint %}

## Solutions

The following provides guidelines on how to solve the problems.

1\) where ever possible avoid using sudo. Of course this often just isn't practical

2\) use the 'start' function and pass in the privileged flag:

```
'chmod +x script.dart'.start(privileged: true);
```

The privileged flag will check if you are running as sudo, if not it will run the chmod script under sudo. This will cause sudo to prompt the user for their sudo password.

This is a good technique as it limits the use of sudo to just those parts of the script that actually need sudo.

3\) compile the script.

Compiling your dart script has a number of benefits.

A compiled script is a completely self contained executable which means it will never cause your pub cache to be accessed which means sudo won't screw it up.

It also fixes the path issues as you don't need dart or dcli on your path for the script to run.

```
dcli compile script.dart
sudo ./script
```

3\) pass your path down to sudo

```
sudo env "PATH=$PATH" <my dcli script>
```

This technique passes your existing user path into sudo which means it can find both dart and dcli.

This method is still dangerous as if dart decides your script needs to be updated then your pub cache will become owned by root.

4\) Use withPrivileges

The intent is to allow you to start your script with sudo but only the parts of your script to that need sudo will actually use it.

We still recommend you compile your script to avoid dart changing permissions on pub-cache.

You do this by starting your script with sudo but immediately downgrading your sudo access when the script starts and then using the withPrivileges method for those parts of your script that need to run as sudo.

```
// get_keys.dart
void main()
{
    /// downgrade script to not run as sudo
    Shell.current.releasePrivilege();
    
    ... do some non-sudo things
    
    /// any code within the following code block will be run
    /// with sudo privileges.
    Shell.current.withPrivileges(() {
        copyTree('\etc\keys', '\some\insecure\location');
    });
}
```

To run the above script:

```
dcli compile get_keys.dart
sudo ./get_keys
```

5\) Pass a password into sudo

If you a trying to run sudo without user intervention then you are likely going to have to pass the password to sudo.

A typically scenario might be calling scripts on a remote system over ssh

he safest way to do this is to:

* create a file with 600 as the password (so only you have read/write access)
* write the sudo password into that file
* create and compile a dart script that can output the password
* run sudo -A to run you command and retrieve the password.

Create a script to ask the user for the sudo password

Name the following script something like sudo\_ask.dart

In the real world creation of the password file would happen in another part of your code base.

```dart
void main() {
  var password = ask('sudo password:');
  var pathToPassword  = 'sudo.p';
  touch(pathToPassword, create: true);
  chmod(600, pathToPassword);
  pathToPassword.append(password);
 
}
```

Create a script to be called by sudo when it needs the password:

Call this script sudo\_askpass.dart

```
void main()
{
    var pathToPassword = 'sudo.p';
    var password = pathToPassword.read().first;
    print(password);
    /// clean up the password file unless you need it again 
    /// during this run.
    delete(pathToPassword);
}
```

Create and compile the DCli script that you want to run under sudo.

as well as the sudo\_ask.dart script.

```
dcli compile sudo_askpass.dart
dcli compile worker.dart
```

Run the script under sudo

```
./sudo_ask.dart
SUDO_ASKPASS=sudo_ask && sudo -A worker
```


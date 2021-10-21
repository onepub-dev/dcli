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

Name the following script something like sudo\_ask.dar

```dart
void main() {
  var password = ask('sudo password:');
  var pathToPassword  = 'sudo.p';
  touch(pathToPassword, create: true);
  chmod(600, pathToPassword);
  pathToPassword.append(password);
 
}
```

Create and compile the DCli script that you want to run under sudo.

as well as the sudo\_ask.dart script.

```
dcli compile sudo_ask.dart
```

kGitBookLater today![Teammate profile](https://js.intercomcdn.com/images/attention.6a6e4cbc.png)We may not be able to reply as fast as usually, but we are working on fixing issues and will get back to you eventually.I need help from Support![GitBook profile](https://static.intercomassets.com/avatars/3797458/square\_128/custom\_avatar-1619024365.png?1619024365)😀 Please note we have launched a major update. We are working on fixing a few issues.Please check [https://www.gitbookstatus.com](https://www.gitbookstatus.com) to see if any open incident may be affecting you. You can also subscribe to get updates.**A member of the team will read your message soon**. Please share as much detail as possible. Screenshots, along with your **'app.gitbook.com/...'** account or space link may help.\
\
We usually try to respond within a business day, and we're aiming to provide our usual quick responses. However, we may be dealing with a higher volume of questions, so **it could take us a little longer to get back to you.**I've just logged into see the major update.My problem is that code blocks are completely broken.The problem seems to be around cursor management. After creating a code block and the leaving it the cursor placement is broken. As I type the cursor seems to jump to some previous location that the cursor had been on. Not certain if the auto save plays a part in this because as soon as a type a character it starts saving.As it stands I can't edit a page with code blocks in it.Just now. Not seen yet

```
```

\
GitBookLater today![Teammate profile](https://js.intercomcdn.com/images/attention.6a6e4cbc.png)We may not be able to reply as fast as usually, but we are working on fixing issues and will get back to you eventually.I need help from Support![GitBook profile](https://static.intercomassets.com/avatars/3797458/square\_128/custom\_avatar-1619024365.png?1619024365)😀 Please note we have launched a major update. We are working on fixing a few issues.Please check [https://www.gitbookstatus.com](https://www.gitbookstatus.com) to see if any open incident may be affecting you. You can also subscribe to get updates.**A member of the team will read your message soon**. Please share as much detail as possible. Screenshots, along with your **'app.gitbook.com/...'** account or space link may help.\
\
We usually try to respond within a business day, and we're aiming to provide our usual quick responses. However, we may be dealing with a higher volume of questions, so **it could take us a little longer to get back to you.**I've just logged into see the major update.My problem is that code blocks are completely broken.The problem seems to be around cursor management. After creating a code block and the leaving it the cursor placement is broken. As I type the cursor seems to jump to some previous location that the cursor had been on. Not certain if the auto save plays a part in this because as soon as a type a character it starts saving.As it stands I can't edit a page with code blocks in it.Just now. Not seen yet

```
```

\


```bash
dcli compile sudo_work.dart
```

Run the script under sudo

```
SUDO_ASKPASS=
```

**xport SUDO\_ASKPASS=/home/$username/asker.sh && SUDO\_PASSWORD=$sudoPassword sudo -A**

# Glob Expansion

Glob Expansion refers to the expansion of wildcards \(\*.txt\) into a list of files.

When you type a command such as 'ls \*.txt' on the command line the shell expands the '\*.txt' wildcard \(referred to as a glob\) to a list of files that match the given wildcard.

As a result of Glob expansion the 'ls' command receives a list of files that end in \*.txt rather than the original glob.

If no files match the glob then the 'ls' command receives the actual glob '\*.txt'.

{% hint style="warning" %}
Glob Expansion does not occur on Windows as neither PowerShell nor Command do glob expansion.
{% endhint %}

Glob expansion is sometimes undesirable. A classic example of this is the linux find command:

```bash
find / -name "*.txt"
```

If the '\*.txt' glob was expanded then the find command would be passed a list of files in the current directory which is clearly not the intent. By wrapping the glob with quotes you are telling bash not to expand the glob but to pass '\*.txt' directly to the find command so it can process the glob against each directory it visits.

DCli uses the same process. If you encase a glob in quotes then DCli will not expand the glob.

```dart
'chmod -R +x "*.dart"'.run;
```

In the above example DCli sees that the glob is wrapped in quotes and as such passes the glob to chmod without first expanding it.




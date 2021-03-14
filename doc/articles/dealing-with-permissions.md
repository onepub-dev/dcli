# Dealing with permissions

When writing cli apps you will invariably have to deal with file permissions and access rights in general.

DCli provides a number tools and methods to help deal with permissions including tools that assist with cross platform development \(linux/windows/osx\).

## Run an app with escalated privileges 

One of DCli's strengths is its ability to spawn child cli apps:

```text
'grep debug *.log'.run
```

The above command will spawn grep as a child process and print its output to the cli.

Under Linux and OSX 




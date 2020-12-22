# Contributing

## Overview

The process for contributing to DCli is pretty standard for github projects.

Fork this [dcli](https://github.com/bsutton/dcli) github project and clone it to your local system.

Check the list of Issues for any open bugs or enhancements marked as help wanted or if you want to work on something new then raise an issue describing the work.

If you are working on an issue add a comment to the issue so that other people know that its underway. Make note of when you hope to complete the task so we know if the effort has gone stale.

Make your code changes and submit a Pull Request.

## No Futures

You are likely to need to use futures under the hood but the user level API that DCli exposes MUST not expose any futures. Use waitForEx to absorb any futures.

OK, so there are likely to be exceptions to this rule but please discuss you plans and the need for exposing a Future before starting work so you aren't disappointed when it gets rejected \(no good idea is likely to be rejected\).

## Exceptions and exit code

All exceptions thrown MUST be extended from DCliException.

Invalid command line arguments MUST throw an exception that derives from CommandLineException

Return codes are pure evil and they are the reason Exceptions were invented.

If any OS command is called and it returns a non-zero exit code then you MUST throw an exception derived from DCliException. We do support the 'nothrow' option on a number of commands as non-zero exit codes don't always mean that the call failed.

## Global Settings

The Settings class is the correct place to store any global settings.

## Coding Standards

Note:

* dcli uses pedantic lint rules and as such ALL code MUST be fully compliant. Suppressing lint warnings will normally not be accepted.
* Use of `dynamic` is almost never acceptable.

## Things to check:

* Ensure that your code has been formatted using drtfmt before committing your code.
* Ensure that you code has no warnings or errors with the exclusion of TODOs.
* Comment your code.
* Fully Document any methods/functions/classes that are exposed as part of the public API
* Ensure that methods/functions are short and readable. Split your methods if they start getting large.
* Include unit tests for your code.
* Ensure that your code doesn't break any existing unit tests.
* Use good function names and variables. Abbreviations are rarely acceptable.
* Be nice to your mother.

## The development cycle

Start by forking the dcli project on git hub

[https://help.github.com/en/github/getting-started-with-github/fork-a-repo](https://help.github.com/en/github/getting-started-with-github/fork-a-repo)

Now clone the fork to your local machine:

```text
cd ~
git clone https://github.com/YOUR-USERNAME/dcli
```

You are now ready to start making a contribution to DCli.

As a developer and user of DCli you will want to maintain a running version of DCli and a your development version.

DCli ships with a Docker container provides a cli specifically for running tests using your development source.

The container mounts your local DCli source folder. This allows you to edit the source with your preferred editor \(I use vscode\) and run code and run test using the Docker cli.

You can also run code directly in vscode

The dcli source code ships with a no. of tools \(written in dcli\) to help you cycle between developer and user mode.

The dcli tools are located under the dcli/tool directory.

#### activate\_local.dart

Running activate\_local will update your dcli install to use your local source rather than the dcli installed into your pub-cache.

You MUST NOT run activate\_local from within the dcli directory!!!

To run activate\_local:

If your dcli development tree is located at ~/dcli

```text
cd ~
dcli/tool/activate_local.dart --path ~/dcli
```

To switch back to the pub-cache version of dcli

```text
pub global activate dcli
```

### 

### Raising a Pull Request \(PR\)

[https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request)

Your PR should be created on a separate branch to allow it to be merged and tested against the DCli repository before we merge it into the DCli main branch.

To have your code changes accepted into the main DCli repository on github you will need to create a PR.  



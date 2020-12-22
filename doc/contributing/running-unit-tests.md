# Running Unit tests

### Running unit tests.

{% hint style="info" %}
I recommend running units test from a Docker container as described below.
{% endhint %}

Running DCli unit tests can be a little tricky as they perform write operations on your file system. In particular the install unit tests will delete your dcli installation which is rather inconvenient.

DCli ships with a number of tools to help you manage this problem.

DCli unit tests are split into two folders. `dcli/tests` is the standard location for unit tests. You can run these unit tests from within vscode using the standard unit test tools.

These unit tests all write to your `/tmp` folder and are safe to run.

You can also run the unit tests from the cli by running:

```text
cd ~/dcli
tool/run_unit_tests.dart
```

## Docker

Alternatively you can run the unit tests from a docker container as noted below.

The unit tests are, by design, destructive as they need to delete your current dcli install and recreated it.

To avoid interfering with your local system the DCli source includes a number of docker containers to run your unit tests.

Under the `dcli/docker/test` folder you will find docker containers and dcli scripts to run those containers.

There are two methods available for running the scripts:

* use your local dcli source
* clone from git hub

Use the local source is safe and slightly faster so is the preferred option.

## Run from Local source

`install.local.df and install.local.dart`

The install.local pair allow you to run the unit tests using your local dcli source. To run the install unit tests run:

```text
cd dcli/docker/test
./install.local.dart
```

## Run for git clone

`install.clone.df and install.clone.dart`

This pair runs the install scripts by first cloning the git repo and running the scripts against the cloned repo.

The docker file pulls the repo from the main dcli github site. You may want to modify the repo to point to your forked repo.

To run the dcli install unit tests from the cloned git repo run:

```text
cd dcli/docker
./install.clone.dart
```


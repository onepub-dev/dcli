# Running Unit tests

### Running unit tests.

Running DCli unit tests can be a little tricky as they perform write operations on your file system. In particular the 'install' unit tests will delete your dcli installation which is rather inconvenient.

Dcli uses the dart critical test package for running unit tests.

pub global activate critical\_test

Whilst you can run most tests from the vs code unit test framework there are number of tests that require pre-setup as well as sudo/admin privileges. The critical test package has the ability to run pre/post hooks to establish the environment to run these tests.



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

```
cd dcli/docker/test
./install.local.dart
```

## Run for git clone

`install.clone.df and install.clone.dart`

This pair runs the install scripts by first cloning the git repo and running the scripts against the cloned repo.

The docker file pulls the repo from the main dcli github site. You may want to modify the repo to point to your forked repo.

To run the dcli install unit tests from the cloned git repo run:

```
cd dcli/docker
./install.clone.dart
```

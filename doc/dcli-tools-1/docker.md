# Docker



DCli is designed to work with Docker.

DCli has a Docker image you can use directly or use in a Docker 'from' statement.

You can also add DCli to an existing Dockerfile.

## Adding DCli to your Dockerfile

You can add DCli to your own Dockerfile. This will allow you to run DCli scripts as part of the Docker deployment process as well as running DCli scripts within the final docker container.

DCli is installed into the root user \(as is normal for a Docker container\). Installers exist for Linux, Windows and Mac OSX.

Just change the wget path to obtain the correct installer:

Linux path

```text
RUN apt-get -y update
RUN apt-get install --no-install-recommends -y wget ca-certificates gnupg2 procps
RUN wget https://github.com/bsutton/dcli/releases/download/latest-linux/dcli_install
RUN chmod +x dcli_install
ENV PATH="${PATH}":/usr/lib/dart/bin:"${HOME}/.pub-cache/bin":"${HOME}/.dcli/bin"
RUN ./dcli_install
```

Windows path:

```text
RUN wget wget https://github.com/bsutton/dcli/releases/download/latest-linux/dcli_install.exe
# TODO correct this path
ENV PATH="${PATH}":/usr/lib/dart/bin:"${HOME}/.pub-cache/bin":"${HOME}/.dcli/bin"
RUN ./dcli_install.exe


```

Mac OSX path:

```text
RUN wget wget https://github.com/bsutton/dcli/releases/download/latest-osx/dcli_install -O dcli_install
RUN chmod +x dcli_install
# TODO correct this path
ENV PATH="${PATH}":/usr/lib/dart/bin:"${HOME}/.pub-cache/bin":"${HOME}/.dcli/bin"
RUN ./dcli_install


```

## Compiling a dart package

Now you have dart and dcli in your container you will want to import a project and compile it.

```text
# now lets compile a script.
RUN mkdir -p /build/bin
RUN mkdir -p /build/lib
COPY pubspec.yaml /build
COPY bin /build/bin/
COPY lib /build/lib/
# The --install option adds the compiled script to your path.
dcli compile --install bin/<your script>
```

### Upgrading DCli in your docker image.

After building your docker image you may need to force an upgrade of the DCli version.

You can simply recreate your docker image or to save time you can just up use this one trick \(sorry\) to force docker to just rebuild the DCli install \(and subsequent steps in your docker file\).

Add the following line just before the call to wget.

If you want to force an upgrade of DCli just increment the no. and run docker build.

```text
ARG PULL_LATEST_DSHELL_INSTALL=1
```

## Using the DCli docker image

A Docker image is available which can be used to create a DCli CLI on your system without polluting your OS.

The docker container presents a CLI with dart and DCli pre-installed so you can experiment with DCli or deploy DCli to system instances.

To use the container:

Create a volume so that your scripts are persistent:

```text
docker volume create dcli_scripts
```

Attach to the DCli cli.

```text
docker run -v dcli_scripts:/home/scripts --network host -it dclifordart/dcli /bin/bash
bash:/> cd /home/scripts
bash:/home/scripts> dcli create hellow.dart
```

The volume is mounted to `/home/scripts` within your dcli container.

vi is included in the container.

Alternatively you can install and run dcli directly from your cli.

## git based dependencies

dart allows you to include dependencies which are pulled from a git repo.

e.g.

```text
dependencies:
  gcloud_lib: 
    git: 
      url: git@bitbucket.org:myrepo/gcloud_lib.git 
      path: gcloud_lib
```

If your git repository is public then you don't need to do anything special.

If your git repository is private then calling `pub get` or attempting a `dcli compile` will fail with an auth error.

If this is your scenario then you may need to make your .ssh keys available to the docker build.

This blog article provide a details on how to achieve this.

[http://blog.oddbit.com/post/2019-02-24-docker-build-learns-about-secr/](http://blog.oddbit.com/post/2019-02-24-docker-build-learns-about-secr/)

The shorter summary is:

```text
  var repo = 'yourdockerrepo';
  var image = 'yourimage';
  var version = '1.0.0';
  setEnv('DOCKER_BUILDKIT', '1');
  'docker build --ssh default -t $repo/$image:$version .'.run;
```

With in your docker file your FIRST line MUST be:

```text
# syntax=docker/dockerfile:1.0.0-experimental
...

RUN apt-get update
RUN apt-get install --no-install-recommends -y openssh-client

# do you dcli install stuff here

ENV GIT_REP=github.org
# Give git access to your ssh keays
RUN mkdir -m 700 /root/.ssh; 
RUN touch -m 600 /root/.ssh/known_hosts; 
RUN ssh-keyscan $GIT_REPO > /root/.ssh/known_hosts

RUN --mount=type=ssh  dcli compile bin/cmd_dispatcher.dart -o  /home/build/target/cmd_dispatcher
```

## Alpine

If you are using an Alpine based Docker image then you will need to install gclibc.

WARNING: There appear to be some issues around using alpine. I'm seeing network errors \(error 69\) running pub get. These generally happen toward the end of the process but occur about 80% of the time. You can reproduce them easily by running `pub cache repair`. My suspicion is that its because we are installing glibc when alpine uses mu libc.

```text
ENV GLIBC_VERSION 2.31-r0

# Download and install glibc
RUN apk add --update curl && \
  curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
  curl -Lo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
  curl -Lo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
  apk add glibc-bin.apk glibc.apk && \
  /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
  echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
  apk del curl && \
  rm -rf glibc.apk glibc-bin.apk /var/cache/apk/*

# dcli requires ps command 
RUN apk add --update procps
RUN apk add --update wget

# pub requires bash and tar
RUN apk add bash
RUN apk add tar

RUN wget https://github.com/bsutton/dcli/raw/master/bin/linux/dcli_install
RUN chmod +x dcli_install
RUN ./dcli_install
ENV PATH="${PATH}:/usr/bin/dart/bin:/root/.pub-cache/bin"
```


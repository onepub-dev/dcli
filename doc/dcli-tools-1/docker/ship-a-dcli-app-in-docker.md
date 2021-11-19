# Ship a DCli app in Docker

DCli is designed to work with docker and makes for a really easy method of developing a Docker based app.

The following is an example Dockerfile showing how to ship a single DCli app in Docker

```docker
FROM google/dart as build

RUN mkdir /src
WORKDIR /src
RUN git clone https://github.com/noojee/pci_file_monitor.git

# remove the git clone and uncomment this lines for local dev.
# COPY pci_file_monitor /src/pci_file_monitor

WORKDIR /src/pci_file_monitor

RUN dart pub get
RUN dart compile exe /src/pci_file_monitor/bin/pcifim.dart -o /pcifim


# Build minimal  image from AOT-compiled `/pcifim`
FROM build
COPY --from=build /pcifim /pcifim
WORKDIR /
RUN /pcifim install

# Run a base line and schedule scans.
ENTRYPOINT ["/pcifim", "--quiet", "--no-colour", "cron", "--baseline", "30 22 * * * *"]

# remove the ENTRYPOINT and uncomment this line to enable interactive debugging.
# CMD ["bash"]

```

The above example use the `pci_file_monitor` project to show the steps required to run a DCli app in docker.

{% embed url="https://github.com/noojee/pci_file_monitor" %}

`pci_file_monitor` is a real app and a useful reference.

Of particular note `pci_file_monitor` includes its own cron daemon which allows it to schedule itself without requiring the Docker image to contain cron (which is rather difficult to do).

To build the docker image run:

```
docker build -t <imagename> .
```

`To run the docker image:`

```docker
docker run <imagename>
```

To debug the image, comment out the 'ENTRYPOINT' and uncomment 'CMD'

You can now connect to the docker image:

```docker
docker run -it <imagename> /bin/bash
```

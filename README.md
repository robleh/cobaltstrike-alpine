# Cobalt Strike Alpine Image
My Cobalt Strike docker images were taking up over 1GB of space. So I came up with a multi-stage Dockerfile based on Alpine whose image is around ~70MB.

```console
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
cobaltstrike-alpine   latest              7dfe66cd51af        13 seconds ago      69.6MB
cobaltstrike          latest              46f2093a15d8        3 minutes ago       1.24GB
```

## Building
Clone this directory and place your .cobaltstrike.license file in it. Then run `make` to build the image. Bear in mind, this image has been activated with your license so don't push it to any public registries.

## Quickstart
```console
docker run -it --name cobalt -p 50050:50050 -p 443:443 -p 80:80 cobaltstrike $YOUR_IP $TEAMSERVER_PASSWORD
```

You probably want to mount a host directory into the container. This provides a place for data to persist and allows you to pass in Malleable C2 Profiles and utilities.
```console
docker run -it --name cobalt -v $HOME/.cobaltsrike:/mnt -p 50050:50050 -p 443:443 -p 80:80 cobaltstrike $YOUR_IP $TEAMSERVER_PASSWORD /mnt/c2.profile
```

## Zsh Function
I use the included `cobalt` shell function/script for convenience. It creates a mount at `$XDG_DATA_HOME/cobaltstrike` or `~/.cobaltstrike`.

To start a teamserver:
```console
cobalt $YOUR_IP $TEAMSERVER_PASSWORD $C2_PROFILE $KILL_DATE
```

If a teamserver container is already running, you can follow the logs:
```console
cobalt logs
```

View the container's port mappings:
```console
cobalt ports
```

Check the process listing within the container:
```console
cobalt ps awwwfux
```

Drop into a shell on the container:
```console
cobalt shell
```

Check the container's status:
```console
cobalt status
```

Stop the container:
```console
cobalt stop
```

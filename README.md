# iLO

How to use iLO from HPE.

Since iLO uses a deprecated technology (i.e. `javaws` which is [deprecated since Java 9 and removed in Java 11](https://stackoverflow.com/questions/60133865/java-web-start-fails-to-locate-java-runtime)), we need to do some workarounds.

## Options

1. Docker with old Java + VNC
2. Docker with old Java + xquartz
3. OpenWebStart

### Docker + VNC

Build and run the `dockerfile` on this directory. Don't forget to replace the env vars:

```shell
docker build . -t ilo

docker run --rm -it -p 8080:80 -p 5901:5901 \
  -e ILO_USER=user \
  -e ILO_PASSWORD=password \
  -e ILO_HOST=host \
  -e PASSWORD=password1 \
  ilo
```

Then visit [http://localhost:8080/vnc.html](http://localhost:8080/vnc.html) and login with `password1` or **unsafely** store this in your bookmarks: `http://localhost:8080/vnc_auto.html?host=localhost&port=8080&password=password1`.

Otherwise, use a VNC client to connect to `localhost:5901` with password `password1`.

### Docker + xquartz

Install xquartz and follow [these instructions](https://gist.github.com/cschiewek/246a244ba23da8b9f0e7b11a68bf3285) and [this comment](https://gist.github.com/cschiewek/246a244ba23da8b9f0e7b11a68bf3285?permalink_comment_id=3119974#gistcomment-3119974).

```shell
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
xhost +
xhost + "$IP"
xhost + "172.17.0.1"
xhost + "172.17.0.2"
xhost + "172.18.0.1"
xhost + "172.18.0.2"
```

```shell
docker pull xnaveira/docker-javaws

docker run -ti --rm -e DISPLAY=host.docker.internal:0.0 -e HOSTNAME=$HOSTNAME -v "$PWD":/app xnaveira/docker-javaws /bin/bash -c "javaws /app/iLO-jirc.jnlp; jcontrol; sleep 2; javaws /app/iLO-jirc.jnlp; read  -n 1 -p \"Press (return) to end session\" mainmenuinput"

```

### OpenWebStart

I have tried this but failed. [openwebstart.com](https://openwebstart.com/). Maybe future version will be more stable.

## Credits

Option 1 is inspired from [theonemule/docker-opengl-turbovnc](https://github.com/theonemule/docker-opengl-turbovnc/blob/master/dockerfile).

## Current issues

- ARM64 build won't work on GitHub actions, although the build works on M~ macOS. Rosetta has your back.

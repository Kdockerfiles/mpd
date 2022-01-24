**[Dockerized](https://hub.docker.com/r/kdockerfiles/mpd/) [MPD](https://musicpd.org/)**

# Usage

## Available ports

`6600`: Local MPD server (using sndio).

`8000`: Remote MPD server (using HTTPD).

## Available volumes

`/home/music`: Directory with music.

`/home/playlists`: Directory with playlists.

## Directory with sndio socket

Should be mounted at `/tmp/sndio`.

## Example command

```bash
$ docker run -v /tmp/sndio/:/tmp/sndio/:ro -v /media/music/:/home/music/:ro -p 6600:6600 -p 8000:8000 kdockerfiles/mpd:0.23.5-sndio-1
```

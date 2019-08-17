FROM kdockerfiles/pulseaudio-shared:12.2-3
LABEL maintainer="KenjiTakahashi <kenji.sx>"

RUN apk add --no-cache \
    curl \
    meson \
    g++ \
    boost-dev \
    py-sphinx \
    libcdio-paranoia-dev \
    libid3tag-dev \
    libmad-dev \
    libsndfile-dev

COPY *.patch /home/

ARG MPD_VERSION_BASE=0.21
ARG MPD_VERSION_FULL=0.21.13

RUN curl -Lo/home/mpd.tar.xz http://www.musicpd.org/download/mpd/${MPD_VERSION_BASE}/mpd-${MPD_VERSION_FULL}.tar.xz && \
    tar xf /home/mpd.tar.xz -C /home && \
    cd /home/mpd-${MPD_VERSION_FULL} && \
    patch -Np1 < ../stacksize.patch && \
    meson \
        -Ddocumentation=true \
        -Dchromaprint=disabled \
        -Dsidplay=disabled \
        -Dadplug=disabled \
        -Dsndio=disabled \
        -Dshine=disabled \
        -Dtremor=disabled \
        -Dao=disabled \
        -Dffmpeg=disabled \
        -Djack=disabled \
        -Dmodplug=disabled \
        -Dshout=disabled \
        -Dsidplay=disabled \
        -Dsoundcloud=disabled \
        -Dwavpack=disabled \
        -Dzzip=disabled \
        -Dzeroconf=disabled \
        -Dsmbclient=disabled \
        -Dlibmpdclient=disabled \
        -Dopenal=disabled \
        -Dfluidsynth=disabled \
        -Dmms=disabled \
        -Dgme=disabled \
    . output && \
    ninja -C output && \
    ninja -C output install


FROM alpine:3.10

RUN apk add --no-cache \
    libcdio-paranoia \
    libid3tag \
    libmad \
    libsndfile

COPY --from=0 /usr/local/bin/mpd /usr/local/bin/
COPY --from=0 /usr/local/lib/ /usr/local/lib/

WORKDIR /home

COPY mpd.conf mpd.conf

RUN mkdir -p playlists music

VOLUME ["/home/music"]

EXPOSE 6600 8000

ENTRYPOINT ["/usr/local/bin/mpd", "--no-daemon"]
CMD ["--stderr", "/home/mpd.conf"]

FROM alpine:3.15
LABEL maintainer="KenjiTakahashi <kenji.sx>"

COPY *.patch /home/

ARG MPD_VERSION_BASE=0.23
ARG MPD_VERSION_FULL=0.23.5

RUN apk add --no-cache \
    patch \
    meson \
    curl \
    gcc \
    musl-dev \
    g++ \
    boost-dev \
    liburing-dev \
    sndio-dev \
    sqlite-dev \
    libid3tag-dev \
    soxr-dev \
    fmt-dev \
    libshout-dev \
    flac-dev \
    mpg123-dev

RUN curl -Lo/home/mpd.tar.xz http://www.musicpd.org/download/mpd/${MPD_VERSION_BASE}/mpd-${MPD_VERSION_FULL}.tar.xz && \
    tar xf /home/mpd.tar.xz -C /home && \
    cd /home/mpd-${MPD_VERSION_FULL} && \
    patch -Np1 < ../stacksize.patch && \
    meson \
        -Dbuildtype=debugoptimized \
        -Dadplug=disabled \
        -Dalsa=disabled \
        -Dao=disabled \
        -Daudiofile=disabled \
        -Dbzip2=disabled \
        -Dcdio_paranoia=disabled \
        -Dchromaprint=disabled \
        -Dcue=true \
        -Dcurl=disabled \
        -Ddaemon=true \
        -Ddatabase=true \
        -Ddbus=disabled \
        -Ddocumentation=disabled \
        -Ddsd=true \
        -Depoll=true \
        -Deventfd=true \
        -Dexpat=disabled \
        -Dfaad=disabled \
        -Dffmpeg=disabled \
        -Dfifo=false \
        -Dflac=enabled \
        -Dfluidsynth=disabled \
        -Dfuzzer=false \
        -Dgme=disabled \
        -Dhtml_manual=false \
        -Dhttpd=true \
        -Diconv=enabled \
        -Dicu=enabled \
        -Did3tag=enabled \
        -Dinotify=true \
        -Dio_uring=enabled \
        -Dipv6=enabled \
        -Diso9660=disabled \
        -Djack=disabled \
        -Dlame=disabled \
        -Dlibmpdclient=disabled \
        -Dlibsamplerate=disabled \
        -Dlocal_socket=true \
        -Dmad=disabled \
        -Dmanpages=false \
        -Dmikmod=disabled \
        -Dmms=disabled \
        -Dmodplug=disabled \
        -Dmpcdec=disabled \
        -Dmpg123=enabled \
        -Dneighbor=false \
        -Dnfs=disabled \
        -Dopenal=disabled \
        -Dopenmpt=disabled \
        -Dopus=disabled \
        -Doss=disabled \
        -Dpcre=disabled \
        -Dpipe=false \
        -Dpipewire=disabled \
        -Dpulse=disabled \
        -Dqobuz=disabled \
        -Drecorder=false \
        -Dshine=disabled \
        -Dshout=enabled \
        -Dsidplay=disabled \
        -Dsignalfd=true \
        -Dsmbclient=disabled \
        -Dsnapcast=false \
        -Dsndfile=disabled \
        -Dsndio=enabled \
        -Dsolaris_output=disabled \
        -Dsoundcloud=disabled \
        -Dsoxr=enabled \
        -Dsqlite=enabled \
        -Dsyslog=disabled \
        -Dsystemd=disabled \
        -Dtcp=true \
        -Dtest=false \
        -Dtremor=disabled \
        -Dtwolame=disabled \
        -Dudisks=disabled \
        -Dupnp=disabled \
        -Dvorbis=disabled \
        -Dvorbisenc=disabled \
        -Dwave_encoder=false \
        -Dwavpack=disabled \
        -Dwebdav=disabled \
        -Dwildmidi=disabled \
        -Dyajl=disabled \
        -Dzeroconf=disabled \
        -Dzlib=disabled \
        -Dzzip=disabled \
    . output && \
    ninja -C output && \
    ninja -C output install


FROM alpine:3.15

COPY --from=0 /usr/local/bin/mpd /usr/local/bin/

RUN apk add --no-cache \
    liburing \
    fmt \
    sqlite-libs \
    icu-libs \
    soxr \
    libid3tag \
    sndio-libs \
    libshout \
    flac \
    mpg123-libs

WORKDIR /home

RUN mkdir -p playlists music

VOLUME ["/home/playlists", "/home/music"]

ENTRYPOINT ["mpd", "--no-daemon"]

CMD ["--stderr", "/home/mpd.conf"]

EXPOSE 6600 8000

COPY mpd.conf mpd.conf

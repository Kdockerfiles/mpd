FROM kdockerfiles/pulseaudio-shared:12.2-1
LABEL maintainer="KenjiTakahashi <kenji.sx>"

RUN apk add --no-cache \
    curl \
    g++ \
    make \
    boost-dev \
    libcdio-paranoia-dev \
    libid3tag-dev \
    libmad-dev \
    libsndfile-dev

COPY *.patch /home/

ARG MPD_VERSION_BASE=0.20
ARG MPD_VERSION_FULL=0.20.20

RUN curl -Lo/home/mpd.tar.xz http://www.musicpd.org/download/mpd/${MPD_VERSION_BASE}/mpd-${MPD_VERSION_FULL}.tar.xz && \
    tar xf /home/mpd.tar.xz -C /home && \
    cd /home/mpd-${MPD_VERSION_FULL} && \
    patch -Np1 < ../stacksize.patch && \
    ./configure \
        --prefix=/usr/local \
        --sysconfdir=/usr/local/etc \
        --mandir=/usr/local/share/man \
        --infodir=/usr/local/share/info \
        --enable-database \
        --enable-httpd-output \
        --enable-cdio-paranoia \
        --enable-pulse \
        --enable-id3 \
        --enable-flac \
        --enable-mad \
        --disable-daemon \
        --disable-libmpdclient \
        --disable-oss \
        --disable-openal \
        --disable-ao \
        --disable-jack \
        --disable-modplug \
        --disable-shout \
        --disable-sidplay \
        --disable-soundcloud \
        --disable-wavpack \
        --disable-smbclient \
        --disable-fluidsynth \
        --with-zeroconf=no \
        --enable-debug \
    && \
    make && \
    make install && \
    rm -rf /home/mpd-${MPD_VERSION_FULL} /home/*.patch /home/*.xz


FROM alpine:3.8

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

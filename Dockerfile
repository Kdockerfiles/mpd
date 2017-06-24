# Required for now, to get libpulse.
# TODO: Refactor
FROM kdockerfiles/pulseaudio:10.0-1
MAINTAINER KenjiTakahashi <kenji.sx>

USER root

RUN apk add --no-cache \
    curl \
    g++ \
    boost-dev \
    libcdio-paranoia-dev \
    libid3tag-dev \
    libmad-dev

RUN curl -Lo/home/mpd.tar.xz http://www.musicpd.org/download/mpd/0.20/mpd-0.20.9.tar.xz && \
    tar xvf /home/mpd.tar.xz -C /home && \
    cd /home/mpd-0.20.9 && \
    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --mandir=/usr/share/man \
        --infodir=/usr/share/info \
        --enable-cdio-paranoia \
        --enable-pulse \
        --enable-id3 \
        --enable-mad \
        --disable-libmpdclient \
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
    && \
    make && \
    make install && \
    rm -rf /home/mpd-0.20.9 /home/*.xz

RUN adduser -S -G audio mpd

USER mpd
WORKDIR /home/mpd

COPY mpd.conf mpd.conf

RUN mkdir -p playlists music && \
    touch mpd.db

VOLUME ["/home/mpd/music"]

EXPOSE 6666 7777

ENTRYPOINT ["mpd", "--no-daemon"]
CMD ["--stderr", "/home/mpd/mpd.conf"]

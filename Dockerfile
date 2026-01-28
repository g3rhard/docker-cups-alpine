# syntax=docker/dockerfile:1@sha256:9857836c9ee4268391bb5b09f9f157f3c91bb15821bb77969642813b0d00518d
ARG ALPINE_VERSION="edge@sha256:9a341ff2287c54b86425cbee0141114d811ae69d88a36019087be6d896cef241"

FROM alpine:${ALPINE_VERSION}

# Install the packages we need. Avahi will be included
RUN echo -e "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo -e "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo -e "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --update --no-cache cups \
    cups-libs \
    cups-pdf \
    cups-client \
    cups-filters \
    cups-dev \
    gutenprint \
    gutenprint-libs \
    gutenprint-doc \
    gutenprint-cups \
    ghostscript \
    brlaser \
    hplip \
    avahi \
    inotify-tools \
    python3 \
    python3-dev \
    py3-pip \
    build-base \
    wget \
    rsync

RUN pip3 --no-cache-dir install --break-system-packages --upgrade pip \
    && pip3 install --break-system-packages pycups \
    && rm -rf /var/cache/apk/*

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

# Add scripts
COPY root /
RUN chmod +x /root/*

#Run Script
CMD ["/root/run_cups.sh"]

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

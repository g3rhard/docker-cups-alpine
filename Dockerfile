# syntax=docker/dockerfile:1@sha256:87999aa3d42bdc6bea60565083ee17e86d1f3339802f543c0d03998580f9cb89
ARG ALPINE_VERSION="edge@sha256:9a341ff2287c54b86425cbee0141114d811ae69d88a36019087be6d896cef241"

FROM alpine:${ALPINE_VERSION}

# Runtime packages only. py3-pycups avoids carrying a compiler, headers, and pip.
# hadolint ignore=DL3018
RUN apk add --no-cache \
        avahi \
        brlaser \
        cups \
        cups-client \
        cups-filters \
        cups-pdf \
        ghostscript \
        gutenprint-cups \
        hplip \
        inotify-tools \
        py3-pycups

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/.*enable\-dbus=.*/enable-dbus=no/' /etc/avahi/avahi-daemon.conf && \
    printf '\nServerAlias *\nDefaultEncryption Never\n' >> /etc/cups/cupsd.conf

COPY --chmod=755 scripts/ /usr/local/bin/

CMD ["run_cups.sh"]

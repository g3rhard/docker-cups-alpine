#!/bin/sh

set -e

/usr/bin/inotifywait -m -q -e close_write,moved_to,create \
  --format '%f' /etc/cups |
while read -r filename; do
  [ "$filename" = "printers.conf" ] || continue

  rm -f /services/AirPrint-*.service
  /usr/local/bin/airprint-generate.py -d /services
  cp /etc/cups/printers.conf /config/printers.conf

  rm -f /etc/avahi/services/AirPrint-*.service
  set -- /services/AirPrint-*.service
  if [ -e "$1" ]; then
    cp -f /services/AirPrint-*.service /etc/avahi/services/
  fi
done

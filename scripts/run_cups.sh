#!/bin/sh

set -e

CUPSADMIN=${CUPSADMIN:-cupsadmin}
CUPSPASSWORD=${CUPSPASSWORD:-$CUPSADMIN}

case "$CUPSADMIN" in
  *[!a-zA-Z0-9_.-]* | "")
    echo "CUPSADMIN contains invalid characters" >&2
    exit 1
    ;;
esac

if ! id "$CUPSADMIN" >/dev/null 2>&1; then
    adduser -S -G lpadmin --no-create-home "$CUPSADMIN"
fi
printf '%s:%s\n' "$CUPSADMIN" "$CUPSPASSWORD" | chpasswd

mkdir -p /config/ppd /services
rm -f /etc/avahi/services/*.service
rm -rf /etc/cups/ppd
ln -s /config/ppd /etc/cups/ppd

set -- /services/*.service
if [ -e "$1" ]; then
  cp -f /services/*.service /etc/avahi/services/
fi
touch /config/printers.conf
cp /config/printers.conf /etc/cups/printers.conf

/usr/sbin/avahi-daemon --daemonize
/usr/local/bin/printer-update.sh &
exec /usr/sbin/cupsd -f

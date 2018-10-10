#!/bin/sh

PLATFORM="unknown"
CONNECTED=0
LOOP="yes"

if [ -f "/etc/release" ] ;
  PLATFORM=$(cat /etc/release | cut -d . -f 1)
fi

while [ "$LOOP" = "yes" ] ; do

  case $PLATFORM in
    Generic)
      for PORT in /sys/class/drm/*/status ; do
        STATUS=$(cat $PORT)
        if [ "$STATUS" = "connected" ] ; then
          CONNECTED=1
        fi
      done
      ;;
    *)
      CONNECTED=1
      ;;
  esac

  if [ $CONNECTED -eq 0 ] ; then
    sleep 10
  else
    LOOP="no"
  fi

done

/usr/bin/retroarch

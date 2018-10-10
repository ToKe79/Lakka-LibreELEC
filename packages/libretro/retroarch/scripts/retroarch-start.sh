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
        if [ -f $PORT ] ; then
          STATUS=$(cat $PORT)
          if [ "$STATUS" = "connected" ] ; then
            CONNECTED=1
          fi
        fi
      done
      ;;
    S912)
      PORT=/sys/class/switch/hdmi/state
      if [ -f $PORT ] ; then
        STATUS=$(cat $PORT)
        if [ $STATUS -eq 1 ] ; then
          CONNECTED=1
        fi
      fi
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

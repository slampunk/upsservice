#!/bin/bash

if [ "$NOTIFYTYPE" = "ONLINE" ]
then
  echo "ONLINE" | socat - UNIX-CONNECT:/tmp/ups.sock
fi

if [ "$NOTIFYTYPE" = "ONBATT" ]
then
  echo "ONBATTERY" | socat - UNIX-CONNECT:/tmp/ups.sock
fi

if [ "$NOTIFYTYPE" = "LOWBATT" ]
then
  echo "ONBATTERY" | socat - UNIX-CONNECT:/tmp/ups.sock
fi

if [ "$NOTIFYTYPE" = "REPLBATT" ]
then
  echo "REPLACEBATTERY" | socat - UNIX-CONNECT:/tmp/ups.sock
fi

#!/usr/bin/env bash

online=$(ifconfig | grep "RUNNING,MULTICAST" | cut -d ":" -f1)


if [[ "$online" ]]
then
    echo %{F#EFF0F1}
  else
    echo %{F#E64141}
fi

exit 0

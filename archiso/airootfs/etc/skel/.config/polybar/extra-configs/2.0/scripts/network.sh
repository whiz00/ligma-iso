#!/usr/bin/env bash

online=$(ip addr | grep "state UP" | cut -d ":" -f2)

#connected=""
#offline=""
#connected=""
#offline=""
connected=""
offline=""
if [[ "$online" ]]; then
  echo %{F#8FA1B3}${connected}
else
  echo %{F#E7816B}${offline}; sleep 1; echo %{F#8FA1B3}${offline}
fi

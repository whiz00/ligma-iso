#!/usr/bin/env bash

pac=$(checkupdates | wc -l)

if [[ "$pac" > "1" ]]; then
  echo %{F#6BA4E7}$pac %{F#6BA4E7}

else
  echo %{F#8FA1B3}%{F#8FA1B3} 

fi

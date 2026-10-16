#!/bin/bash

if pgrep -af '^qs -c caelestia' >/dev/null; then
  echo "caelestia"
elif pgrep -af 'serpantinum' | grep -v 'inotifywait' >/dev/null; then
  echo "serpantinum"
else
  echo "Nothing"
fi

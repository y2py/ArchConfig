#!/bin/bash
LAST_WL=""
LAST_X=""
while true; do
  WL=$(wl-paste 2>/dev/null)
  X=$(xclip -selection clipboard -o 2>/dev/null)
  if [ "$WL" != "$LAST_WL" ] && [ -n "$WL" ]; then
    echo -n "$WL" | xclip -selection clipboard
    LAST_WL="$WL"; LAST_X="$WL"
  elif [ "$X" != "$LAST_X" ] && [ -n "$X" ]; then
    echo -n "$X" | wl-copy
    LAST_X="$X"; LAST_WL="$X"
  fi
  sleep 0.5
done

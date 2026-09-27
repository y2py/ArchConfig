#!/bin/bash
FILE="/tmp/isw_status"
LOG_FILE="/tmp/isw_errors.log"
SOUNDS="$HOME/.config/hypr/hyprland/sounds/isw"
ICON="$HOME/.config/hypr/hyprland/icons/AliceKuonji.jpeg"
#init
if [ ! -f $FILE ]; then
    echo 0 > $FILE
fi

STATUS=$(cat $FILE)

#toggler
if [ "$STATUS" -eq 1 ]; then

    sudo isw -b off > /dev/null 2>> $LOG_FILE
    pw-play $SOUNDS/off.mp3 &
    notify-send -i $ICON "System Message" "Fan speed set to Auto."
    echo 0 > "$FILE"
else

    sudo isw -b on > /dev/null 2>> $LOG_FILE
    pw-play $SOUNDS/on.mp3 &
    notify-send -i $ICON "System Message" "Fan speed set to Max."
    echo 1 > "$FILE"

fi

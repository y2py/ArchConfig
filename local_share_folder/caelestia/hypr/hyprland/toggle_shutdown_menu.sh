
#!/bin/bash

LOCK_FILE="/tmp/shutdown_click_check"
TIME_WINDOW=3
SOUND_FILE="/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"

if [ -f "$LOCK_FILE" ]; then
    LAST_CLICK=$(cat "$LOCK_FILE")
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - LAST_CLICK))

    if [ $ELAPSED -le $TIME_WINDOW ]; then
        rm -f "$LOCK_FILE"
        systemctl poweroff
        exit 0
    fi
fi

date +%s > "$LOCK_FILE"

if [ -f "$SOUND_FILE" ] && command -v pw-play &> /dev/null; then
    pw-play "$SOUND_FILE" &
fi

yad --image="dialog-warning" \
    --title="Shutdown" \
    --text="Do You Want To Shutdown?" \
    --button="Yes:0" \
    --button="No:1" \
    --width=380 \
    --center

RESPONSE=$?

rm -f "$LOCK_FILE"

if [ $RESPONSE -eq 0 ]; then
    systemctl poweroff
else
    exit 0
fi


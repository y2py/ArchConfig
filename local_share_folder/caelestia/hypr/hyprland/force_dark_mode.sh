#!/bin/bash
STATE_FILE="/tmp/caelestia_mode_state"
LOG_FILE="/tmp/caelestia_mode_state_logs"
TIMEOUT=$(( $(date +%s) + 15 ))
while ! pgrep -f "/usr/bin/caelestia" >/dev/null; do
    echo "CAELESTIA NOT FOUND"
    if [ "$(date +%s)" -gt "$TIMEOUT" ]; then
        echo "$(date '+%T') - Error: caelestia did not start" >> "$LOG_FILE"
        exit 1
    fi
    sleep 0.5
done
sleep 3
END=$(( $(date +%s) + 300 ))
while [ "$(date +%s)" -lt "$END" ]; do
    # Step 1: run the enable command
    caelestia scheme set --mode dark &>/dev/null

    # Step 2: check the real current state
    CURRENT_STATE=$(caelestia scheme get --mode 2>/dev/null)

    # Step 3: compare - did it actually become enabled?
    if [ "$CURRENT_STATE" = "dark" ]; then
        sleep 5
    # Step 4: Trying Again - did it bugged?
        caelestia scheme set --mode dark &>/dev/null
        echo "dark" > "$STATE_FILE"
        exit 0
    fi

    sleep 0.5
done

echo "failed: caelestia-mode did not report enabled after 300s (last state: $CURRENT_STATE)" >&2
exit 1

#!/bin/bash
STATE_FILE="/home/aws/.cache/idle-inhibitor-state"
END=$(( $(date +%s) + 300 ))

while [ "$(date +%s)" -lt "$END" ]; do
    # Step 1: run the enable command
    caelestia shell idleInhibitor enable &>/dev/null

    # Step 2: check the real current state
    CURRENT_STATE=$(caelestia shell idleInhibitor isEnabled 2>/dev/null)

    # Step 3: compare - did it actually become enabled?
    if [ "$CURRENT_STATE" = "true" ]; then
        echo "enabled" > "$STATE_FILE"
        exit 0
    fi

    sleep 0.5
done

echo "failed: idleInhibitor did not report enabled after 300s (last state: $CURRENT_STATE)" >&2
exit 1

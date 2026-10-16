#!/usr/bin/bash

STATE_FILE="$HOME/.cache/idle-inhibitor-state"

# Wait for Caelestia IPC to become available (up to 30 seconds).
for ((i = 0; i < 60; i++)); do
  if CURRENT_STATE=$(caelestia shell idleInhibitor isEnabled 2>/dev/null); then
    break
  fi
  sleep 0.5
done

# Read the previously saved state.
if [[ ! -f "$STATE_FILE" ]]; then
  echo "No saved idle inhibitor state found." >&2
  exit 1
fi

SAVED_STATE=$(<"$STATE_FILE")
SAVED_STATE=$(printf '%s' "$SAVED_STATE" | tr -d '[:space:]')

case "$SAVED_STATE" in
true | enabled)
  caelestia shell idleInhibitor enable >/dev/null 2>&1
  ;;
false | disabled)
  caelestia shell idleInhibitor disable >/dev/null 2>&1
  ;;
*)
  echo "Invalid saved state: $SAVED_STATE" >&2
  exit 1
  ;;
esac

# Verify the restored state.
for ((i = 0; i < 20; i++)); do
  CURRENT_STATE=$(caelestia shell idleInhibitor isEnabled 2>/dev/null)

  if [[ "$SAVED_STATE" == "true" || "$SAVED_STATE" == "enabled" ]]; then
    [[ "$CURRENT_STATE" == "true" ]] && exit 0
  else
    [[ "$CURRENT_STATE" == "false" ]] && exit 0
  fi

  sleep 0.25
done

echo "Failed to restore idle inhibitor state (saved: $SAVED_STATE, current: $CURRENT_STATE)" >&2
exit 1

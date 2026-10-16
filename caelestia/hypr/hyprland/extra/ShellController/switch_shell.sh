#!/bin/bash

BASE_DIR="$HOME/.config/hypr/hyprland/extra/ShellController"
current="$BASE_DIR/canRun"
lock="$BASE_DIR/switch.lock"
notify_sender="$HOME/.config/hypr/hyprland/notify_sender.sh"
SOUNDS="$HOME/.config/hypr/hyprland/sounds/system"

exec 9>"$lock"

if ! flock -n 9; then
  bash "$notify_sender" "On Cooldown..."

  shell=$(bash "$BASE_DIR/get_shell.sh")
  if [[ "$shell" == "caelestia" ]]; then
    pw-play "$SOUNDS/off.mp3"
  fi

  echo "There is a process already running. Exiting..."
  exit 0
fi

cleanup() {
  echo 0 >"$current"
}
trap cleanup EXIT

shell=$(bash "$BASE_DIR/get_shell.sh")

echo 1 >"$current"
echo "Your Shell is: $shell"

case "$shell" in
serpantinum)
  bash "$notify_sender" "Switching to Caelestia..!"

  bash ~/.config/hypr/hyprland/run_caelestia.sh >/dev/null 2>&1 &
  disown

  sleep 2
  serpantinumd stop >/dev/null 2>&1
  sleep 3
  ;;

caelestia)
  bash "$notify_sender" "Switching to Serpantinum..!" &
  pw-play "$SOUNDS/on.mp3"

  serpantinumd start >/dev/null 2>&1 &
  disown

  sleep 3
  caelestia shell -k >/dev/null 2>&1
  sleep 2
  ;;

*)
  echo "Nothing is Running!"
  ;;
esac

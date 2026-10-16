#!/bin/bash
file="$HOME/.cache/idle-inhibitor-state"
isEnabled=$(caelestia shell idleInhibitor isEnabled)

echo $isEnabled >$file

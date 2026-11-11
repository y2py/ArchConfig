#!/bin/bash
isEnabled=$(caelestia shell idleInhibitor isEnabled)
echo $isEnabled >~/.cache/idle-inhibitor-state

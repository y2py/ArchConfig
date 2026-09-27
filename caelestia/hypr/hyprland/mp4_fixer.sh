#!/bin/bash
ffmpeg -i "$1" -c:v copy -c:a pcm_s16le "resolved_$1" -y


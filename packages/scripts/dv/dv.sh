#!/usr/bin/env bash

OG_BITRATE=$(ffprobe -v error -select_streams v -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$1")
OG_BITRATE=$(( OG_BITRATE / 1024 ))
SEC=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1")
# use awk to round up in case our shell doesn't support floating point arithmetic
SEC_ROUNDED=$(echo "$SEC" | awk '{print int($1 + 1)}')
# target 50 MB, minus 128kb/s for audio
BITRATE=$((50*1024*8 / SEC_ROUNDED - 128))
# upper limit of 4kbs in case the clip is very short
MAX_BITRATE=4096
BITRATE=$(( BITRATE > MAX_BITRATE ? MAX_BITRATE : BITRATE ))
BITRATE=$(( BITRATE > OG_BITRATE ? OG_BITRATE : BITRATE ))

# two passes
# we use the software encoder because its not that much slower, has better support, and looks better at lower bitrates
ffmpeg -y -i "$1" -vf scale=-1:720 -c:v libx264 -b:v "$BITRATE"k -pix_fmt yuv420p -an -pass 1 -f mp4 /dev/null
ffmpeg -y -i "$1" -vf scale=-1:720 -c:v libx264 -b:v "$BITRATE"k -pix_fmt yuv420p -map_chapters -1 -c:a aac -pass 2 output.mp4

# remove file artifacts
rm ffmpeg2pass-0.log ffmpeg2pass-0.log.mbtree
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

OG_BITRATE=$(ffprobe -v error -select_streams v -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$1")

# Sometimes the bitrate will be undefined. This will catch that and set a sensible default (4 kbps)
if [ "$OG_BITRATE" = "N/A" ]; then
    OG_BITRATE=4096
else 
    OG_BITRATE=$(( OG_BITRATE / 1024 ))
fi

SEC=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1")
# use awk to round up in case our shell doesn't support floating point arithmetic
SEC_ROUNDED=$(echo "$SEC" | awk '{print int($1 + 1)}')
# target 50 MB total
BITRATE=$((50*1024*8 / SEC_ROUNDED))

# audio bitrate 128kbps by default, unless we don't have room for it.
AUDIO_BITRATE=128
if (( BITRATE < 256 )); then
    AUDIO_BITRATE=$((BITRATE / 2))
fi

# minus the audio bitrate from the video bitrate
BITRATE=$((BITRATE - AUDIO_BITRATE))

# upper limit of 4kbs in case the clip is very short
MAX_BITRATE=4096
BITRATE=$(( BITRATE > MAX_BITRATE ? MAX_BITRATE : BITRATE ))
BITRATE=$(( BITRATE > OG_BITRATE ? OG_BITRATE : BITRATE ))

# more than 720p is wasted on Discord, but if we're crushing a long video, we'll need to go even smaller
if (( BITRATE > 1024 )); then 
    SCALE=720
elif (( BITRATE > 256 )); then
    SCALE=360
else
    SCALE=180
fi

# two passes
# we use the software encoder because its not that much slower, has better support, and looks better at lower bitrates
# note: we downsample to stereo if necessary
ffmpeg -y -i "$1" -vf scale=-1:"$SCALE" -c:v libx264 -b:v "$BITRATE"k -pix_fmt yuv420p -an -pass 1 -f mp4 /dev/null
ffmpeg -y -i "$1" -vf scale=-1:"$SCALE" -c:v libx264 -b:v "$BITRATE"k -pix_fmt yuv420p -map_chapters -1 -c:a aac -b:a "$AUDIO_BITRATE"k -ac 2 -pass 2 output.mp4

# remove file artifacts
rm ffmpeg2pass-0.log ffmpeg2pass-0.log.mbtree
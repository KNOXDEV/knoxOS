VCODEC=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$1")

INPUT_ARGS="-ss $2 -to $3"

# if coming from hevc, we can use cuvid to decode and nvenc to reencode all on the gpu
if [[ "$VCODEC" = "hevc" ]]; then
	INPUT_ARGS="-hwaccel cuda -hwaccel_output_format cuda $INPUT_ARGS"
fi

ffmpeg "$INPUT_ARGS" -i "$1" -c:v hevc_nvenc -preset p5 -multipass qres -rc vbr -cq 19 -c:a copy ./trimmed.mp4
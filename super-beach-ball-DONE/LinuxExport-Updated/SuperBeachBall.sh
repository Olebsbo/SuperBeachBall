#!/bin/sh
printf '\033c\033]0;%s\a' SuperBeachBall
base_path="$(dirname "$(realpath "$0")")"
"$base_path/SuperBeachBall.x86_64" "$@"

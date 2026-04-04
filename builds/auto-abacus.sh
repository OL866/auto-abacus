#!/bin/sh
printf '\033c\033]0;%s\a' auto-abacus
base_path="$(dirname "$(realpath "$0")")"
"$base_path/auto-abacus.arm64" "$@"

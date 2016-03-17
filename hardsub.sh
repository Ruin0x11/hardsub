#!/bin/bash
# hardsub.sh
# Convert softsubs to hardsubs.

# Prepare temporary directory to unpack demultiplexed components to.
readonly tmpdir="$(mktemp -d --tmpdir hardsub.XXXXXXXXXX)"
trap "
  cd '${TMPDIR:/tmp}'
  rm -r '$tmpdir'
" EXIT

# Resolve paths needed to be accessed from within temporary location.
readonly input="$(realpath $1)"
cd "$tmpdir"

# Extract multiplexed components.
ffmpeg -i "$input" -map 0:s:0 sub.ass

# Compile video.
ffmpeg -i "$input" -vf ass=sub.ass -sn "${input%.*}.hardsubbed.${input##*.}"

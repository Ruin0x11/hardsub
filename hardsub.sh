#!/bin/bash

# Parse options.
while [ $OPTIND -le $# ]
do
  if getopts 'h' argument
  then
    case $argument in
      h)
        echo "usage: $0 [options] <video>"
        echo 'Convert softsubs to hardsubs.'
        echo ' -h  only shows this help text'
        exit ;;
      \?) exit 1 ;;
    esac
  else
    if [ -z ${input++} ]
    then
      readonly input="$(realpath "${!OPTIND}")"
    else
      echo "$0: too many arguments" >&2
      exit 1
    fi
    let OPTIND++
  fi
done
if [ -z ${input++} ]
then
  echo "$0: no input file given" >&2
  exit 0
fi

# Prepare temporary directory to unpack demultiplexed components to.
readonly tmpdir="$(mktemp -d --tmpdir hardsub.XXXXXXXXXX)"
export FONTCONFIG_FILE="$(realpath "${BASH_SOURCE[0]%%/*}")/fonts.conf"
trap "
  cd '${TMPDIR:/tmp}'
  rm -r '$tmpdir'
" EXIT
cd "$tmpdir"

# Extract multiplexed components.
ffmpeg -dump_attachment:t '' -i "$input"
ffmpeg -i "$input" -map 0:s:0 sub.ass

# Compile video.
ffmpeg -i "$input" -vf ass=sub.ass -sn "${input%.*}.hardsubbed.${input##*.}"

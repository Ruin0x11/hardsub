#!/bin/bash

# Parse options.
while [ $OPTIND -le $# ]
do
  if getopts 'hq' argument
  then
    case $argument in
      h)
        echo "usage: $0 [options] <video>"
        echo 'Convert softsubs to hardsubs.'
        echo ' -h  only shows this help text'
        echo ' -q  do not show short-running ffmpeg output'
        exit ;;
      q) quiet=true ;;
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

# Prepare colors. Stolen from Arch Linux' pacman project,
# more specifically the message utils for makepkg.
if [ -z ${quiet++} ]
then
  readonly target="/dev/stdout"
  if tput setaf 0 &>/dev/null
  then
    readonly reset="$(tput sgr0)"
    readonly bold="$(tput bold)"
  else
    readonly reset="\e[0m"
    readonly bold="\e[1m"
  fi
else
  readonly reset=
  readonly bold=
  readonly target="/dev/null"
fi
msg() {
  echo "${bold}$1${reset}"
}

msg 'Prepare workspace.'
readonly tmpdir="$(mktemp -d --tmpdir hardsub.XXXXXXXXXX)"
export FONTCONFIG_FILE="$(realpath "${BASH_SOURCE[0]%%/*}")/fonts.conf"
trap "
  cd '${TMPDIR:/tmp}'
  rm -r '$tmpdir'
" EXIT
cd "$tmpdir"

msg 'Extract multiplexed components.'
ffmpeg -dump_attachment:t '' -i "$input" 2>"$target"
ffmpeg -i "$input" -map 0:s:0 sub.ass 2>"$target"

msg 'Compile video.'
ffmpeg -i "$input" -vf ass=sub.ass -sn "${input%.*}.hardsubbed.${input##*.}"

#!/bin/bash

# Parse options.
while [ $OPTIND -le $# ]
do
  if getopts 'hqs:' argument
  then
    case $argument in
      h)
        echo "usage: $0 [options] <video>"
        echo 'Convert softsubs to hardsubs.'
        echo ' -h           only shows this help text'
        echo ' -q           do not show short-running ffmpeg output'
        echo ' -s <number>  choose subtitle stream'
        exit ;;
      q) quiet=true ;;
      s)
        if [[ "$OPTARG" =~ ^[0-9]+$ ]]
        then
          stream=$OPTARG
        else
          echo "$0: stream must be numeric" >&2
          exit 1
        fi ;;
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
ffmpeg -dump_attachment:t '' -i "$input" 2>&1 | \
  if [ -z ${stream++} ]
  then
    if [ 1 -lt "$(tee "$target" | grep \
      '^    Stream #0:[[:digit:]]\+[^:]*: Subtitle: ass' | wc -l)" ]
    then
      echo "Multiple subtitles detected." \
        "Choose one with the -s option to silence this warning." >&2
    fi
  else
    cat > "$target"
  fi
ffmpeg -i "$input" -map "0:s:${stream-0}" sub.ass 2>"$target"

msg 'Compile video.'
ffmpeg -i "$input" -vf ass=sub.ass -sn "${input%.*}.hardsubbed.${input##*.}"

#!/bin/bash

# Parse options.
while [ $OPTIND -le $# ]
do
  if getopts 'hvs:lo:()' argument
  then
    case $argument in
      h)
        echo "usage: $0 [options] <video>"
        echo 'Convert softsubs to hardsubs.'
        echo ' -h           only shows this help text'
        echo ' -v           show short-running ffmpeg output'
        echo ' -s <number>  choose subtitle stream'
        echo ' -l           list available subtitle streams'
        echo ' -o <file>    output file name'
        echo ' -( ... -)    arguments to pass to encoding ffmpeg'
        exit ;;
      v)
        if [ -z ${target++} ]
        then
          # Prepare colors. Stolen from Arch Linux' pacman project,
          # more specifically the message utils for makepkg.
          readonly target="/dev/stderr"
          if tput setaf 0 &>/dev/null
          then
            readonly reset="$(tput sgr0)"
            readonly bold="$(tput bold)"
          else
            readonly reset="\e[0m"
            readonly bold="\e[1m"
          fi
        fi ;;
      s) stream=$OPTARG ;;
      l) stream=list ;;
      o) output=$(realpath "$OPTARG") ;;
      \()
        while [ "${!OPTIND}" != '-)' ]
        do
          if [ $OPTIND -ge $# ]
          then
            echo "$0: -( without -)"
            exit 1
          fi
          pass+=("${!OPTIND}")
          let OPTIND++
        done
        let OPTIND++
        ;;
      \))
        echo "$0: -) without -("
        exit 1 ;;
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

# List.
if [ "$stream" = list ]
then
  i=0
  while read title
  do
    echo "$i: $title"
    let i++
  done < <(ffprobe "$input" 2>&1 | pcregrep -M -o3 \
    "(?s)^ {4}Stream #0:(\\d+)[^:]*: Subtitle: ass( \\(default\\))?$(
    )\n.*?^ {6}title *:( [^\n]+)")
  exit
fi

msg() {
  echo "${bold}$1${reset}"
}

msg 'Prepare workspace.'
: ${output=$(realpath "\$name.hardsubbed.\$ext")}
readonly tmpdir="$(mktemp -d --tmpdir hardsub.XXXXXXXXXX)"
export FONTCONFIG_FILE="$(realpath "${BASH_SOURCE[0]%%/*}")/fonts.conf"
trap "
  cd '${TMPDIR:/tmp}'
  rm -r '$tmpdir'
" EXIT
cd "$tmpdir"

msg 'Extract multiplexed components.'
if [ -z ${stream++} ]
then
  if [ 1 -lt "$(tee "${target-/dev/null}" | grep \
    '^    Stream #0:[[:digit:]]\+[^:]*: Subtitle: ass' | wc -l)" ]
  then
    echo "Multiple subtitles detected." \
      "Choose one with the -s option to silence this warning." >&2
  fi
else
  if [[ "$stream" =~ ^[0-9]+$ ]]
  then
    stream='s:0'
    cat > "${target-/dev/null}"
  else
    declare -A streams
    while read number title
    do
      streams["$title"]=$number
    done < <(pcregrep -M -o1 -o3 \
      "(?s)^ {4}Stream #0:(\\d+)[^:]*: Subtitle: ass( \\(default\\))?$(
      )\n.*?^ {6}title *:( [^\n]+)")
    stream="${streams["$stream"]}"
    if [ -z ${stream:++} ]
    then
      echo "No subtitle with given title found." >&2
      exit 1
    fi
  fi
fi < <(ffmpeg -dump_attachment:t '' -i "$input" 2>&1)
readonly sub=$(mktemp -u XXXXXXXXXX.ass)
ffmpeg -i "$input" -map "0:${stream-s:0}" "$sub" 2>"${target=/dev/null}"

msg 'Compile video.'
readonly name="${input##*/}"
ffmpeg -i "$input" -vf ass="$sub" -sn "${pass[@]}" "$(env - \
  file="$name" name="${name%.*}" ext="${name##*.}" \
  path="${input%%/*}" envsubst <<< "$output")"

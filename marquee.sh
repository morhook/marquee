#!/bin/bash

TEXT="$*"

function calculate_toilet_width() {
  local text="$1"
  local max_width=$(tput cols)
  local output=$(print_banner "$text" | sed 's/\x1b\[[0-9;]*m//g')
  local max_pos=0
  while IFS= read -r line; do
    local line_length=${#line}
    if ((line_length > max_pos)); then
      max_pos=$line_length
    fi
  done <<<"$output"
  echo $max_pos
}

function print_banner() {
  MAX_COLS=$(tput cols)
  toilet -w $MAX_COLS -t -f smblock --filter metal -- "$1 " | lolcat -i --seed=1
  # This is necessary since toilet or lolcat reset the cursor visibility
  tput civis
}

function rotate_text() {
  TEXT="$1"
  LENGTH_TEXT=${#TEXT}
  CUT_LENGTH=$(echo $LENGTH_TEXT - 1 | bc)
  TEXT_TMP="${TEXT:1:$CUT_LENGTH}"
  echo "${TEXT_TMP}${TEXT:0:1}"
}

function reset_banner() {
  clear
  local MAX_COLS=$(tput cols)
  local TEXT_LENGTH=$(calculate_toilet_width "$TEXT")
  local SPACES=$(expr $MAX_COLS - $TEXT_LENGTH - 3)
  local WHITESPACES=$(printf "%-${SPACES}s" "")
  BANNER=$WHITESPACES$TEXT

  # echo -e "\n\n\n\n\n"
  # echo Max Cols: $MAX_COLS
  # echo Text Length: $TEXT_LENGTH
  # echo Spaces: $SPACES
  # echo Banner length: $(echo "$BANNER" | wc -m)
  # echo "Banner: =$BANNER="
}

trap reset_banner SIGWINCH
trap "tput cnorm; exit" INT TERM EXIT

reset_banner

while true; do
  tput cup 0 0
  print_banner "$BANNER"
  BANNER=$(rotate_text "$BANNER")
  sleep 0.8
  # Comment/Uncomment next two lines for blinking mode
  clear
  sleep 0.01
done

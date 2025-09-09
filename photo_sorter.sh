#!/usr/bin/env bash

PHOTO_DIR=/home/pme/Pictures/astro/moon/2025.09.07

printhelp() {
	echo "this is the help menu"
	echo "by default this program scans the current directory and sorts all found photos"
	echo "usage:"
	echo "  -h: print this help text"
	echo "  -f: from directory: move files from there"
	echo "  -t: to directory: move files to this"
}

getstats() {
  exiftool -s3 -T -n -q -$1 $PHOTO_DIR/*.CR2
}

scan_files() {
  echo "scanning $1 values ..."
  local -n arr=$2

  while IFS=$'\t' read -r iso; do
    [[ -n $iso ]] || continue
    (( arr["$iso"]++ ))
  done < <(getstats $1)

  echo "done"
}

count_meta() {
  local -n arr=$2
  local most_count=0 local most_iso=0
  for iso in "${!arr[@]}"; do
    count=${arr[$iso]}
    if (( count > most_count )); then
      most_iso=$iso
      most_count=$count
    fi
  done

  printf "most used $1:\t$most_iso\n"
  printf "photos using this value:\t$most_count\n"
  printf "different "$1"s:\t${#arr[@]}\n"
  printf "\n"
}

scanner() {
  scan_files $1 $2
  count_meta $1 $2
}

main() {
  echo 1
}

declare -A iso_count
declare -A shutter_count
declare -A focal_count
declare -A temp_count

#read -r distinct most < <(foo "/home/pme/Pictures/astro/moon/2025.09.07/")

scanner "ISO" iso_count
scanner "ShutterSpeed" shutter_count
scanner "FocalLength" focal_count
scanner "CameraTemperature" temp_count

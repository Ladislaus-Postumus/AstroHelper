#!/usr/bin/env bash

if [[ $1 == "-h" || $1 == "--help" || $1 == "-?" ]] then
	echo "This script will move astrophotos from <from directory> to <to directory> and sort them into lights/darks/biases/flats/testframes"
	echo "Usage: photo-sorter.sh <from directory> <to directory>"
	exit 0
fi

FROM_DIR=$1
TO_DIR=$2
ERRORS=0

if [[ ! -d $FROM_DIR ]] then
	echo "$FROM_DIR does not exist or is not a directory" >&2
	ERRORS=1
fi

if [[ ! -n $(ls $FROM_DIR) ]] then
	echo "$FROM_DIR does not contain any files" >&2
	ERRORS=1
fi

if [[ ! -d $TO_DIR ]] then
	echo "$TO_DIR does not exist or is not a directory" >&2
	ERRORS=1
fi

if [[ ERRORS -eq 1 ]] then
	exit 1
fi


# PHOTO_DIR=/home/pme/Pictures/astro/moon/2025.09.07

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
  local most_count=0
  local most_value=0

  for value in "${!arr[@]}"; do
    count=${arr[$value]}
    if (( count > most_count )); then
      most_value=$value
      most_count=$count
    fi
  done

  echo $most_value $most_count $amount
}

scanner() {
  scan_files $1 $2
  count_meta $1 $2
}

main() {
  declare -A focal_count
  local most_value most_count amount
  read -r most_value most_count amount <(scanner "FocalLength" focal_count)

  printf "most used $1:\t$most_iso\n"
  printf "photos using this value:\t$most_count\n"
  printf "different "$1"s:\t${#arr[@]}\n"
  printf "\n"
}

#declare -A iso_count
#declare -A shutter_count
#declare -A temp_count

#read -r distinct most < <(foo "/home/pme/Pictures/astro/moon/2025.09.07/")

# scanner "ISO" iso_count
# scanner "ShutterSpeed" shutter_count
# scanner "CameraTemperature" temp_count

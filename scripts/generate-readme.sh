#!/bin/bash

root=$(pwd)
README="$root/README.md"
echo -e '# Summary' >$README

function generate() {
  local DIR=$1
  local anchor=$2
  local filenames=$(ls $DIR)

  for filename in ${filenames[@]}; do
    local dir="$DIR/$filename"
    if [ -d $dir ]; then
      echo -e "\n$anchor $filename\n" >>$README
      generate "$dir" "$anchor#"
    elif [ -f $dir ]; then
      echo "- [$filename]($dir)" >>$README
    fi
  done
}

generate './chapters' '##'
echo 'done'

#!/bin/bash

# assign env var, if set
HB="${HOMEBREW_PREFIX:=/usr/local}"

find -L "${HB}/opt" -name 'INSTALL_RECEIPT.json' -maxdepth 2 -print0 | xargs -0 -n 200 grep -l "\"built_as_bottle\":false" > /tmp/not-built-bottles.txt.bkup

# cat /tmp/not-built-bottles.txt.bkup | xargs -n 200 grep -l -v "\"used_options\":\[\]" > /tmp/not-built-bottles_w-options.txt.bkup

[ -f /tmp/not-built-bottles_w-options.txt ] && rm /tmp/not-built-bottles_w-options.txt
touch /tmp/not-built-bottles_w-options.txt

NAME=''
OPTIONS=''
while IFS= read -r file
do
  # get the formula name
  NAME=$(echo -n "$file" | sed -E "s|^${HB}/opt/([^/]+)/INSTALL_RECEIPT.json$|\1|")
    
  # get, cleanup and append used options
  OPTIONS=$(grep -l -v "\"used_options\":\[\]" "$file")
  
  if [ -z "$OPTIONS" ]; then
    NAME_OPTS="${NAME}"
  else
    OPTIONS=$(sed -E -e 's/^.+"used_options":\[([^]]+)\].*$/\1/' -e 's/"//g' -e "s/,/ /g" "$file")
    NAME_OPTS="${NAME} ${OPTIONS}"
  fi
  
  echo "${NAME_OPTS}" >> /tmp/not-built-bottles_w-options.txt
  
done < /tmp/not-built-bottles.txt.bkup


open /tmp/not-built-bottles_w-options.txt

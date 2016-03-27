#!/bin/bash

# assign env var, if set
HB="${HOMEBREW_PREFIX:=/usr/local}"

find -L "${HB}/opt" -name 'INSTALL_RECEIPT.json' -maxdepth 2 -print > /tmp/homebrew-installed.txt

printf '' > /tmp/homebrew-installed-w-options.txt

NAME=''
OPTIONS=''
NAMES=''
NAME_OPTS=''
while IFS= read -r file
do
  # get the formula name
  NAME=$(printf "$file" | sed -E "s|^${HB}/opt/([^/]+)/INSTALL_RECEIPT.json$|\1|")
    
  # get, cleanup and append used options
  OPTIONS=$(grep -l -v "\"used_options\":\[\]" "$file")
  
  if [ -z "$OPTIONS" ]; then
    NAMES+="${NAME}
"
  else
    OPTIONS=$(sed -E -e 's/^.+"used_options":\[([^]]+)\].*$/\1/' -e 's/"//g' -e "s/,/ /g" "$file")
    NAME_OPTS+="${NAME} ${OPTIONS}
"
  fi
  
done < /tmp/homebrew-installed.txt

printf "${NAME_OPTS}" >> /tmp/homebrew-installed-w-options.txt
printf "${NAMES}" >> /tmp/homebrew-installed-w-options.txt

echo "Opening /tmp/homebrew-installed-w-options.txt"
nano /tmp/homebrew-installed-w-options.txt

#!/bin/bash

entries=()
for item in $@
do
  if [[ ! $item =~ "-W" ]];then 
    entries+=($item) 
  fi
done

echo $entries

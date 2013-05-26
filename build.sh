#!/bin/bash

files=( \
  js/coffee/wrapper/yat.js \
  js/coffee/backbone/models/navigationViewManager.js \
  js/coffee/backbone/views/templates.js \
  js/coffee/backbone/views/overviewView.js \
  js/coffee/backbone/views/viewportItemView.js \
  js/coffee/backbone/views/viewportView.js \
  js/coffee/backbone/views/navigationElementView.js \
  js/coffee/backbone/views/navigationView.js \
  js/coffee/backbone/views/timelineView.js \
  js/coffee/backbone/models/item.js \
  js/coffee/backbone/collections/items.js \
  js/coffee/backbone/app.js \
)

baseDir=`dirname $0`

counter=0
while [ $counter -lt ${#files[@]} ]; do
  files[$counter]="$baseDir/${files[$counter]}"
  let counter=counter+1
done

if [ -z "$1" ]
  then
    normal=yat.js
    minified=yat.min.js
  else
    normal=$1
fi

if [ -a $normal ]
  then
    rm $normal
fi

cat ${files[*]} >> $normal
jsmin < "$normal" > "$minified"
#!/bin/bash

files=( \
  js/libs/underscore-min.js \
  js/libs/backbone-min.js \
  js/libs/jquery.event.scroll.js \
  js/libs/jquery.ba-resize.min.js \
  js/libs/hammer.js \
  js/libs/moment.js \
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
    minified=yat.js
  else
    minified=$1
fi

if [ -a $minified ]
  then
    rm $minified
fi

cat ${files[*]} >> $minified
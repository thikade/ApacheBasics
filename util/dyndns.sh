#!/bin/bash

H=$(hostname)

case $H in

ap00|centos6)
   u=http://sync.afraid.org/u/xxx/
   ;;
ap01)
   u=http://sync.afraid.org/u/xxx/
   ;;

esac

# echo url is: $u
if [ -n "$u" ]; then
  # curl -s $u >> /tmp/freedns_${H}_my_to.log 2>/dev/null
  curl -s $u | tee -a /tmp/freedns_${H}_my_to.log 2>/dev/null
else
  echo "host not found: $H"
fi


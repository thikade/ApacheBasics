#!/bin/bash

pwd_array=( KiQEb6C2 4cTF2imn 1LgszMFS Y5c31Hjw X29GhTtw Uw5q4L2f NHf5Bb7y Fgf6CfA9 eqgw4IMv 1PLrXCkT mz6IhBll DaCh6oNr )

START=$1
END=$2

if [ "$START" = "" -o "$END" = "" ]; then
 START=1
 END=12
fi

for i in `seq -f "%02.0f" $START $END`; do
  index=`expr $i - 1`
  newPwd=${pwd_array[$index]}
  newhost=ap${i}
  echo ""
  echo "$newhost ==> $newPwd"

  nc -z -w2 $newhost 22 >/dev/null
  isUp=$?

  if [ $isUp -eq 0 ]; then
     echo "ssh  root@$newhost ..."
     ssh -q -o "PasswordAuthentication=no" root@$newhost "echo $newPwd | passwd --stdin student"
  else 
     echo "host $newhost not up!"
  fi

done

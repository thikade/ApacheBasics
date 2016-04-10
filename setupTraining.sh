#!/bin/bash

EXEC_DIR=$HOME/ApacheBasics
cd $EXEC_DIR

USER=student
USER_HOME=/home/$USER
USER_BIN=$USER_HOME/bin
EXAMPLE_DIR=$USER_HOME/apache
EXAMPLE_BACKUP_DIR=$USER_HOME/backup

if [ "$1" = "clean"  -o "$1" = "purge" ]; then
  echo "deleteing user $USER and his home $USER_HOME"
  echo "press Strg-c to abort in the next 1 seconds..."
  sleep 1
  userdel -r $USER
  rm -rf $USER_HOME
fi

if [ "$1" = "purge" ]; then
  echo "purge completed. exiting."
  echo ""
  exit 0
fi

id $USER > /dev/null 2>&1
RC=$?
if [ $RC -ne 0 ]; then
  useradd -m $USER
  echo "user \"$USER\" created!"
else 
  echo "user \"$USER\" exists!"
fi

echo ""

if [ -d $EXAMPLE_DIR ]; then
  sudo su - $USER -c "mkdir $EXAMPLE_BACKUP_DIR 2>/dev/null; tar czf $EXAMPLE_BACKUP_DIR/apache_`date +%Y%m%d_%H.%M.%S`.tgz -C $USER_HOME apache "
fi
sudo su - $USER -c "mkdir $EXAMPLE_DIR  2> /dev/null"
sudo su - $USER -c "mkdir bin 2> /dev/null"
sudo su - $USER -c "mkdir www 2> /dev/null"

# copy assets: bin
cp -r userDir/bin/* ${USER_BIN}/
chown -R $USER  ${USER_BIN}/

# copy assets: apache examples
cp -r userDir/apache/* ${EXAMPLE_DIR}/

# replace "${HOME}" with /home/$USER for better readability
perl -i -pe "s,\\$\\{HOME\\},/home/$USER," ${EXAMPLE_DIR}/*/conf/httpd.conf

chown -R $USER  ${EXAMPLE_DIR}/

# copy asset: bash completion 
sudo cp userDir/a2ctl.completion /etc/bash_completion.d/a2ctl

# copy www directory to /home/$USER/www
cp -r www/* $USER_HOME/www/


find $USER_HOME/www -type d | xargs chmod a+rx 
find $USER_HOME/www -type f | xargs chmod a+r  
chown -R $USER $USER_HOME/www
chmod a+rx $USER_HOME

# ls -l `dirname $EXAMPLE_DIR`
# ls $EXAMPLE_DIR
# find $USER_HOME/www -ls 

cd ${EXAMPLE_DIR}

echo ""
echo "done!"

#!/bin/bash

USER=student
USER_HOME=/home/$USER
USER_BIN=$USER_HOME/bin
EXAMPLE_DIR=$USER_HOME/apache

###########################
# APACKGE INSTALLATION
###########################
# yum -y -q update
# yum -y -q install httpd man telnet nc strace lsof git links
# yum -y -q install epel-release.noarch 
# yum -y -q install bash-completion

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
  # cp -r $EXAMPLE_DIR $EXAMPLE_DIR.`date +%Y%m%d_%H.%M.%S` 
  su - $USER -c "tar czf $EXAMPLE_DIR.`date +%Y%m%d_%H.%M.%S`.tgz $EXAMPLE_DIR "
fi
su - $USER -c "mkdir $EXAMPLE_DIR  2> /dev/null"
su - $USER -c "mkdir bin 2> /dev/null"
su - $USER -c "mkdir www 2> /dev/null"

# copy assets: bin
cp -r userDir/bin/* ${USER_BIN}/
chown -R $USER  ${USER_BIN}/

# copy assets: apache examples
cp -r userDir/apache/* ${EXAMPLE_DIR}/
chown -R $USER  ${EXAMPLE_DIR}/

# copy asset: bash completion 
cp userDir/a2ctl.completion /etc/bash_completion.d/a2ctl

# copy www directory to /home/$USER/www
cp -r www/* $USER_HOME/www/
find $USER_HOME/www -type d -exec chmod a+rx \;
find $USER_HOME/www -type f -exec chmod a+r  \;
chown -R $USER $USER_HOME/www

ls -l `dirname $EXAMPLE_DIR`
ls $EXAMPLE_DIR
find $USER_HOME/www -ls 

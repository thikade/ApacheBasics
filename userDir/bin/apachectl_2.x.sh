#!/bin/sh
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# Apache control script designed to allow an easy command line interface
# to controlling Apache.  Written by Marc Slemko, 1997/08/23
#
# The exit codes returned are:
#   XXX this doc is no longer correct now that the interesting
#   XXX functions are handled by httpd
#       0 - operation completed successfully
#       1 -
#       2 - usage error
#       3 - httpd could not be started
#       4 - httpd could not be stopped
#       5 - httpd could not be started during a restart
#       6 - httpd could not be restarted during a restart
#       7 - httpd could not be restarted during a graceful restart
#       8 - configuration syntax error
#
# When multiple arguments are given, only the error from the _last_
# one is reported.  Run "apachectl help" for usage info
#
ARGV="$@"
#
# |||||||||||||||||||| START CONFIGURATION SECTION  ||||||||||||||||||||
# --------------------                              --------------------
#
# the path to your httpd binary, including options if necessary
HTTPD='/usr/sbin/httpd'
#
#
# a command that outputs a formatted text version of the HTML at the
# url given on the command line.  Designed for lynx, however other
# programs may work.
if [ -x "/usr/bin/links" ]; then
  LYNX="/usr/bin/links -dump"
else
  LYNX=none
fi
#
# the URL to your server's mod_status status page.  If you do not
# have one, then status and fullstatus will not work.
STATUSURL="http://localhost:80/server-status"

# Source /etc/sysconfig/httpd for $HTTPD setting, etc.
if [ -r /etc/sysconfig/httpd ]; then
   . /etc/sysconfig/httpd
fi

# Start httpd in the C locale by default.
HTTPD_LANG=${HTTPD_LANG-"C"}

#
# Set this variable to a command that increases the maximum
# number of file descriptors allowed per child process. This is
# critical for configurations that use many file descriptors,
# such as mass vhosting, or a multithreaded server.
ULIMIT_MAX_FILES="ulimit -S -n `ulimit -H -n`"
# --------------------                              --------------------
# ||||||||||||||||||||   END CONFIGURATION SECTION  ||||||||||||||||||||

# Set the maximum number of file descriptors allowed per child process.
if [ "x$ULIMIT_MAX_FILES" != "x" ] ; then
    $ULIMIT_MAX_FILES
fi

ERROR=0
if [ "x$ARGV" = "x" ] ; then
    ARGV="-h"
fi

function checklynx() {
if [ "$LYNX" = "none" ]; then
   echo "The 'links' package is required for this functionality."
   exit 8
fi
}

function testconfig() {
# httpd is denied terminal access in SELinux, so run in the
# current context to get stdout from $HTTPD -t.
if test -x /usr/sbin/selinuxenabled && /usr/sbin/selinuxenabled; then
  runcon -- `id -Z` $HTTPD $OPTIONS -t
else
  $HTTPD $OPTIONS -t
fi
ERROR=$?
}

case $ARGV in
restart|graceful)
    if $HTTPD $OPTIONS -t >&/dev/null; then
       LANG=$HTTPD_LANG $HTTPD $OPTIONS -k $ARGV
       ERROR=$?
    else
       echo "apachectl: Configuration syntax error, will not run \"$ARGV\":"
       testconfig
    fi
    ;;
start|stop|graceful-stop)
    LANG=$HTTPD_LANG $HTTPD $OPTIONS -k $ARGV
    ERROR=$?
    ;;
configtest)
    testconfig
    ;;
status)
    checklynx
    set -o pipefail
    $LYNX $STATUSURL | awk ' /process$/ { print; exit } { print } '
    if [[ $? != 0 ]] ; then
        ERROR=3
    fi
    ;;
fullstatus)
    checklynx
    $LYNX $STATUSURL
    ;;
*)
    LANG=$HTTPD_LANG $HTTPD $OPTIONS $ARGV
    ERROR=$?
esac

exit $ERROR

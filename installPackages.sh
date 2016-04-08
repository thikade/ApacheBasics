#!/bin/bash

P="httpd httpd-tools man telnet nc strace curl wget lsof git links bind-utils wireshark"
P="$P yum-utils bash-completion"

###########################
# PACKAGE INSTALLATION
###########################
yum -y -q update
yum -y -q install epel-release.noarch 
yum -y -q install $P
echo ""
echo "yum installed: $P"

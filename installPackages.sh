#!/bin/bash

###########################
# PACKAGE INSTALLATION
###########################
yum -y -q update
yum -y -q install httpd man telnet nc strace lsof git links
yum -y -q install epel-release.noarch 
yum -y -q install bash-completion


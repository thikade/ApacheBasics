#!/bin/bash

###########################
# PACKAGE INSTALLATION
###########################
yum -y -q update
yum -y -q install httpd man telnet nc strace curl wget lsof git links bind-utils wireshark
yum -y -q install epel-release.noarch 
yum -y -q install bash-completion


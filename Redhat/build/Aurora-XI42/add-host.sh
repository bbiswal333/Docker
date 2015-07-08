#!/bin/bash
host1line=`grep \`uname -n\` /etc/hosts`
cp /etc/hosts /etc/hosts.old
host1line=`grep \`uname -n\` /etc/hosts`
sed  "/$host1line/s/$/ sapboxi42/" /etc/hosts.old > /etc/hosts



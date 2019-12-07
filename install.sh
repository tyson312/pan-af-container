#!/bin/bash
# updated by Tyson Reed for docker OCT2019

#Tell the installer the root of the files to download
REPO="https://raw.githubusercontent.com/p0lr/PAN-AF/master/"

# TR: get caches and update software
apt update
apt upgrade -y
apt install cron rsyslog systemd wget python2.7 -y

# TR: start syslogging
service rsyslog restart

#install the python requests module
apt-get install python-requests -y

#install sqlite3
apt-get install sqlite3 -y

#install python-pip
apt-get install python-pip -y

#install xmldiff
pip install xmldiff

#create the directory for the primary dug code to live
cd /var
mkdir dug
chown www-data dug
chgrp www-data dug
cd /var/dug
#create the devices database
touch create.sql
chmod 777 create.sql
echo 'CREATE TABLE DevicesDynamic (DeviceName "TEXT", DeviceMac "TEXT", Groups "Text");' > create.sql
sqlite3 devices.sql < create.sql
rm create.sql
#install the code that updates the firewall
wget -q ${REPO}dug.py
#create the log file
touch dug.log
#Set owner, group, and permissions of files in /var/dug
chown www-data *.*
chgrp www-data *.*
chmod 755 *.*

#update cron to execute the script every minute
cd /etc/cron.d
wget -q ${REPO}dugcron
service cron restart

#install apache2 and configure it to allow cgi
apt-get install apache2 -y
a2enmod cgid
service apache2 restart

#copy cgi scripts into the cgi directory
cd /usr/lib/cgi-bin
wget -q ${REPO}index.cgi
wget -q ${REPO}keygen.cgi
wget -q ${REPO}vlan.cgi
wget -q ${REPO}usermap.cgi
wget -q ${REPO}groupmap.cgi
wget -q ${REPO}clearusers.cgi
wget -q ${REPO}arp.cgi
wget -q ${REPO}dhcp.cgi
wget -q ${REPO}dhcputil.cgi
wget -q ${REPO}policy.cgi
wget -q ${REPO}duglog.cgi
wget -q ${REPO}syslog.cgi
wget -q ${REPO}messageslog.cgi
wget -q ${REPO}accesslog.cgi
wget -q ${REPO}errorlog.cgi
wget -q ${REPO}manback.cgi
wget -q ${REPO}software.cgi
wget -q ${REPO}changes.cgi
wget -q ${REPO}menu.html
chown www-data *.*
chgrp www-data *.*
chmod 755 *.*

#log permissions and rotation configuration
chmod 644 /var/log/syslog
chmod 644 /var/log/messages
cd /etc
mv rsyslog.conf rsyslog.conf.orig
wget -q ${REPO}rsyslog.conf
chown root rsyslog.conf
chgrp root rsyslog.conf
chmod 755 rsyslog.conf
mv logrotate.conf logrotate.conf.orig
wget -q ${REPO}logrotate.conf
chown root logrotate.conf
chgrp root logrotate.conf
chmod 755 logrotate.conf

chmod 755 /var/log/apache2
chmod 644 /var/log/apache2/access.log
chmod 644 /var/log/apache2/error.log
cd /etc/logrotate.d
rm apache2
wget -q ${REPO}apache2
chown root apache2
chgrp root apache2
chmod 644 apache2

#copy default web pages
cd /var/www/html
rm index.html
wget -q ${REPO}index.html
wget -q ${REPO}logo.svg
wget -q ${REPO}style.css
wget -q ${REPO}favicon.ico
touch macs.txt
touch rsa.csv
chown www-data *.*
chgrp www-data *.*
chmod 755 *.*

cd /var
mkdir autoback
chown www-data autoback
chgrp www-data autoback
cd /var/autoback
wget -q ${REPO}autoback.py
chown www-data *.*
chgrp www-data *.*
chmod 755 *.*

#harden the Raspberry Pi
#systemctl disable avahi-daemon
#systemctl stop avahi-daemon
#systemctl disable triggerhappy
#systemctl stop triggerhappy

#harden Apache -- TR: file doesn't exist in repo any longer so skip this step
#cd /etc/apache2/conf-available
#rm -f security.conf
#wget -q ${REPO}security.conf
#systemctl restart apache2
apachectl start

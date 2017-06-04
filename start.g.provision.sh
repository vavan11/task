#!/bin/bash
ssh-keygen -f "/home/metaxa/.ssh/known_hosts" -R 130.211.69.83
scp provision.g.cloud.sh ssh Google:~
scp server.xml ssh Google:~
scp default ssh Google:~
ssh Google 'chmod +x ~/provision.g.cloud.sh'
ssh Google './provision.g.cloud.sh'
sleep 5 && gnome-terminal -x sh -c 'ssh PortForvAmazon; exec bash'

#!/bin/bash
gcloud compute instances create confluence --image-project ubuntu-os-cloud --image-family ubuntu-1604-lts --boot-disk-size 20GB --can-ip-forward --machine-type n1-standard-2 --description confluence --address 130.211.69.83
sleep 30 && gcloud compute ssh vovamelnik@confluence --ssh-key-file ~/.ssh/id_rsa --plain
ssh-keygen -f "/home/metaxa/.ssh/known_hosts" -R 130.211.69.83
sleep 2 && scp provision.g.cloud.sh ssh Google:~
scp server.xml ssh Google:~
scp default ssh Google:~
ssh Google 'chmod +x ~/provision.g.cloud.sh'
ssh Google './provision.g.cloud.sh'
sleep 5 && gnome-terminal -x sh -c 'ssh PortForvAmazon; exec bash'

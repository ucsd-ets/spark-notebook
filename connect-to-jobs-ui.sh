#!/bin/bash

UIDX=$(id -u)
PAD=$(printf "%05d" $UIDX)
KUBECONFIG=/home/linux/dsmlp/${PAD: -2}/${PAD: -3}/$USER/.kube/config


function ssh_command() {
 

 kubecommand=$(echo "python3 /opt/forward.py $USER $KUBECONFIG")
}

ssh_command
echo $kubecommand

ssh $USER@dsmlp-login.ucsd.edu $kubecommand
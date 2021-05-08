#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
sudo apt-get install ansible -y

sudo apt-get install tree -y

# dependencies for vault
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
sudo apt install python3-pip -y

pip3 install awscli
pip3 install boto boto3

sudo apt-get update -y
sudo apt-get upgrade -y

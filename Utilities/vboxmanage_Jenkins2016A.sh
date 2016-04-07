#!/bin/bash

#This script clones an existing VirtualBox VM to create a new one called Jenkins2016A.
#It then configures the VM so that you will be able to see its Jenkins instance on the 
#host machine's 7070 port, and connect to it over ssh on port 2016.

#The objective is to make it simpler to test a build script on a pristine server. The
#source PreJenkins machine is running Ubuntu Server 16.04, vanilla install, with SSH
#server and little else. It should have a script called make_jenkins.sh in the user's
#home directory. PreJenkins should be kept updated but nothing else.

echo "Cloning the PreJenkins machine as Jenkins2016A..."
VBoxManage clonevm "PreJenkins" --name "Jenkins2016A" --options keepallmacs --options keepdisknames --register
VBoxManage modifyvm "Jenkins2016A" --natpf1 "jenkins,tcp,,7070,,8080"
VBoxManage modifyvm "Jenkins2016A" --natpf1 "guestssh,tcp,,2016,,22"
echo "VM configured. Now start the VM, log into it, and run ./make_jenkins.sh.
When it's all configured, run the script connect_to_Jenkins2016A.sh to connect to it."



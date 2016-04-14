#!/bin/bash

echo "Connecting to the Virtual Machine called Jenkins2016A"
echo "Sending Firefox to http://localhost:7070/"
firefox "http://localhost:7070/"
echo "Now ssh-ing into the machine."
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l hcmc -p 2016 localhost

# Jenkins
This repository contains a Dockerfile, job configurations, and instructions for setting up and maintaining Jenkins build servers for the TEI. 
A ready made Docker image is available on [hub.docker.com](https://hub.docker.com/r/teic/jenkins/), and if you have docker installed you should be able to pull it with:

<code>docker pull teic/jenkins</code>

and then you could run it with 

<code>docker run --rm --name teijenkins -p 8080:8080 -p 50000:50000 -v /your/jenkins_home:/var/jenkins_home teic/jenkins</code>

thus storing the data in `/your/jenkins_home` (mapped to `/var/jenkins_home` in the container).

Note that a complete run of TEI builds on the Jenkins server may take up more than 10GB of space on your drive.

## Detailed Instructions

When running this image for the first time, it is suggested that you start with an empty volume for `jenkins_home`. 
This will trigger a quick setup wizard where you'll add a user and may install additional plugins. 
(The plugins section may be skipped by deselecting all plugins – all necessary plugins are already installed in this image.)

Once you have access to the (still bare) Jenkins, you should go to the Jenkins administration panel ("configure system") and 

1. add Console Output Parsing: copy the file `tei-log-parse-rules` from this repository to your `jenkins_home`. 
    Then set "Parsing Rules File" to "/var/jenkins_home/tei-log-parse-rules" 
    and enter some appropriate description (e.g. "TEI log parse rules"). 
2. set/check the proper Jenkins URL 

Finally, copy the `jobs` directory to your `jenkins_home`, replacing the empty default directory. 
Click "Reload Configuration from Disk" for the changes to take effect.

Once you're set up, remember to backup/keep your data directory `/your/jenkins_home` 
so whenever you start a new container, it will inherit the job data and configuration.  

## Limitations
We do not install kindlegen for creating the .mobi version of the Guidelines, since this is non-free; and we do not do the minimal install of Oxygen which is required to build the Stylesheets documentation, since this requires a license. If either of these requirements is installed into the docker container, these build processes will begin working automatically. 

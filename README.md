# Jenkins

[![License](https://img.shields.io/github/license/teic/Jenkins.svg)](https://github.com/TEIC/Jenkins/blob/dev/LICENSE)
[![Docker Automated build](https://img.shields.io/docker/automated/teic/jenkins.svg)](https://hub.docker.com/r/teic/jenkins)
[![Docker](https://github.com/TEIC/Jenkins/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/TEIC/Jenkins/actions/workflows/docker-publish.yml)

This repository contains a Dockerfile, job configurations, and instructions for setting up and maintaining Jenkins build servers for the TEI. 
A ready made Docker image is available on [hub.docker.com](https://hub.docker.com/r/teic/jenkins/), and if you have docker installed you should be able to pull it with:

```
docker pull teic/jenkins
```

and then you could run it with 

```
docker run --rm --name teijenkins -p 8080:8080 -p 50000:50000 -v /your/jenkins_home:/var/jenkins_home teic/jenkins
```

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

Finally, we need to populate the `jobs` directory within `jenkins_home` and add the `tei-log-parse-rules` file;
these are available from a tar archive at `jenkins_home`, so you simply need to issue `tar xfz jobs.tar.gz` within this directory to put everything in place.
Click "Reload Configuration from Disk" for the changes to take effect.

Once you're set up, remember to backup/keep your data directory `/your/jenkins_home` 
so whenever you start a new container, it will inherit the job data and configuration.  


## Content Security Policy (CSP)

Jenkins 1.641 / Jenkins 1.625.3 introduced the [Content-Security-Policy](https://wiki.jenkins.io/display/JENKINS/Configuring+Content+Security+Policy) header to static files served by Jenkins.
Hence, the TEI Guidelines will display some artifacts (e.g. bibliography tooltips) when viewed from Jenkins. 
The CSP can be relaxed by passing the appropriate Java options to the Jenkins startup script, e.g.

```
docker run --env JAVA_OPTS="-Dhudson.model.DirectoryBrowserSupport.CSP='default-src self; img-src *'" …
```

## Usage of the Docker image *without* the Jenkins server 

The Docker image is also handy when you want to test or build the Guidelines (and/or Stylesheets) locally on your machine. 
You will need to mount the local Stylesheets and TEI directories into the container, and set the working directory.

### Use with Stylesheets

Navigate to the Stylesheets repo (you cloned from Github) and enter

```
docker run --rm -v `pwd`:/stylesheet -w /stylesheet -it --entrypoint "make" teic/jenkins:dev test
```

This will mount the current directory into the container and set the working directory within the container to that directory. We directly set the `make` command as entrypoint so everything after the image name will be appended to that `make` command as parameters. In the above example it's simply "test" for testing the current state; another useful target would be "dist" which creates the distributable files. 

### Use with Guidelines

Navigate to the Guidelines repo (you cloned from Github) and enter

```
docker run --rm -v `pwd`:/tei -w /tei/P5 -v /YOUR/PATH/TO/TEI-STYLESHEETS:/usr/share/xml/tei/stylesheet -it --entrypoint "make" teic/jenkins:dev test
```

This will mount the current directory into the container and set the working directory within the container to the subdirectory "P5". We directly set the `make` command as entrypoint so everything after the image name will be appended to that `make` command as parameters. In the above example it's simply "test" for testing the current state; another useful target would be "dist" which creates the distributable files. 


## Limitations

We do not install kindlegen for creating the .mobi version of the Guidelines, since this is non-free; and we do not do the minimal install of Oxygen which is required to build the Stylesheets documentation, since this requires a license. If either of these requirements is installed into the docker container, these build processes will begin working automatically. 

### add oXygen 

* Download oXygenXML editor from [Syncrosoft](http://oxygenxml.com) and extract/install it to some directory
* Mount this directoy (with the license file) into the container as `/usr/share/oxygen` 

### add kindlegen 

* Download KindleGen from [Amazon](https://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000765211)
* Mount the directoy (with the kindlegen binary) into the container as `/usr/share/kindlegen` 



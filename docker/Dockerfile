####DOCKER FILE FOR IMAGE OF TEI JENKINS SERVER####

# Written by Martin Holmes, December 2016. #

# We start from the latest Jenkins, which is based on
# openjdk:jdk-8, which is based ultimately on debian 
# jessie.

# As the Jenkins page says, the image should be started like
# this: 

# docker run --name teijenkins -p 8080:8080 -p 50000:50000 -v /your/home:/var/jenkins_home jenkins

# thus storing all jenkins data in /your/home, or like this:

# docker run --name teijenkins -p 8080:8080 -p 50000:50000 -v /var/jenkins_home jenkins

# My own version for the record:
# docker run --name teijenkins -p 8080:8080 -p 50000:50000 -v /home/mholmes/WorkData/tei/jenkins_home:/var/jenkins_home jenkins

# IMPORTANT NOTE: If you run this container, the VERY FIRST thing you should do is to 
#                 configure security in Jenkins. Out of the box, it allows anyone 
#                 to run any job without any login. DO NOT FORGET TO DO THIS.

FROM jenkins:latest
 
# Variables we'll use later on.
ARG JENKINS_USER_NAME="TEI Council"
ARG JENKINS_USER_EMAIL="tei-council@lists.tei-c.org"

# Need to switch to root user to install stuff.
USER root

# We need to build rnv locally since it's no longer packaged for
# Debian. Doing this before installing other stuff because it's
# quicker for testing purposes. We need make for that. Do apt-utils
# first so that it's available when other stuff is being installed.
# libexpat-dev is required to build rnv.
RUN apt-get update && apt-get --yes --force-yes --no-install-recommends install apt-utils
RUN apt-get --yes --force-yes --no-install-recommends install make build-essential libexpat-dev

RUN mkdir rnv && \
    git clone https://github.com/dtolpin/RNV.git rnv && \ 
    cd rnv && \ 
    make -f Makefile.gnu rnv && \
    cp rnv /usr/bin/ && \
    cd ../

# Install a bunch of packages we need. This package list has been 
# customized a little from the original 2016 builder script set,
# because we're working with Debian Jessie instead of Ubuntu.
# Many required packages are already installed upstream. 
# Various tex-related packages have been added as build failures
# revealed the need for them.
RUN apt-get update && apt-get --yes --force-yes --no-install-recommends install ant \ 
     debhelper \ 
     debiandoc-sgml \ 
     devscripts \ 
     fakeroot \
     fonts-arphic-ukai \ 
     fonts-arphic-uming \ 
     fonts-ipafont-gothic \ 
     fonts-ipafont-mincho \
     fonts-linuxlibertine \ 
     jing \ 
     libfile-fcntllock-perl \ 
     libjing-java \ 
     libsaxon-java \ 
     libsaxonhe-java \ 
     libtrang-java \ 
     libxml2-utils \ 
     linkchecker \ 
     linuxdoc-tools \ 
     lmodern \
     maven \ 
     openssh-server \ 
     psgml \ 
     texlive-fonts-recommended \ 
     texlive-generic-recommended \ 
     texlive-latex-extra \ 
     texlive-xetex \ 
     trang \ 
     ttf-baekmuk \ 
     ttf-dejavu \ 
     ttf-junicode \ 
     ttf-kochi-gothic \ 
     ttf-kochi-mincho \
     xmlstarlet \ 
     xsltproc \ 
     zip

# Now we have to get the one troublesome font that's not in any repo.
RUN mkdir /usr/share/fonts/truetype/hannom && \
    cd /usr/share/fonts/truetype/hannom && \
    wget -O hannom.zip http://downloads.sourceforge.net/project/vietunicode/hannom/hannom%20v2005/hannomH.zip && \
    unzip hannom.zip && \
    find . -iname "*.ttf" | rename 's/\ /_/g' && \
    rm hannom.zip && \
    fc-cache -f -v

# Next we'll grab some stuff from the TEI Jenkins repo on GitHub.
RUN mkdir Jenkins
RUN git clone https://github.com/TEIC/Jenkins.git Jenkins

# Configure settings for git
RUN git config --global user.email $JENKINS_USER_EMAIL
RUN git config --global user.name $JENKINS_USER_NAME

# Now we try installing Jenkins plugins.
# Recommended approach from hub.docker.com jenkins page:
# provide a file listing all the plugins you want to install.
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
    
# Put the log parser rules in place.
COPY tei-log-parse-rules /var/jenkins_home/tei-log-parse-rules

# Copy the jobs into place.
COPY jobs/ /var/jenkins_home/jobs/

# That should be it.

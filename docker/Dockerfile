####DOCKER FILE FOR IMAGE OF TEI JENKINS SERVER####

# We start from the latest Jenkins, which is based on
# openjdk:jdk-8, which is based ultimately on debian 
# jessie.

# As the Jenkins page says, the image should be started like
# this: 

# docker run --name teijenkins -p 8080:8080 -p 50000:50000 -v /your/home:/var/jenkins_home jenkins

# thus storing all jenkins data in /your/home, or like this:

# docker run --name teijenkins -p 8080:8080 -p 50000:50000 -v /var/jenkins_home jenkins

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
    
# Temporary: confirm rnv is there.
RUN ls /usr/bin/rnv

# Install a bunch of packages we need. This package list has been 
# customized a little from the original 2016 builder script set,
# because we're working with Debian Jessie instead of Ubuntu.
# Commented-out packages are those reported by the build process
# as being already installed, presumably by upstream images.
RUN apt-get update && apt-get --yes --force-yes --no-install-recommends install debhelper \ 
     debiandoc-sgml \ 
     devscripts \ 
     fonts-arphic-ukai \ 
     fonts-arphic-uming \ 
#     fonts-dejavu-core \ 
#     fonts-dejavu-extra \ 
     fonts-ipafont-gothic \ 
     fonts-ipafont-mincho \
     fonts-linuxlibertine \ 
#     git \ 
     jing \ 
     libjing-java \ 
     libsaxon-java \ 
     libsaxonhe-java \ 
     libtrang-java \ 
#     libxml2 \ 
     libxml2-utils \ 
     linkchecker \ 
     linuxdoc-tools \ 
     maven \ 
     openssh-server \ 
     psgml \ 
     texlive-fonts-recommended \ 
     texlive-latex-extra \ 
     texlive-xetex \ 
     trang \ 
     ttf-baekmuk \ 
     ttf-dejavu \ 
     ttf-junicode \ 
#     unzip \ 
#     wget \ 
     xmlstarlet \ 
     xsltproc \ 
     zip

# NOTE: NOT DOING THIS because of permissions issues;
# we'll chown stuff instead.
# We switch back to the jenkins user to install Jenkins plugins and
# configure jobs.
# USER jenkins

# Next we'll grab some stuff from the TEI Jenkins repo on GitHub.
RUN mkdir Jenkins
RUN git clone https://github.com/TEIC/Jenkins.git Jenkins

# Configure settings for git
RUN git config --global user.email $JENKINS_USER_EMAIL
RUN git config --global user.name $JENKINS_USER_NAME

# Now we try installing Jenkins plugins.
RUN mkdir /var/jenkins_home/plugins && \
    cd /var/jenkins_home/plugins && \ 
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/copyartifact.hpi && \ 
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/emotional-jenkins-plugin.hpi && \ 
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/greenballs.hpi && \ 
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/jobConfigHistory.hpi && \  
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/plot.hpi && \ 
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/log-parser.hpi && \ 
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/scp.hpi && \ 
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/PrioritySorter.hpi && \ 
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/scm-api.hpi && \ 
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/git.hpi && \ 
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/git-client.hpi && \ 
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/github.hpi && \ 
    wget --no-check-certificate https://updates.jenkins-ci.org/latest/github-api.hpi && \ 
    chown -R jenkins .
    



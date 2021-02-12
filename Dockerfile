####DOCKER FILE FOR IMAGE OF TEI JENKINS SERVER####

# Written by Martin Holmes, December 2016. #

# We start from the Jenkins lts version, which is based on
# openjdk:8-jdk, which is based ultimately on debian 
# stretch.

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

# First: building `rnv` locally since it's no 
# longer packaged for Debian 
FROM debian as builder

# We need `make` for that and 
# `libexpat-dev` is required to build `rnv`.
RUN apt-get update && apt-get --yes --no-install-recommends --no-install-suggests install ca-certificates git make build-essential libexpat-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/rnv && \
    git clone https://github.com/dtolpin/RNV.git /var/rnv && \ 
    cd /var/rnv && \ 
    make -f Makefile.gnu rnv


# Second: Build the final Jenkins image
FROM jenkins/jenkins:lts
LABEL maintainer="Martin Holmes and Peter Stadler for the TEI Council"
 
# Variables we'll use later on.
ARG JENKINS_USER_NAME="TEI Council"
ARG JENKINS_USER_EMAIL="tei-council@lists.tei-c.org"

# Need to switch to root user to install stuff.
USER root

# Copy build artefacts from first step
COPY --from=builder /var/rnv/rnv /usr/bin/ 

# Install a bunch of packages we need. This package list has been 
# customized a little from the original 2016 builder script set,
# because we're working with Debian Jessie instead of Ubuntu.
# Many required packages are already installed upstream. 
# Various tex-related packages have been added as build failures
# revealed the need for them.
RUN apt-get update && apt-get --yes --no-install-recommends --no-install-suggests install \
     ant \ 
     ant-optional \
     build-essential \
     debhelper \ 
     debiandoc-sgml \ 
     devscripts \ 
     fakeroot \
     fonts-linuxlibertine \ 
     # provides Noto font families for Traditional Chinese, Simplified Chinese, Japanese and Korean, see https://packages.debian.org/buster/fonts-noto-cjk
     fonts-dejavu \ 
     fonts-junicode \ 
     fonts-noto-cjk \
     jing \ 
     libcss-dom-perl \
     libfile-fcntllock-perl \ 
     libjing-java \ 
     libsaxon-java \ 
     libsaxonhe-java \
     libterm-readkey-perl \
     libtrang-java \
     libwww-perl \
     libxml2-utils \ 
     linuxdoc-tools \ 
     lmodern \
     make \
     maven \
     perl-modules \
     psgml \ 
     texlive-fonts-recommended \ 
     texlive-generic-recommended \ 
     texlive-latex-extra \ 
     texlive-xetex \ 
     trang \ 
     xmlstarlet \ 
     xsltproc \ 
     zip \
     && rm -rf /var/lib/apt/lists/*

# Install W3C linkchecker skript "checklink"
# https://dev.w3.org/perl/modules/W3C/LinkChecker/docs/checklink
RUN PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install W3C::LinkChecker'

# create a simple shell wrapper script for the 
# saxon.jar provided by the Debian libsaxonhe-java package 
RUN echo "#! /bin/bash" > /usr/local/bin/saxon \
    && echo "java -jar /usr/share/java/Saxon-HE.jar \$*" >> /usr/local/bin/saxon \
    && chmod 755 /usr/local/bin/saxon

# running as user jenkins for installing plugins,
# and finally starting the service
USER jenkins:jenkins
WORKDIR ${JENKINS_HOME}
RUN /usr/local/bin/install-plugins.sh \
    junit \
    script-security \
    matrix-project \
    structs \
    ssh-credentials \
    workflow-scm-step \
    workflow-step-api \
    maven-plugin \
    javadoc \
    display-url-api \
    mailer \
    plain-credentials \
    token-macro \
    credentials \
    git \
    git-client \
    copyartifact \
    emotional-jenkins-plugin \
    greenballs \
    jobConfigHistory \
    plot \
    log-parser \
    # disabled scp plugin due to "Insecure credential storage and transmission" warning
    #scp \
    PrioritySorter \
    scm-api \
    github \
    github-api \
    cors-filter \
    build-symlink

# copy the initial job configuration and log parse rules to /tmp
# for convenience, we tar it and copy it to /usr/share/jenkins/ref/
# in the next step, so it will be added the ${JENKINS_HOME} directory automatically
COPY jobs /tmp/jobs
COPY tei-log-parse-rules /tmp/tei-log-parse-rules

# Configure settings for git
# and save it for reuse
# because ${JENKINS_HOME} is declared as a volume
# and its content won't survive 
RUN git config --global user.email ${JENKINS_USER_EMAIL} \
    && git config --global user.name ${JENKINS_USER_NAME} \
    && cp .gitconfig /usr/share/jenkins/ref/ \
    && tar cfz /usr/share/jenkins/ref/jobs.tar.gz -C /tmp/ jobs tei-log-parse-rules

# That should be it.

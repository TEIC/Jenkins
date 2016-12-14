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

# Need to switch to root user to install stuff.
USER root

#Install a bunch of packages we need.
RUN apt-get update && apt-get --yes --force-yes --no-install-recommends install apt-utils \ 
     debhelper \ 
     debiandoc-sgml \ 
     devscripts \ 
     fonts-arphic-ukai \ 
     fonts-arphic-uming \ 
     fonts-dejavu-core \ 
     fonts-dejavu-extra \ 
     fonts-ipafont-gothic \ 
     fonts-ipafont-mincho \
     fonts-linuxlibertine \ 
     git \ 
     jing \ 
     jing \ 
     libjing-java \ 
     libsaxon-java \ 
     libsaxonhe-java \ 
     libtrang-java \ 
     libxml2 \ 
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
     unzip \ 
     wget \ 
     xmlstarlet \ 
     xsltproc \ 
     zip

#Next we'll grab some stuff from the TEI Jenkins repo on GitHub.
RUN mkdir Jenkins
RUN git clone https://github.com/TEIC/Jenkins.git Jenkins

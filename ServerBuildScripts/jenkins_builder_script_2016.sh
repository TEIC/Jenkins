#!/bin/bash
#The Mighty Jenkins Builder Script.

# This script is designed to set up a Jenkins Continuous
# Integration server which will build all of the TEI
# products automatically from the TEI SVN repository on
# SourceForge.

# For this to work, you will need a valid license for
# Oxygen, which is required for building some of the products.

# To use this script, first set up an Ubuntu 16.04 server
# with default configuration (no need to install anything
# in particular).

# Next, log into the server and create the directory
# /usr/share/oxygen, then put a file named licensekey.txt
# with the nine lines of text of the Oxygen license key
# (located between the license key start and end markers)
# into that directory.

# Then you can put this script on the server and run it
# as root to create the server build.

#Note that this should be run as root (with sudo).

# port the Jenkins server will listen to
JENKINS_PORT=8080
JENKINS_USER_NAME="TEI Council"
JENKINS_USER_EMAIL="tei-council@lists.tei-c.org"

#Required location of Oxygen licence.
OxyLicense="/usr/share/oxygen/licensekey.txt"

echo ""
echo "*******************************************"
echo "The purpose of this script is to set up a working
Jenkins Continuous Integration Server which will check
out and build a range of TEI products, including the
P5 Guidelines (in various formats) and the Roma schema
generation tool."
echo ""
echo "This script is designed to be run on a fully-updated
install of Ubuntu Xenial Xerus (Ubuntu 16.04). Xenial was
chosen because it is a Long-Term Support edition, and
will be maintained for several years from the time
of writing the script."
echo ""
echo "The script will fail to work on other versions of Ubuntu."
echo "*******************************************"
echo "Press return to continue"
read
echo ""
echo "*******************************************"
echo "In order for Jenkins to build the TEI packages, you will
need to have a registration key for the Oxygen XML Editor. "
echo ""
echo "You must provide a license for Oxygen, in the form of a
file named licensekey.txt with the nine lines of text of the
license key (located between the license key start and end
markers). "
echo ""
echo "This should be placed in /usr/share/oxygen. Create that
directory if it does not exist."
echo "This script will check for the existence of that file, and
terminate if it does not exist."
echo "*******************************************"
echo ""
echo "Do you want to continue? Press return to continue,
Control+c to stop."
read


#Save the current directory so that we can come back here.
currDir=`pwd`

echo ""
echo "Entering the Mighty Jenkins Builder Script."

uid=$(/usr/bin/id -u) && [ "$uid" = "0" ] ||
{ echo "This script must be run as root."; exit 1; }

echo "Running as root: good."
echo ""

if grep -q 16.04 /etc/lsb-release
then echo "Running on Ubuntu Xenial. Good."
else
  echo "This script needs to be run on Ubuntu Xenial Server."
  echo "According to /etc/lsb-release, you don't seem to be
running that version of Ubuntu."
  echo "Things are likely to break …."
#  exit
fi
echo ""
#Check for existence of an Oxygen licence key file in /usr/share/oxygen

if [ -f $OxyLicense ];
then echo "Oxygen license is in the right place."
else
  echo "You must provide a license for Oxygen, in the form of a
file named licensekey.txt containing the nine lines of text of
the license key (located between the license key start and end
markers). "
  echo "This should be placed in /usr/share/oxygen. Create that
directory if it does not exist."
  echo "The script will now terminate. Run it again when you
have installed the Oxygen license key."
  exit
fi

echo ""
echo "Using netstat to check whether any service is currently
running on port $JENKINS_PORT."
echo ""
netstat -tulpan | grep $JENKINS_PORT
if [ $? -eq 0 ]
then echo "Another service appears to be running on port $JENKINS_PORT,
which is the default port for Jenkins."
  echo "You can either continue, and then change the port on
which Jenkins runs later, or stop now, and move that service
to another port."
echo ""
  echo "Press return to continue, or Control+c to stop."
  read
fi


#Set -e so we exit if something goes wrong. More useful error messages
#would be helpful, in the future.
set -e

echo ""
echo "*******************************************"
echo "The following build process should proceed without
any need for intervention from you, but if it fails at
some point, you can start it again, or read through the
script and run each section separately to figure out what
the problem is."
echo "*******************************************"
echo ""

echo "Press return to continue"
read

#We used to start by installing the MS fonts, which have EULAs, so if we got that
#bit out of the way, the rest of the install could proceed basically unattended. But
#switching from Times New Roman to Libertine should remove that requirement.
#echo "We'll start by installing some fonts we need.
#You'll have to agree to a EULA here."
#apt-get -y install msttcorefonts

#Now do updates.
echo "Doing system updates before starting on anything else."
apt-get update
apt-get -y upgrade

#NOTE: THIS FAILS RIGHT NOW BECAUSE THE KOCHI FONTS HAVE BEEN DEPRECATED.
#SEEKING A SOLUTION.
echo "Installing required fonts."
apt-get -y install ttf-dejavu fonts-arphic-ukai fonts-arphic-uming ttf-baekmuk ttf-junicode fonts-linuxlibertine
#apt-get -y install ttf-kochi-gothic ttf-kochi-mincho
apt-get -y install fonts-ipafont-gothic fonts-ipafont-mincho
echo ""

#Now add the repositories we want.
echo "Backing up repository list."
cp /etc/apt/sources.list /etc/apt/sources.list.bak
echo ""

#Uncomment partner repos.
echo "Uncommenting partner repositories on sources list."
sed -i -re '/partner$/ s/^#//' /etc/apt/sources.list
echo ""

#First Jenkins
echo "Adding Jenkins repository."
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list
echo ""

#NOTE: THIS SHOULD REALLY NOT BE NEEDED, BUT THE STYLESHEETS BUILD PROCESS
#MAKES USE OF OXYGEN TOOLS THAT ARE PACKAGED IN THE TEI REPO AT THE MOMENT.
#Next TEI. Allow a 5-minute timeout for this one; it's insanely slow.
#NOTE -- given this tei.oucs repo no long exists this will have to change, presumably to clone github repo?
echo "Adding TEI Debian repository. It may take some time to retrieve the key."
gpg --keyserver wwwkeys.pgp.net --keyserver-options timeout=300 --recv-keys FEA4973F86A9A497
apt-key add ~/.gnupg/pubring.gpg
echo "deb http://tei.oucs.ox.ac.uk/teideb/binary ./" > /etc/apt/sources.list.d/tei.list
echo ""

#Now we can start installing packages.
echo "Updating for new repositories."
apt-get update
echo ""

#We will need a JDK, so we try to install the one to match the default OpenJDK JRE that's installed.
echo "Installing the OpenJDK Java Development Kit."
apt-get -y install openjdk-8-jdk
echo ""

#We need Maven and Git for the OxGarage install. Note: instead of maven2, we now have
#the generic "maven" package which at the time of writing is installing maven 3.
echo "Installing the Maven project tool, and Git"
apt-get -y install maven git
echo ""

echo "Installing core packages we need."
apt-get -y install openssh-server libxml2 libxml2-utils devscripts xsltproc libsaxonhe-java debhelper trang jing zip unzip &&
apt-get -y install texlive-xetex texlive-latex-extra texlive-fonts-recommended &&
echo "Installing curl, required for some tei building stuff."
apt-get -y install curl &&
echo ""
# linkchecker is needed for the linkchecker Jenkins project
echo "Installing linkchecker."
apt-get -y install linkchecker
echo ""

#We need to grab some stuff from the Internets. Saxon:
echo "Retrieving a copy of Saxon jar."

wget -O saxonhe.zip https://sourceforge.net/projects/saxon/files/latest/download?source=files
  if [ $? != 0 ]; then
  { 
     echo "Failed to download Saxon from SourceForge."
echo "This is fairly important, but if you have 
already installed Saxon on the system, it won't 
be a problem, so you can press return to continue. If you 
don't have Saxon already, please place a copy in /usr/bin/
and re-run this script."
    read
  }
  fi
echo "Setting up Saxon."
mkdir saxon
unzip -d saxon saxonhe.zip
chmod a+x saxon/saxon*.jar
cp saxon/saxon*.jar /usr/bin/

## NOTE: Above installs saxon but below saxon is also installed. 
## Testing on Debian8 the libsaxonb-java package installed saxon 9.1.0.8J 
## somewhat behind the 9.7 version on sourceforge.  But does this matter? 
## Should we use packaged version?

#Next we'll grab some stuff from the TEI Jenkins repo on GitHub.
mkdir Jenkins
git clone https://github.com/TEIC/Jenkins.git Jenkins

#TEI packages
#NOTE: THIS SET OF PACKAGES SHOULD SURELY BE TRIMMED. I KNOW WE NEED MANY OF THEM, THOUGH.
#There's an inordinate quantity of documentation that seems to come down with textlive-xetex;
#I'm trying --no-install-recommends to prevent that. 
echo "Installing TEI packages."
apt-get -y --no-install-recommends --force-yes install psgml xmlstarlet debiandoc-sgml linuxdoc-tools jing jing-trang-doc libjing-java texlive-xetex &&
apt-get -y --force-yes install libtrang-java saxon tei-p5-exemplars tei-roma tei-p5-doc tei-xsl tei-p5-source tei-p5-schema tei-oxygen zip &&
echo ""

#NOTE: Do we still need Hannom? What do we have in the Guidelines that uses Vietnamese?
#Need a LaTeX guru to look at the PDF build process. No harm in doing this for now, though.
if [ ! -d /usr/share/fonts/truetype/hannom ]
then
{
  echo "The Han Nom font is not available in repositories,
  so we have to download it from SourceForge."
  cd /usr/share/fonts/truetype
  mkdir hannom
  cd hannom
  wget -O hannom.zip http://downloads.sourceforge.net/project/vietunicode/hannom/hannom%20v2005/hannomH.zip
  if [ $? != 0 ]; then
  {
    echo "Failed to download Hannom font from SourceForge."
    echo "This is not crucial, but if you want to make sure it
is installed, press Control+C to exit now, and run this
script again. Otherwise, press return to continue."
    read
  } fi
  unzip hannom.zip
  find . -iname "*.ttf" | rename 's/\ /_/g'
  rm hannom.zip
  fc-cache -f -v

  #Go back to our home directory.
  cd $currDir
  echo "Changed back to $currDir"
} fi

#Downloading and installing rnv
echo "Downloading and building rnv (the RelaxNG validator) from SourceForge."
echo "First we need libexpat-dev, on which it depends."
apt-get -y install libexpat-dev
echo ""
echo "Now we download rnv, build and install it."
#This seems to be fragile. Let's catch it in case it fails. Lots of apparently good URLs fail when
#using wget, so I've fallen back on using curl -L. We'll see how reliable this is.
#wget -O rnv-1.7.10.zip http://sourceforge.net/projects/rnv/files/Sources/1.7.10/rnv-1.7.10.zip/download
#wget -O rnv-1.7.10.zip http://downloads.sourceforge.net/projects/rnv/Sources/1.7.10/rnv-1.7.10.zip?r=\&ts=1338494052\&use_mirror=iweb
#wget -O rnv-1.7.10.zip http://sourceforge.net/projects/rnv/files/Sources/1.7.10/rnv-1.7.10.zip/download?use_mirror=voxel

#NOTE: Rewritten. rnv is now at:
#         https://github.com/hartwork/rnv
#Zip is now here:
#         https://github.com/hartwork/rnv/archive/1.7.11.zip
#curl -L http://sourceforge.net/projects/rnv/files/Sources/1.7.10/rnv-1.7.10.zip/download > rnv-1.7.10.zip
#curl -L https://github.com/hartwork/rnv/archive/1.7.11.zip > rnv-1.7.11.zip
#if [ $? != 0 ]; then
#{
#    echo "Failed to download rnv source code from GitHub."
#    echo "This is not crucial, but if you want to make sure rnv
#is installed, press Control+C to exit now, and run this
#script again. Otherwise, press return to continue."
#    read
#} fi
#unzip rnv-1.7.11.zip
#if [ $? != 0 ]; then
#{
#    echo "Failed to unzip the rnv source code from GitHub."
#    echo "This is not crucial, but if you want to make sure rnv
#is installed, press Control+C to exit now, and run this
#script again. Otherwise, press return to continue."
#    read
#} fi
#cd rnv-1.7.11
#./configure
#make
#make install
#if [ $? != 0 ]; then
#{
#    echo "Failed to build and install rnv from GitHub."
#    echo "This is not crucial, but if you want to make sure rnv
#is installed, press Control+C to exit now, and run this
#script again. Otherwise, press return to continue."
#    read
#} fi

#NOTE: Version of rnv on Hartwork will not build. Getting dtolpin's instead.
mkdir rnv
git clone https://github.com/dtolpin/RNV.git rnv
cd rnv
make -f Makefile.gnu
cp rnv /usr/bin/

echo ""

#Jenkins
echo "Installing the Jenkins CI Server."
apt-get -y install jenkins
echo ""
echo "Replacing default port and waiting for Jenkins to restart …"
# Stop Jenkins if it's already started
/etc/init.d/jenkins stop
sleep 20
# replace the default port
sed -i "s/HTTP_PORT=.*$/HTTP_PORT=$JENKINS_PORT/" /etc/default/jenkins 

# start Jenkins
/etc/init.d/jenkins start
sleep 20

# Set up Jenkins' git identity
sudo -i -u jenkins git config --global user.email $JENKINS_USER_EMAIL
sudo -i -u jenkins git config --global user.name $JENKINS_USER_NAME

#NOTE: THE FOLLOWING FAILS with permission errors; it's not clear to me what's 
#causing the problem, but I think it's probably the case that we can't use the CLI
#on the default port any more. See https://github.com/TEIC/Jenkins/issues/1 as I 
#work on this issue.
#java -jar jenkins-cli.jar -s http://localhost:8080 version
#java.io.IOException: No X-Jenkins-CLI2-Port among [X-Jenkins, null, Server, X-Content-Type-Options, #X-You-Are-In-Group, X-Hudson, X-Permission-Implied-By, Date, X-Jenkins-Session, X-You-Are-Authenticated-As, #X-Required-Permission, Set-Cookie, Expires, Content-Length, Content-Type]
#	at hudson.cli.CLI.getCliTcpPort(CLI.java:284)
#	at hudson.cli.CLI.<init>(CLI.java:128)
#	at hudson.cli.CLIConnectionFactory.connect(CLIConnectionFactory.java:72)
#	at hudson.cli.CLI._main(CLI.java:473)
#	at hudson.cli.CLI.main(CLI.java:384)
#	Suppressed: java.io.IOException: Server returned HTTP response code: 403 for URL: http://localhost:8080/cli
#		at sun.net.www.protocol.http.HttpURLConnection.getInputStream0(HttpURLConnection.java:1840)
#		at sun.net.www.protocol.http.HttpURLConnection.getInputStream(HttpURLConnection.java:1441)
#		at hudson.cli.FullDuplexHttpStream.<init>(FullDuplexHttpStream.java:78)
#		at hudson.cli.CLI.connectViaHttp(CLI.java:152)
#		at hudson.cli.CLI.<init>(CLI.java:132)
#		... 3 more

#Now we need to find out what the Jenkins version is, and stash the result in a variable for later use.
#echo "Discovering Jenkins version..."
#cd /tmp
#wget http://localhost:$JENKINS_PORT/jnlpJars/jenkins-cli.jar
#JINKSVERSION=`java -jar jenkins-cli.jar -s http://localhost:$JENKINS_PORT version`
#echo "version $JINKSVERSION"


echo "Script tested up to here. Exiting for now..."
exit


#Configuration for Jenkins
#NOTE: Paths and filenames below are wrong; need to fix.
echo "Starting configuration of Jenkins."
cd /var/lib/jenkins
cp ${currDir}/tei-log-parse-rules ./
chown jenkins tei-log-parse-rules
cp ${currDir}/hudson.plugins.logparser.LogParserPublisher.xml ./
chown jenkins hudson.plugins.logparser.LogParserPublisher.xml
cp ${currDir}/jenkins.advancedqueue.PriorityConfiguration.xml ./
chown jenkins jenkins.advancedqueue.PriorityConfiguration.xml
echo ""

echo "Getting all the job data from TEI."
cp -R ${currDir}/jobs ./
chown -R jenkins jobs
echo ""

echo "Installing Jenkins plugins."
rm -rf plugins
mkdir plugins
chown -R jenkins plugins
cd plugins
wget --no-check-certificate https://updates.jenkins-ci.org/latest/copyartifact.hpi
chown jenkins copyartifact.hpi
wget --no-check-certificate https://updates.jenkins-ci.org/latest/emotional-jenkins-plugin.hpi
chown jenkins emotional-jenkins-plugin.hpi
wget --no-check-certificate https://updates.jenkins-ci.org/latest/greenballs.hpi
chown jenkins greenballs.hpi
wget --no-check-certificate https://updates.jenkins-ci.org/latest/jobConfigHistory.hpi
chown jenkins jobConfigHistory.hpi
wget --no-check-certificate https://updates.jenkins-ci.org/latest/plot.hpi
chown jenkins plot.hpi
wget --no-check-certificate https://updates.jenkins-ci.org/latest/log-parser.hpi
chown jenkins log-parser.hpi
wget --no-check-certificate https://updates.jenkins-ci.org/latest/scp.hpi
chown jenkins scp.hpi
wget --no-check-certificate https://updates.jenkins-ci.org/latest/PrioritySorter.hpi
chown jenkins PrioritySorter.hpi

#New Git-related plugins added March 2013 for OxGarage move to GitHub.
wget --no-check-certificate https://updates.jenkins-ci.org/latest/scm-api.hpi
chown jenkins scm-api.hpi
wget --no-check-certificate https://updates.jenkins-ci.org/latest/git.hpi
chown jenkins git.hpi
wget --no-check-certificate https://updates.jenkins-ci.org/latest/git-client.hpi
chown jenkins git-client.hpi
wget --no-check-certificate https://updates.jenkins-ci.org/latest/github.hpi
chown jenkins github.hpi
wget --no-check-certificate https://updates.jenkins-ci.org/latest/github-api.hpi
chown jenkins github-api.hpi
echo ""

echo "Stopping Jenkins server, so that we can reconfigure all the jobs a little."
/etc/init.d/jenkins stop
echo ""

#Reconfigure Jinks jobs with user's email, and adding priority settings if necessary.
#NOTE: Avoiding this, because you need to set up a whole host of Jenkins config files
#in order to make emailing work.
#echo "If you want Jenkins to notify you when a build fails, please enter your email address now:"
#read email

echo "Downloading various configuration files for Jenkins."
cd /var/lib/jenkins
cp ${currDir}/jenkins_job_config.xsl ./
chown jenkins jenkins_job_config.xsl
cp ${currDir}/jenkins_main_config.xsl ./
chown jenkins jenkins_main_config.xsl
cp ${currDir}/defaultConfig.xml config.xml
#mv defaultConfig.xml config.xml
saxon -s:/var/lib/jenkins/config.xml -xsl:/var/lib/jenkins/jenkins_main_config.xsl -o:/var/lib/jenkins/config.xml jinksVersion=$JINKSVERSION
chown jenkins config.xml
echo "Downloaded and set up root configuration file."

echo "Configuring job priorities settings."

echo "Running transformations on job configurations."
saxon -s:/var/lib/jenkins/jobs/OxGarage/config.xml -xsl:/var/lib/jenkins/jenkins_job_config.xsl -o:/var/lib/jenkins/jobs/OxGarage/config.xml email=
saxon -s:/var/lib/jenkins/jobs/Roma/config.xml -xsl:/var/lib/jenkins/jenkins_job_config.xsl -o:/var/lib/jenkins/jobs/Roma/config.xml email=
saxon -s:/var/lib/jenkins/jobs/Stylesheets/config.xml -xsl:/var/lib/jenkins/jenkins_job_config.xsl -o:/var/lib/jenkins/jobs/Stylesheets/config.xml email=
saxon -s:/var/lib/jenkins/jobs/TEIP5/config.xml -xsl:/var/lib/jenkins/jenkins_job_config.xsl -o:/var/lib/jenkins/jobs/TEIP5/config.xml email=
saxon -s:/var/lib/jenkins/jobs/TEIP5-Documentation/config.xml -xsl:/var/lib/jenkins/jenkins_job_config.xsl -o:/var/lib/jenkins/jobs/TEIP5-Documentation/config.xml email=
saxon -s:/var/lib/jenkins/jobs/TEIP5-Test/config.xml -xsl:/var/lib/jenkins/jenkins_job_config.xsl -o:/var/lib/jenkins/jobs/TEIP5-Test/config.xml email=
echo ""

echo "Starting the Jenkins server."
/etc/init.d/jenkins start
#sleep 30

#echo "Now we want to trigger the server to save its configuration before restarting it."

#Now we try making Jinks save its configuration. This appallingly messy line of code comes from
#using Firefox's Live HTTP Headers extension to figure out what happens when you save the
#config. If we don't do this, it seems that Jenkins will never figure out that it needs to use the
#tei-log-parse-rules file to parse build logs, which means that many errors which aren't really
#errors will appear.
#echo "Trying to force Jenkins to save its configuration using curl."
#curl -d "_.rawWorkspaceDir=%24%7BITEM_ROOTDIR%7D%2Fworkspace&_.rawBuildsDir=%24%7BITEM_ROOTDIR%7D%2Fbuilds&system_message=&_.numExecutors=2&_.quietPeriod=5&_.scmCheckoutRetryCount=0&namingStrategy=0&stapler-class=jenkins.model.ProjectNamingStrategy%24DefaultProjectNamingStrategy&stapler-class=jenkins.model.ProjectNamingStrategy%24PatternProjectNamingStrategy&_.namePattern=.*&slaveAgentPort.type=random&stapler-class=hudson.markup.RawHtmlMarkupFormatter&stapler-class=hudson.security.LegacySecurityRealm&stapler-class=hudson.security.HudsonPrivateSecurityRealm&privateRealm.allowsSignup=on&stapler-class=hudson.security.LDAPSecurityRealm&ldap.server=&ldap.rootDN=&ldap.userSearchBase=&ldap.userSearch=&ldap.groupSearchBase=&ldap.managerDN=&ldap.managerPassword=&stapler-class=hudson.security.PAMSecurityRealm&_.serviceName=&authorization=0&stapler-class=hudson.security.AuthorizationStrategy%24Unsecured&stapler-class=hudson.security.LegacyAuthorizationStrategy&stapler-class=hudson.security.FullControlOnceLoggedInAuthorizationStrategy&stapler-class=hudson.security.GlobalMatrixAuthorizationStrategy&stapler-class=hudson.security.ProjectMatrixAuthorizationStrategy&stapler-class=hudson.security.csrf.DefaultCrumbIssuer&name=jobConfigHistory&historyRootDir=&maxHistoryEntries=&excludePattern=queue%7CnodeMonitors%7CUpdateCenter%7Cglobal-build-stats&globalMavenOpts=&stapler-class=hudson.maven.local_repo.DefaultLocalRepositoryLocator&stapler-class=hudson.maven.local_repo.PerExecutorLocalRepositoryLocator&stapler-class=hudson.maven.local_repo.PerJobLocalRepositoryLocator&_.usageStatisticsCollected=on&port.type=random&_.cvsExe=&_.cvspassFile=&svn.workspaceFormat=8&svn.global_excluded_revprop=&svn.storeAuthToDisk=on&shell=&_.url=http%3A%2F%2Flocalhost%3A7070%2F&_.smtpServer=&_.defaultSuffix=&_.adminAddress=address+not+configured+yet+%3Cnobody%40nowhere%3E&_.smtpAuthUserName=&_.smtpAuthPassword=&_.smtpPort=&_.replyToAddress=&_.charset=UTF-8&sendTestMailTo=&log-parser.name=TEI+Log+Parse+Rules&log-parser.path=%2Fvar%2Flib%2Fjenkins%2Ftei-log-parse-rules&log-parser.name=&log-parser.path=&core%3Aapply=&json=%7B%22rawWorkspaceDir%22%3A+%22%24%7BITEM_ROOTDIR%7D%2Fworkspace%22%2C+%22rawBuildsDir%22%3A+%22%24%7BITEM_ROOTDIR%7D%2Fbuilds%22%2C+%22system_message%22%3A+%22%22%2C+%22%22%3A+%22%22%2C+%22jenkins-model-MasterBuildConfiguration%22%3A+%7B%22numExecutors%22%3A+%222%22%7D%2C+%22jenkins-model-GlobalQuietPeriodConfiguration%22%3A+%7B%22quietPeriod%22%3A+%225%22%7D%2C+%22jenkins-model-GlobalSCMRetryCountConfiguration%22%3A+%7B%22scmCheckoutRetryCount%22%3A+%220%22%7D%2C+%22jenkins-model-GlobalProjectNamingStrategyConfiguration%22%3A+%7B%7D%2C+%22hudson-security-GlobalSecurityConfiguration%22%3A+%7B%7D%2C+%22hudson-security-csrf-GlobalCrumbIssuerConfiguration%22%3A+%7B%7D%2C+%22jenkins-model-GlobalNodePropertiesConfiguration%22%3A+%7B%22globalNodeProperties%22%3A+%7B%7D%7D%2C+%22jenkins-model-GlobalPluginConfiguration%22%3A+%7B%22plugin%22%3A+%7B%22name%22%3A+%22jobConfigHistory%22%2C+%22historyRootDir%22%3A+%22%22%2C+%22maxHistoryEntries%22%3A+%22%22%2C+%22saveSystemConfiguration%22%3A+false%2C+%22excludePattern%22%3A+%22queue%7CnodeMonitors%7CUpdateCenter%7Cglobal-build-stats%22%2C+%22skipDuplicateHistory%22%3A+false%7D%7D%2C+%22hudson-maven-MavenModuleSet%22%3A+%7B%22globalMavenOpts%22%3A+%22%22%2C+%22%22%3A+%220%22%2C+%22localRepository%22%3A+%7B%22stapler-class%22%3A+%22hudson.maven.local_repo.DefaultLocalRepositoryLocator%22%7D%7D%2C+%22hudson-model-UsageStatistics%22%3A+%7B%22usageStatisticsCollected%22%3A+%7B%7D%7D%2C+%22org-jenkinsci-main-modules-sshd-SSHD%22%3A+%7B%22port%22%3A+%7B%22value%22%3A+%22%22%2C+%22type%22%3A+%22random%22%7D%7D%2C+%22hudson-scm-CVSSCM%22%3A+%7B%22cvsExe%22%3A+%22%22%2C+%22cvspassFile%22%3A+%22%22%2C+%22cvs_noCompression%22%3A+false%7D%2C+%22hudson-scm-SubversionSCM%22%3A+%7B%22workspaceFormat%22%3A+%228%22%2C+%22global_excluded_revprop%22%3A+%22%22%2C+%22storeAuthToDisk%22%3A+%7B%7D%7D%2C+%22hudson-tasks-Shell%22%3A+%7B%22shell%22%3A+%22%22%7D%2C+%22hudson-tasks-Mailer%22%3A+%7B%22url%22%3A+%22http%3A%2F%2Flocalhost%3A7070%2F%22%2C+%22smtpServer%22%3A+%22%22%2C+%22defaultSuffix%22%3A+%22%22%2C+%22adminAddress%22%3A+%22address+not+configured+yet+%3Cnobody%40nowhere%3E%22%2C+%22useSsl%22%3A+false%2C+%22smtpPort%22%3A+%22%22%2C+%22replyToAddress%22%3A+%22%22%2C+%22charset%22%3A+%22UTF-8%22%7D%2C+%22hudson-plugins-logparser-LogParserPublisher%22%3A+%7B%22rule%22%3A+%5B%7B%22name%22%3A+%22TEI+Log+Parse+Rules%22%2C+%22path%22%3A+%22%2Fvar%2Flib%2Fjenkins%2Ftei-log-parse-rules%22%7D%2C+%7B%22name%22%3A+%22%22%2C+%22path%22%3A+%22%22%7D%5D%7D%2C+%22core%3Aapply%22%3A+%22%22%7D&Submit=Save" http://localhost:$JENKINS_PORT/configSubmit

#echo "Waiting to allow Jenkins server to store configuration before restarting the server."
#sleep 10
#echo "Restarting Jenkins server."
#/etc/init.d/jenkins restart

#NOTE: No need for the lines below because the Priority Sorter plugin should handle it.
#echo "Triggering the Stylesheet job. It needs to be completed before other P5 builds will succeed."
#wget http://localhost:$JENKINS_PORT/job/Stylesheets/build > /dev/null
#echo "Stylesheets build has been triggered."

echo ""
echo "*******************************************"
echo "OK, we should be done. Now you have to:"
echo "Go to the Jenkins interface on
http://[this_computer_ip]:$JENKINS_PORT, and set up
authentication. Read the Jenkins documentation
for help with this."
echo ""
echo "Make sure you do this, because your Jenkins
installation is currently unsecured, and anyone
could make changes to it."
echo ""
echo "If some builds fail initially, it may be simply
due to sequencing and timing. The Stylesheets build
must successfully complete before any of the TEIP5
builds will be able to work."
echo ""
echo "That's it!"
echo "Press return to exit."
echo "*******************************************"
read
exit

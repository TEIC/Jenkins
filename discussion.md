# Discussions and plans

This is where we collaborate to record issues we're looking at 
and answers we've decided on.

## Questions and answers

* Do we want to install Apache to make Jenkins available through port 80?
  Answer: no; that's beyond the remit of a basic server setup.
  
* Which JDK should we settle on, 7 or 8?
  Answer: JDK 8 appears to be the default on Ubuntu 16.04, so 
  go with that unless some incompatibility emerges.
  
* Do we install the TEI packages? The answer to that would appear to be YES, 
  because the Stylesheets Makefile expects Oxygen to be installed in the location
  where it would be installed by those packages:
      oxygendoc:
    	# when building Debian packages, the script runs under
    	# fakeroot, and the oxygen script then tries to look in /root/.com.oxygenxml, and fails.  
    	# The answer is to tweak the stylesheetDocumentation.sh script 
    	@echo text for existence of file $(OXY)/stylesheetDocumentation.sh and make stylesheet documentation if it exists
    	if test -f $(OXY)/stylesheetDocumentation.sh; then perl -pe "s+-Djava.awt+-Duser.home=/tmp/ -Djava.awt+; s+OXYGEN_HOME=.*+OXYGEN_HOME=/usr/share/oxygen+" < $(OXY)/stylesheetDocumentation.sh > ./runDoc.sh; chmod 755 runDoc.sh;  cp -f $(OXY)/licensekey.txt .;  $(MAKE) ${DOCTARGETS} ${PROFILEDOCTARGETS}; rm -f licensekey.txt runDoc.sh; fi
    	DECISION: Council meeting 2016-04-25: try commenting out this task in the Makefile to see what breaks.
    	I'm trying initially with it in place; when things work with it, then we'll start commenting it out.
    	
* Do we really need the TEIP5-Test* and TEIP5-Documentation* jobs, or could we just 
  configure the main job to fail earlier?

## Jenkins job configuration

This is the current config on our main Jenkins server, which MDH reconfigured 
following the release in March:

* Stylesheets-dev -> TEIP5-Test-dev -> TEIP5-Documentation-dev -> TEIP5-dev
  (drawing from the dev branches)
* Stylesheets -> TEIP5-Test -> TEIP5-Documentation -> TEIP5
  (drawing from the master branches)
* Other disabled release branch jobs exist for the last release, but whether 
  those need to be curated in the repo is not yet clear. They can easily be 
  created by cloning the dev jobs and pointing them at the release branch.
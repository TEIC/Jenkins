# Discussions and plans

This is where we collaborate to record issues we're looking at 
and answers we've decided on.

## Questions and answers

* Do we want to install Apache to make Jenkins available through port 80?
  Answer: no; that's beyond the remit of a basic server setup.
* Which JDK should we settle on, 7 or 8?
  Possible answer: JDK 8 appears to be the default on Ubuntu 16.04, so 
  go with that unless some incompatibility emerges.
* Do we install the TEI packages? All our jobs are supposed to be building 
  (as far as I know) with the products of other jobs, so in theory they 
  shouldn't be necessary. I'd like to test this out, and if it's so, then 
  great, we don't need them. But I have a feeling that something in the 
  Makefile uses Oxygen .sh files, and I wonder if they're available through 
  the install of oxygen-tei (meaning the TEI deb version of Oxygen), rather 
  than in the repo somewhere. Anyone know?
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
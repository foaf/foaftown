#!/bin/sh

#svn co http://opensocial-resources.googlecode.com/svn/spec/0.8/opensocial/

java -cp js.jar org.mozilla.javascript.tools.shell.Main -f \
     opensocial/opensocial.js \
     -f opensocial/name.js -f opensocial/person.js -f opensocial/organization.js \
	-f opensocial/address.js -f opensocial/name.js -f opensocial/address.js \
	-f opensocial/activity.js -f opensocial/email.js \
	-f opensocial/mediaitem.js -f opensocial/message.js -f opensocial/phone.js -f opensocial/url.js \
	-f canonicaldb.json \
	-f schemarama.js


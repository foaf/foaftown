Dan introduced me to Strophe, which is a javascript API for XMPP, which 
uses BOSH or similar to interface with an XMPP server (such as eJabberd 
or OpenFire). The upshot of this is that you can control one webpage 
from another using XMPP, using no server-side Web code. This is great 
for quick prototyping, and for demonstrating control of web-based video. 
What's even cooler for demos like these is to use greasemonkey on the 
player side, in which case you can show demonstrations based on real 
video sites, as greasemonkey gives you control over the behaviour and 
appearance of the video site (only on a machine with the script 
installed, but that's fine for demos).

Getting it working

The basic process is this:

* create a domain (because of javascript's access control policy)
* install jabber server
* create two accounts and make them friends
* put an http rewrite file in the right place
* create 'near' and 'far' webpages to represent the remote and player
* create greasemonkey script and iframe for the web based video player

A word of warning: this is fiddly. Things are changing in the APIs in browsers, in particular, cross-domain iframe lookholes are being closed and browsers are using the onmessage system instead, which is fine, as long we you realise what's going on.

* fix domains

By far the easiest way of getting thsi working is to create a new domain, e.g. jabber.yourdomain.com. You'll need to fix the DNS wit your provider and then edit apache virtual hosts file, for example:

@@

and then restart apache

@@

* install jabber server

In Ubuntu this is as strightforwad as 'sudo at-get install ejabberd'. OpenFire is also apparantly easy.

* configure jabber server

pico /etc/ejabberd/ejabberd.cfg (yeah I use pico! got a problem? :-)

edit this:

%% Hostname
{hosts, ["jabber.yourhostname.com"]}.

You need quite a recent version of ejabberd, and then it incldes bosh access.

* create two accounts and make them friends

ejabberdctl register near jabber.yourhostname.com password
ejabberdctl register far jabber.yourhostname.com password
ejabberdctl add-rosteritem far jabber.notu.be near jabber.notu.be near buttons both
ejabberdctl add-rosteritem near jabber.notu.be far jabber.notu.be far buttons both



* put an http rewrite file in the right place

The simplest thing to do is this:

* create a new directory in the right domain, for example

cd @@
mkdir @@example
cd example

* create an htaccess file

pico .htaccess

RewriteEngine On
RewriteBase /var/www/example
RewriteRule http-bind http://localhost:5280/http-bind/ [P]
RewriteRule http-bind/ http://localhost:5280/http-bind/ [P]
RewriteRule http-poll http://localhost:5280/http-poll/ [P]
RewriteRule http-poll/ http://localhost:5280/http-poll/ [P]
RewriteRule admin/ http://localhost:5280/admin/ [P]

This means that the http interface to ejabberd is in the correct domain. If you put your 'near' and 'far' files in this directory or a subdirectory, that should work.


* create 'near' and 'far' webpages to represent the remote and player

You can see examples: near@@ far@@

Basically each has an on_message function and also sends messages. It's all pretty straightforward. IQs are what we should be using and they are a little bit more fiddly, but I've put some examples here: near@@ far@@. You'll need strophe.js in the same directory.

Near sends load and play messages, while far sends nowp (now playing).

At this stage you should be able to see these two pages communicating. Load 'near' into Safari or similar and far into Firefox (3). @@click play, in near and you should see a response in 'far'.

* create greasemonkey script and iframe for the web based video player

The issue is that you want the 'far' strophe page to control a player (e.g. iPlayer) from a different site. For this you can put the player site as an iframe into the 'far' page. 

@@diag@@

iFrames are confusing and greasemonkey with iFrames is even more so. Basically in modern browsers, iFrame-based hacks for communicating between cross-site iFrames are not allowed, so you need to use HTML5's postMessage instead. This is much easier. 

For the iFrame player greasemonkey script to post to the enclosing 'far' page do this:

  unsafeWindow.parent.postMessage(message, "http://jabber.yoursite.com/");

Where message is a string.

The 'far' page checks for messages like this:

 function receiveMessage(event){
   alert(event.data);
 }


The far page can also send messages like this:

     var win = document.getElementById("frameid").contentWindow;
     win.postMessage("pause", "http://playersite.com/");
     
and the greasemonkey script uses receiveMessage as before.

This 'unsafewindow' business is a way to get at the real window of the iframe (to bypass greasemonkey restrictions). Using this you can also call local javascript methods:

unsafeWindow.play();

Using near, far and gmscript, with test.html, on a different server, you should be able to send messages from near that affect test.


References:

http://softwareas.com/cross-domain-communication-with-iframes
http://greasemonkey.mozdev.org/authoring.html#unsafeWindow
http://code.stanziq.com/strophe/strophejs/doc/1.0.1/files/core-js.html
http://www.ejabberd.im/




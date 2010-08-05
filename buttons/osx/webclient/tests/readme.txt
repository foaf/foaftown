Strophe and Greasemonkey 

This week I've been looking at using strophe and greasemonkey to try to 
make an evocative but simple two-screen prototype for web-based on 
demand video. It was a bit fiddly in parts but it's very useful once you 
get it going. Danbri has been building prototypes like these for some 
time, but it's taken me this long to get my own version working because 
you need your own XMPP server working (that's not strictly true, but 
more on that later).

Why?

We are experimenting with using XMPP for communication between devices, 
primarily because we want to look at social APIs for TV - and XMPP 
provides a lot of the infrastructure we need there (such as friends, 
groups, messaging). First we need some basic control of video, so before 
we start putting friends into the mixture we are implementing some of 
the usual remote commands such as play / pause, and also 'nowp' (now 
playing).

We've done this with an XMPP python bot talking to MythTV and an iPhone 
as a controller, but it was slow work to build the iPhone interface, and 
the code isn't usable on other non-Apple devices.

Dan introduced me to Strophe, which is a javascript API for XMPP, which 
uses BOSH or similar to interface with an XMPP server (such as eJabberd 
or OpenFire). The upshot of this is that you can control one webpage 
from another using XMPP, using no server-side Web code. This is great 
for quick prototyping, and for demonstrating control of web-based video. 
What's even cooler for demos like these is to use Greasemonkey on the 
player side, in which case you can show demonstrations based on real 
video sites, as Greasemonkey gives you control over the behaviour and 
appearance of the video site (only on a machine with the script 
installed - see 
http://wiki.greasespot.net/Greasemonkey_Manual:Installing_Scripts - but 
that's fine for demos).

Getting it working

The basic process is this:

* create a domain (because of javascript's access control policy)
* install jabber server
* create two accounts and make them friends
* put an http rewrite file in the right place
* create 'near' and 'far' webpages to represent the remote and player
* create greasemonkey script and iframe for the web based video player

A word of warning: this is fiddly. Things are changing in the APIs in 
browsers, in particular, cross-domain iframe lookholes are being closed 
and browsers are using the postmessage system instead, which is fine, as 
long we you realise what's going on (and can control the iframe content, 
which is why we need Greasemonkey).

* fix domains

By far the easiest way of getting this working is to create a new 
domain, e.g. jabber.yourdomain.com. You'll need to fix the DNS with your 
provider and then edit apache virtual hosts file (for me on ubuntu it's 
/etc/apache2/sites-enabled/000-default), for example:

<VirtualHost *:80>
 ServerName jabber.example.com
 DocumentRoot /var/www/jabber
 <IfModule mod_proxy.c>
   ProxyPreserveHost On
 </IfModule>
   <Directory /var/www/jabber>
     DirectoryIndex index.html
     AllowOverride All
     Order allow,deny
     Allow from all
   </Directory>
</VirtualHost>


and then restart apache

sudo /etc/init.d/apache2 restart

* install jabber server

In Ubuntu this is as strightforwad as 'sudo apt-get install ejabberd'. 
OpenFire is also apparently easy.

* configure jabber server

pico /etc/ejabberd/ejabberd.cfg (yeah I use pico! got a problem? :-)

edit this:

%% Hostname
{hosts, ["jabber.yourhostname.com"]}.

You need quite a recent version of ejabberd (later than 2.0), and then 
it includes bosh.

* create two accounts and make them friends

on the commandline:

ejabberdctl register near jabber.yourhostname.com password
ejabberdctl register far jabber.yourhostname.com password
ejabberdctl add-rosteritem far jabber.notu.be near jabber.notu.be near buttons both
ejabberdctl add-rosteritem near jabber.notu.be far jabber.notu.be far buttons both

* put an http rewrite file in the right place

The simplest thing to do is this:

- create a new directory in the correct domain, for example

cd /var/www
#this can be anything, but it needs to match your apache vhost config above
mkdir jabber 
cd jabber

- create an .htaccess file

pico .htaccess

RewriteEngine On
RewriteBase /var/www/jabber
RewriteRule http-bind http://localhost:5280/http-bind/ [P]
RewriteRule http-bind/ http://localhost:5280/http-bind/ [P]
RewriteRule http-poll http://localhost:5280/http-poll/ [P]
RewriteRule http-poll/ http://localhost:5280/http-poll/ [P]
RewriteRule admin/ http://localhost:5280/admin/ [P]

This means that the http interface to ejabberd is in the correct domain. 
If you put your 'near' and 'far' files in this directory or a 
subdirectory, that should work.

You mght need to enable rewrite and proxy modules in apache

* create 'near' and 'far' webpages to represent the remote and player

You can see examples: near: 
http://svn.foaf-project.org/foaftown/buttons/osx/webclient/tests/near_chat.html 
far: 
http://svn.foaf-project.org/foaftown/buttons/osx/webclient/tests/far_chat.html

Basically each has an on_message function and also sends messages. It's 
all pretty straightforward. IQs are what we should be using and they are 
a little bit more fiddly, but I've put some examples here: near: 
http://svn.foaf-project.org/foaftown/buttons/osx/webclient/tests/near_iq.html 
far: 
http://svn.foaf-project.org/foaftown/buttons/osx/webclient/tests/far_iq.html 
You'll need strophe.js in the same directory.

Near sends load and play messages, while far sends nowp (now playing).

At this stage you should be able to see these two pages communicating. 
Load 'near' into Safari or similar and far into Firefox (3). Click 
play or load in 'near' and you should see a response in 'far'.

* create a Greasemonkey script and iframe for the web based video player

We want the 'far' strophe page to control a player (e.g. iPlayer) from a 
different site. For this you can put the player site as an iframe into 
the 'far' page.

See the diagram strophe-communication.png

iFrames are confusing and Greasemonkey with iFrames is even more so. In 
modern browsers, iFrame-based hacks for communicating between cross-site 
iFrames are not allowed, so you need to use HTML5's postMessage instead. 
This is much easier.

For the iFrame player Greasemonkey script to post to the enclosing 'far' 
page do this:

unsafeWindow.parent.postMessage(message, "http://jabber.yoursite.com/");

Where message is a string.

The 'far' page checks for messages like this:

function receiveMessage(event){
   alert(event.data);
}

The far page can also send messages like this:

     var win = document.getElementById("frameid").contentWindow;
     win.postMessage("pause", "http://playersite.com/");
     
and the Greasemonkey script uses receiveMessage as before.

This 'unsafewindow' business is a way to get at the real window of the 
iframe (to bypass Greasemonkey restrictions). Using this you can also 
call local javascript methods:

  unsafeWindow.play();

Using near, far and test_greasemonkey.user.js, with test.html on a 
different server, you should be able to send messages from near that 
affect test.html.


* CORS (Cross Origin Resource Sharing)

In suported browsers, CORS allows you to make cross-domain ajax calls 
using javascript. This means that you should be able to host ejabberd on 
a different domain to the files taht use it. In general it's easy to 
implement, but I haven't tried it in this application yet.


References:

http://code.stanziq.com/strophe/strophejs/doc/1.0.1/files/core-js.html
http://www.ejabberd.im/
http://xmpp.org/extensions/xep-0206.html
http://anders.conbere.org/blog/2009/09/29/get_xmpp_-_bosh_working_with_ejabberd_firefox_and_strophe/
https://developer.mozilla.org/en/DOM/window.postMessage
http://softwareas.com/cross-domain-communication-with-iframes
http://wiki.greasespot.net/Greasemonkey_Manual:Installing_Scripts
http://greasemonkey.mozdev.org/authoring.html#unsafeWindow
http://www.w3.org/TR/cors/



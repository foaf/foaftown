
WELCOME TO Gumbovi

This is Gumbovi, an experimental implementation of Buttons, an XMPP-based system for 
controlling and interacting with a variety of media-centre and TV-like systems.

STATUS

* Gumbovi status: proof of concept, somewhat messy testbed. Can send XMPP msgs, read QR codes.
* Buttons: unspecified except in code; since there are increasing amounts of code, this is unsustainable

OVERVIEW

Your iPhone (or iPod touch, iPad etc.) logs into an XMPP account on your behalf. You get a remote-control based
UI, plus the ability to pick which other party your button-presses are sent to. You get a basic buddylist, initially
hardcoded to three accounts on public XMPP servers. 

On a device with a camera (ie. iPhone, but not iPod or iPhone simulator) Gumbovi can read QR Codes (2d barcodes) 
to discover XMPP address of new media centres.

Major TODOs:
 * XMPP mDns local link comms (discovery, messaging)
 * Roster-events and service discovery: buddy list should show media-capable accounts
 * as much of NoTube demo scripts as humanly possible
 

LICENSE

 http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231

  
 
DEPENDENCIES
 
 Icons - will probably use  http://twitter.com/glyphish/ so need to credit there (and list the app?)
 
* QR code reader: http://github.com/jverkoey/liteqr/tree/master/qrlib/ 
  Apache license: http://github.com/jverkoey/liteqr/blob/master/LICENSE
  
* XMPP: http://code.google.com/p/xmppframework/wiki/iPhone (New BSD License) 
   which in turn uses http://code.google.com/p/xmppframework/wiki/ThirdPartyCode
   AsyncSocket (by Dustin Voss, public domain); libidn (GNU LesserGPL).
   
   
   BONJOUR
   
   Swap MainWindow.xib to Bonjour.xib in main mplist, and we get the xmmpframework's basic xmpp xep-0174 ui. 
   
   It can talk with Apple iChat amongst other things. It crashes sometimes. seee below with Ahoy tests...
   
   Logs:
   
   run
Running…
[Switching to thread 11779]
[Switching to thread 11779]
(gdb) continue
2010-03-04 20:38:25.897 Gumbovi1[2542:207] netServiceDidPublish
2010-03-04 20:38:26.025 Gumbovi1[2542:207] netServiceBrowser:didFindService: <NSNetService 0x1240b0> local. _presence._tcp. robbie@demo
2010-03-04 20:39:03.844 Gumbovi1[2542:207] netServiceBrowser:didFindService: <NSNetService 0x1240b0> local. _presence._tcp. danbri@TellyClub
2010-03-04 20:39:03.959 Gumbovi1[2542:207] controllerWillChangeContent
2010-03-04 20:39:03.971 Gumbovi1[2542:207] NSFetchedResultsChangeInsert[Section]
2010-03-04 20:39:03.995 Gumbovi1[2542:207] NSFetchedResultsChangeInsert[Object]
2010-03-04 20:39:04.004 Gumbovi1[2542:207] controllerDidChangeContent
2010-03-04 20:39:04.423 Gumbovi1[2542:207] dict: {
    1st = Dan;
    email = "bandri@danbri.org";
    ext = 5I;
    last = Brickley;
    phsh = fd875ec4344b1c38bb53557a7cc17e7fb5960e92;
    "port.p2pj" = 52309;
    status = avail;
    txtvers = 1;
    vc = "SDCURAV!XN";
}
2010-03-04 20:39:04.447 Gumbovi1[2542:207] controllerWillChangeContent
2010-03-04 20:39:04.460 Gumbovi1[2542:207] NSFetchedResultsChangeInsert[Section]
2010-03-04 20:39:04.480 Gumbovi1[2542:207] NSFetchedResultsChangeDelete[Section]
2010-03-04 20:39:04.493 Gumbovi1[2542:207] NSFetchedResultsChangeUpdate[Object]
2010-03-04 20:39:04.511 Gumbovi1[2542:207] didDeleteSection && didInsertSection
2010-03-04 20:39:04.524 Gumbovi1[2542:207] controllerDidChangeContent
2010-03-04 20:39:04.695 Gumbovi1[2542:207] ns(danbri@TellyClub._presence._tcp.local.) -> 192.168.1.10
2010-03-04 20:39:04.708 Gumbovi1[2542:207] controllerWillChangeContent
2010-03-04 20:39:04.729 Gumbovi1[2542:207] NSFetchedResultsChangeUpdate[Object]
2010-03-04 20:39:04.745 Gumbovi1[2542:207] controllerDidChangeContent
2010-03-04 20:39:17.088 Gumbovi1[2542:207] Accepting connection from service: danbri@TellyClub._presence._tcp.local.
2010-03-04 20:39:17.103 Gumbovi1[2542:207] SEND: <?xml version='1.0'?>
2010-03-04 20:39:17.116 Gumbovi1[2542:207] SEND: <stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' from='demo@iphone'>
2010-03-04 20:39:17.153 Gumbovi1[2542:207] RECV: <?xml version="1.0" encoding="UTF-8" ?>
<stream:stream xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/streams">
2010-03-04 20:39:17.165 Gumbovi1[2542:207] StreamController: xmppStream:willSendP2PFeatures:
2010-03-04 20:39:17.177 Gumbovi1[2542:207] SEND: <stream:features/>
2010-03-04 20:39:17.189 Gumbovi1[2542:207] StreamController: xmppStreamDidOpen:
2010-03-04 20:39:17.218 Gumbovi1[2542:207] RECV: <message to="robbie@demo" type="chat">
<body>test from iChat</body>
<html xmlns="http://www.w3.org/1999/xhtml"><body ichatballooncolor="#F4DE1F" ichattextcolor="#000000"><font face="Helvetica" size="3" ABSZ="12">test from iChat</font></body></html><x xmlns="jabber:x:event">
<composing/>
</x>
</message>
2010-03-04 20:39:17.226 Gumbovi1[2542:207] StreamController: xmppStream:didReceiveMessage:
2010-03-04 20:39:17.271 Gumbovi1[2542:207] controllerWillChangeContent
2010-03-04 20:39:17.282 Gumbovi1[2542:207] NSFetchedResultsChangeUpdate[Object]
2010-03-04 20:39:17.293 Gumbovi1[2542:207] controllerDidChangeContent
2010-03-04 20:39:20.332 Gumbovi1[2542:207] RECV: </stream:stream>
2010-03-04 20:39:20.358 Gumbovi1[2542:207] StreamController: xmppStreamDidClose:



Crashes when Ahoy comes online (http://github.com/matsadler/ahoy),


2010-03-04 20:41:28.029 Gumbovi1[2542:207] netServiceBrowser:didFindService: <NSNetService 0x15b360> local. _presence._tcp. fredbutton@nowhere
2010-03-04 20:41:28.038 Gumbovi1[2542:207] controllerWillChangeContent
2010-03-04 20:41:28.044 Gumbovi1[2542:207] NSFetchedResultsChangeInsert[Section]
2010-03-04 20:41:28.050 Gumbovi1[2542:207] NSFetchedResultsChangeInsert[Object]
2010-03-04 20:41:28.056 Gumbovi1[2542:207] controllerDidChangeContent
2010-03-04 20:41:28.185 Gumbovi1[2542:207] *** -[NSNull bytes]: unrecognized selector sent to instance 0x38389934
2010-03-04 20:41:28.202 Gumbovi1[2542:207] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[NSNull bytes]: unrecognized selector sent to instance 0x38389934'
2010-03-04 20:41:28.219 Gumbovi1[2542:207] Stack: (
    843263261,
    825818644,

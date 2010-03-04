
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
 
 
 

This directory contains some OSX utilities for the FOAF Buttons experiment.

1. Apple Remote adaptor


This comes in two parts.

1a. iremoted_buttons 
... an intel OSX binary, built from iremoted_buttons.c
this can be run on commandline, and reports OSX infra red messages from the Apple Remote.

	See blog post: http://danbri.org/words/2009/10/18/478
	Sample output: http://wiki.foaf-project.org/w/DanBri/AppleRemoteButtonTest1

1b. appleremote_buttons_wrapper.rb

This is a ruby script, which runs and monitors iremoted_buttons, converting
into Ruby API calls and a simple OO model for the UI events. 

Sample output:

Cornercase:osx danbri$ ./appleremote_buttons_wrapper.rb 
starting event loop.

EVENT: PLUS code: 0x1d event type: DOWN
EVENT: PLUS code: 0x1d event type: UP
EVENT: MINU code: 0x1e event type: DOWN
EVENT: MINU code: 0x1e event type: UP
EVENT: LEFT code: 0x17 event type: DOWN
EVENT: LEFT code: 0x17 event type: UP
EVENT: RIGH code: 0x16 event type: DOWN
EVENT: RIGH code: 0x16 event type: UP
EVENT: PLPZ code: 0x15 event type: DOWN
EVENT: PLPZ code: 0x15 event type: UP
EVENT: MENU code: 0x14 event type: DOWN
EVENT: MENU code: 0x14 event type: UP



2. iTunes

 - to upload


3. buttons_tilt.pl

experiment at using the tilt sensor (which can also detect screen knocks) as ui input.
 - we might use this to allow a full screen galllery / epg to have "left' and 'right' be taps on side of monitor.

4. jabutton.rb

switchboard ruby/xmpp script

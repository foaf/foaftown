#!/usr/bin/env python

# to use:
#     NOTUBEPASS=xxxpasswdhere ./alice.py
#
#... or set the NOTUBEPASS as an environment variable

# This sample script shows a py utility connecting to a jabber/xmpp account
# If it gets a text message, it will toggle the player of a boxee instance running locally
# It exposes no information back to other xmpp parties currently. Eventually we could expose a 
# remote control interface via xmpp.

import os
import sys 
from xmpp import *


try:
  secret=os.environ["NOTUBEPASS"]
except(Exception):
    print "No password found"
    sys.exit(1)  

def toggleBoxeePlayer():
    boxee_toggle = "http://localhost:8800/xbmcCmds/xbmcHttp?command=Pause()"
    import urllib2
    usock = urllib2.urlopen(boxee_toggle)
    data = usock.read()
    usock.close()
    print "calling pause api "
    print boxee_toggle
    print "Result of fetching url is ...."
    print data

def presenceHandler(conn,presence_node):
    """ Handler for playing a sound when particular contact became online """
    targetJID='bob.notube@gmail.com'
    if presence_node.getFrom().bareMatch(targetJID):
        pass
def iqHandler(conn,iq_node):
    """ Handler for processing some "get" query from custom namespace"""
    print "Got an IQ query:"
    print iq_node
    pass
    reply=iq_node.buildReply('result')
    conn.send(reply) # ... put some content into reply node
    raise NodeProcessed  # This stanza is fully processed
def messageHandler(conn,mess_node): 
    print "In message handler with message: "
    print mess_node
    pass
    print "toggling local boxee player (if we have one!)"
    toggleBoxeePlayer()    

cl = Client(server='gmail.com', debug=[]) 
conn = cl.connect(server=('talk.google.com', 5222)) 
if not conn: 
  print "Unable to connect to server." 
  sys.exit(1) 

print "Connected: %s" % conn 
auth = cl.auth(user='alice.notube', password=secret, resource='gmail.com') 
if not auth: 
  print "Unable to authorize - check login/password." 
  sys.exit(1) 
print "Auth: %s" % auth 
print cl 
cl.RegisterHandler('presence',presenceHandler)
cl.RegisterHandler('iq',iqHandler)
cl.RegisterHandler('message',messageHandler)
cl.sendInitPresence()
cl.Process(1)
if not cl.isConnected(): cl.reconnectAndReauth()		# ...if connection is brocken - restore it
cl.send(Message('bob.notube@gmail.com','Test message from Alice notube script!')) # ...send an ASCII message
while 1:
  cl.Process(1)

cl.disconnect()		# ...and then disconnect.


#!/usr/bin/env python

# Usage:
# NOTUBEPASS=thepasswordgoeshere ./bob.py

# Sample python script
# In this story, bob or bob's device (phone, remote control, laptop, etc) is sending an xmpp message to alice.
# Initially we have configured alice to simply toggle any local Boxee media player if a message is received.
# TODO: a real API

import os
import sys 
from xmpp import *


try:
  secret=os.environ["NOTUBEPASS"]
except(Exception):
    print "No password found"
    sys.exit(1)  

import sys 
from xmpp import *

# TODO: password handling!

def presenceHandler(conn,presence_node):
    """ Handler for playing a sound when particular contact became online """
    targetJID='node@domain.org'
    if presence_node.getFrom().bareMatch(targetJID):
        # play a sound
        pass
def iqHandler(conn,iq_node):
    """ Handler for processing some "get" query from custom namespace"""
    reply=iq_node.buildReply('result')
    # ... put some content into reply node
    conn.send(reply)
    raise NodeProcessed  # This stanza is fully processed
def messageHandler(conn,mess_node): 
    print "In message handler with message "
    print mess_node
    pass




cl = Client(server='gmail.com', debug=[]) 
conn = cl.connect(server=('talk.google.com', 5222)) 
if not conn: 
  print "Unable to connect to server." 
  sys.exit(1) 

print "Connected: %s" % conn 
auth = cl.auth(user='bob.notube', password=secret, resource='gmail.com') 
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
cl.send(Message('alice.notube@gmail.com','Test message from Bob notube script!')) # ...send an ASCII message
cl.Process(1) 				# ...work some more time - collect replies

while 1:
  cl.Process(1)

cl.disconnect()		# ...and then disconnect.


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
import re
from xmpp import *

try:
  secret=os.environ["NOTUBEPASS"]
except(Exception):
    print "No password found"
    sys.exit(1)  

# Plex is as xbmc but on 3000, see Prefs > Network for settings

def toggleBoxeePlayer():
    boxee_toggle = "http://localhost:8800/xbmcCmds/xbmcHttp?command=Pause()" # plex
#    boxee_toggle = "http://localhost:3000/xbmcCmds/xbmcHttp?command=Pause()" # boxee
    import urllib2
    usock = urllib2.urlopen(boxee_toggle)
    data = usock.read()
    usock.close()
    print "calling pause api "
    print boxee_toggle
    print "Result of fetching url is ...."
    print data
    notify("Buttons: Pause toggled")


# 32400 port for 

def boxee_GetCurrentlyPlaying():
    boxee_toggle = "http://localhost:8800/xbmcCmds/xbmcHttp?command=GetCurrentlyPlaying()"
#    boxee_toggle = "http://localhost:3000/xbmcCmds/xbmcHttp?command=GetCurrentlyPlaying()"
    import urllib2
    usock = urllib2.urlopen(boxee_toggle)
    data = usock.read()
    usock.close()
    print "calling GetCurrentlyPlaying api "
    print boxee_toggle
    print "Result of fetching url is ...."
    p = re.compile(":([^@]*)@")
    data = p.sub(':xxxxx@',data)
    print data
    return(data)

def notify(str):
   # danbri@zojandan:~/working/mumbles/mumbles0.4-branch/src$ ./mumbles-send "Buttons - Pause toggle"
    mumbles = "working/mumbles/mumbles0.4-branch/src/mumbles-send"
#   os.system( os.getenv("HOME") + '/' +  mumbles + ' \"' + str +  '\"' )


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
#    reply=mess_node.buildReply('toggled!')

    txt = boxee_GetCurrentlyPlaying()
    conn.send(Message(mess_node.getFrom(),txt, "chat" ))
    print "!!! replied to " + str( mess_node.getFrom() )
    # conn.send(reply) 


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
cl.send(Message('buttons@foaf.tv', 'Hello Buttons! --alice mediacentre', "chat")) # ...send an ASCII message
while 1:
  cl.Process(1)

cl.disconnect()		# ...and then disconnect.


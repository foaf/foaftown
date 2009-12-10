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
import urllib2
import urllib, simplejson
from xmpp import *
from datetime import datetime

server = "http://localhost:8800/xbmcCmds/xbmcHttp"

try:
  secret=os.environ["NOTUBEPASS"]
except(Exception):
    print "No password found"
    sys.exit(1)  

# Plex is as xbmc but on 3000, see Prefs > Network for settings

def imdbFromTitle(str):
  title = "The Fog of War: Eleven Lessons from the Life of Robert S. McNamara" 
  title = "Bitka na Neretvi"
  result = simplejson.load(urllib.urlopen("http://ajax.googleapis.com/ajax/services/search/web?%s" % urllib.urlencode({'v': "1.0", 'q': title + " site:imdb.com" })))
  return result['responseData']['results'][0]['url']


def toggleBoxeePlayer():
    boxee_toggle = "http://localhost:8800/xbmcCmds/xbmcHttp?command=Pause()" # plex
#    boxee_toggle = "http://localhost:3000/xbmcCmds/xbmcHttp?command=Pause()" # boxee
    print "Calling toggle url: "+boxee_toggle
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
#   3000 for plex default
    usock = urllib2.urlopen(boxee_toggle)
    data = usock.read()
    usock.close()
    print "calling GetCurrentlyPlaying api "
    print boxee_toggle
#    print "Result of fetching url is ...."
    p = re.compile(":([^@]*)@")
    data = p.sub(':xxxxx@',data)
#    print data
    return(data)

def notify(str):
   # danbri@zojandan:~/working/mumbles/mumbles0.4-branch/src$ ./mumbles-send "Buttons - Pause toggle"
   mumbles = "working/mumbles/mumbles0.4-branch/src/mumbles-send"
   #   os.system( os.getenv("HOME") + '/' +  mumbles + ' \"' + str +  '\"' )


# http://www.xbmc.org/trac/browser/branches/linuxport/XBMC/guilib/Key.h?rev=17732
# http://xbmc.org/wiki/?title=WebServerHTTP-API
# http://xbox/xbmcCmds/xbmcHttp?command=Action(4)
# define ACTION_PLAYER_FORWARD        77  // FF in current file played. global action, can be used anywhere
def got_righ():
    url = server +"?command=Action(77)"
    usock = urllib2.urlopen(url)
    data = usock.read()
    usock.close()
    print "Gone FF"

def got_plus():
  return

def got_minu():
  return 

def runCmd(command):
    child = os.popen(command)
    data = child.read()
    err = child.close()
    if err:
        raise RuntimeError, '%s failed w/ exit code %d' % (command, err)
    return data


def getImdb(fn):
  r = runCmd("echo 'select * from video_files where strPath=\"" + fn + "\";' | sqlite3 ~/Library/Application\ Support/BOXEE/UserData/Database/boxee_media.db")
  arr = r.split("|")
  return arr[12]

def got_like():
  st =  boxee_GetCurrentlyPlaying()
  # f       = 'smb://BLACKBOOK/south/Found/FoundFilm/Dark City/dark_city.avi'
  # Filename:smb://BLACKBOOK/south/Found/FoundFilm/Dark City/dark_city.avi 
  regexp = re.compile( "<li>Filename:(.*)\n" )
  rez = regexp.search(st)
  if rez == None:
    print "Couldn't find current status."
  else:
    fn = rez.group(1)
    print "GOT fn: " + fn
    imdb = 'http://www.imdb.com/title/'+getImdb(fn)
    print "LIKED IMDB: " + imdb
    # report this to DB:
    userid='fakeuser'
    regexp = re.compile( "<li>Title:(.*)\n" )
    rez = regexp.search(st)
    title = rez.group(1)
    dt = datetime.now().ctime() 
    url = imdb
    comments="liked"
    u  = "http://services.notube.tv/notube/zapper/boxeelog.php%s" % urllib.urlencode({'action': "insert", 'username': userid, 'title': title, 'when': dt, 'url': url, 'comments': comments })
    print "Using URL for NoTube Network activity log: "+u
    urllib2.urlopen(u)
    # Hey, we should also store the offset in time, and make a screenshot, store that too? :)

def got_menu():
  return 

def got_left():
    url = server +"?command=Action(78)"
    usock = urllib2.urlopen(url)
    data = usock.read()
    usock.close()
    print "Gone RW"

def presenceHandler(conn,presence_node):
    """ Handler for playing a sound when particular contact became online """
    targetJID='alice.notube@gmail.com'
    if presence_node.getFrom().bareMatch(targetJID):
        pass

def iqHandler(conn,iq_node):
    """ Handler for processing some "get" query from custom namespace"""
    print "Got an IQ query:"
    print iq_node
#3      pass
#    reply=iq_node.buildReply('result')
#    conn.send(reply) # ... put some content into reply node
    raise NodeProcessed  # This stanza is fully processed

def messageHandler(conn,mess_node): 
    value = str(mess_node.getBody())
    value = value.replace(" event.","")
    print "GOT msg: "+value
    if value == 'PLPZ':
      toggleBoxeePlayer()
    elif value == 'LEFT':
      got_left()
    elif value == 'RIGH':
      got_righ() 
    elif value == 'PLUS':
      got_plus() 
    elif value == 'MINU':
      got_minu() 
    elif value == 'LIKE':
      got_like() 
    elif value == 'MENU':
      got_menu() 
  
#    toggleBoxeePlayer()    
#    reply=mess_node.buildReply('toggled!')
    txt = boxee_GetCurrentlyPlaying()
    conn.send(Message(mess_node.getFrom(),txt, "chat" ))
    print "!!! replied to " + str( mess_node.getFrom() )

#cl = Client(server='foaf.tv', debug=[]) 
#conn = cl.connect(server=('foaf.tv', 5222)) 

# google:
cl = Client(server='gmail.com', debug=[]) 
conn = cl.connect(server=('talk.google.com', 5222)) 


if not conn: 
  print "Unable to connect to server." 
  sys.exit(1) 

print "Connected: %s" % conn 
#auth = cl.auth(user='buttons', password=secret, resource='foo') 

# use gmail account:
auth = cl.auth(user='bob.notube', password=secret, resource='foo') 

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
#cl.send(Message('alice.notube@gmail.com', 'Hello Alice! -- buttons', "chat")) # ...send an ASCII message
while 1:
  cl.Process(1)

cl.disconnect()		# ...and then disconnect.


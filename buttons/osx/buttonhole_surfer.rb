#!/usr/bin/env ruby -rubygems

require 'switchboard'
require 'xmpp4r/client'
include Jabber

# this variant includes a connection to XMPP via switchboard library, but doesn't yet send anything

# This script works with the Apple Remote IR controller, monitoring 
# a commandline C program for output, and relaying that to the wider 'net via XMPP.
# Well, I've not done the XMPP bit yet. 
# 
#  This is a contribution to the FOAF Buttons project, and was initiated as part of the NoTube EU project, www.notube.tv
# 
# Dan Brickley <danbri@danbri.org>
#
# 
#
#  External program to monitor:

IR="./iremoted_buttons" 	# you can compile this with gcc -Wall -o iremoted_buttons iremoted_buttons.c -framework IOKit -framework Carbon

# Local (non-standard) nicknames for the 6 USB codes:
APIR= { '0x1d' 		=> 'PLUS', 	# up 	(immediate events)
        '0x1e'	 	=> 'MINU', 	# down  (immediate events)
       	'0x17' 		=> 'LEFT', 	# left  (buffered events, all other buttons)
	'0x16'		=> 'RIGH', 	# right
	'0x15'		=> 'PLPZ', 	# fire (play/pause)
	'0x14'		=> 'MENU' } 	# menu


class ButtonEvent
  attr_accessor :name, :event
  def initialize(name = "NOPE")
    @name = name
  end
  def label
    return APIR[@name] # optimistic, should error check!
  end
end

class ButtonDownEvent < ButtonEvent
  def initialize(i)
    @event='DOWN'
    super(i)
  end
end

class ButtonUpEvent < ButtonEvent
  def initialize(i)
    @event='UP'
    super(i)
  end
end

def eventLoop(sb=nil)
  f = IO.popen( IR + " 2>&1 ","r") do |pipe|
    pipe.each do |line|
      sleep 0.1
      relay(line, sb)
    end
  end
end

def relay(line,sb)
  line.gsub!(/\s*/,"")
  if line.equal?("")
    puts "NOTHING"
    return
  end

  if line =~ /<pressed>([^<]+)<\/pressed>/
    ev = ButtonDownEvent.new($1) 
    bubbleEvent(ev,sb)

  elsif line =~ /<depressed>([^<]+)<\/depressed>/
    ev = ButtonUpEvent.new($1) 
    bubbleEvent(ev,sb)
  elsif
    puts "UNKNOWN; ignoring" 
  end
end

  # Switchboard is essentially a wrapper around xmpp4r, so `switchboard.client` will give you access to a `Jabber::Client`
  # object.  Docs for that are here: http://home.gna.org/xmpp4r/rdoc/  http://home.gna.org/xmpp4r/rdoc/classes/Jabber/Client.html
  # http://devblog.famundo.com/articles/2006/10/14/ruby-and-xmpp-jabber-part-2-logging-in-and-sending-simple-messages

def bubbleEvent(e,sb)
  msg = "Button #{e.event} event: #{e.label} (#{e.name})"
  puts msg
  to = "alice.notube@gmail.com"
  subject = "Apple Remote Event"
  begin 
    m = Message::new(to, msg).set_type(:normal).set_id('1').set_subject(subject)
    sb.client.send(m)
  rescue Exception => e
    puts "Rescued: #{e}"
  end
end



# Main:

switchboard = Switchboard::Client.new
switchboard.plug!(AutoAcceptJack, NotifyJack)

t1 = Thread.new {

begin
    switchboard.on_message do |message|
      txt = message.body.to_s
      puts "Message body was: '#{txt}'"
      if (txt =~ /pause/)
        puts "replied with pause toggle."
        stream.send("toggled pause")
      else
        stream.send(message.answer)
      end
    end
    switchboard.on_iq do |message|
      p "Got message iq: "
      p message
    end
    switchboard.run!
  rescue Exception => e
    put "Exception: #{e} in our Switchboard thread"
  end
} 

print "starting event loop.\n\n"

eventLoop(switchboard) # loop around, listening to IR events and eventually relaying them to XMPP listeners


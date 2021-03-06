#!/usr/bin/env ruby

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
#
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



def eventLoop
  f = IO.popen( IR + " 2>&1 ","r") do |pipe|
    pipe.each do |line|
      sleep 0.1
      relay(line)
    end
  end
end

def relay(line)
  line.gsub!(/\s*/,"")
  if line.equal?("")
    puts "NOTHING"
    return
  end

  if line =~ /<pressed>([^<]+)<\/pressed>/
    ev = ButtonDownEvent.new($1) 
    bubbleEvent(ev)

  elsif line =~ /<depressed>([^<]+)<\/depressed>/
    ev = ButtonUpEvent.new($1) 
    bubbleEvent(ev)
  elsif
    puts "UNKNOWN; ignoring" 
  end
end

def bubbleEvent(e)
  puts "EVENT: #{e.label} code: #{e.name} event type: #{e.event}"
  
  # TODO: we need to have a connection to XMPP network, and send events out to remote listeners, ...

end

print "starting event loop.\n\n"

eventLoop() # loop around, listening to IR events and eventually relaying them to XMPP listeners


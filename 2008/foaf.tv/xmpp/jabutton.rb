#!/usr/bin/env ruby -rubygems
require 'appscript'
include Appscript
require 'xmpp4r'
include Jabber
# config: put the following 3 lines (no '#' marks and a real password!) into ~/.switchboardrc

require 'switchboard'
switchboard = Switchboard::Client.new
#switchboard.plug!(AutoAcceptJack, NotifyJack)
switchboard.plug!(AutoAcceptJack)

switchboard.on_message do |message|
  txt = message.body.to_s
  puts "Message body was: '#{txt}'"
  begin
    itunes = app('iTunes.app')
    track = itunes.current_track
    p track                     # <OSA::Itunes::FileTrack:0x1495e20>
    p track.name                # "Over The Rainbow"
    p track.artist              # "Keith Jarrett"
    p track.duration            # 362.368988037109
    p track.date_added.to_s     # "2006-06-30"
    to = "buttons@foaf.tv"
    subject = "iTunes status update"
    body = "Currently playing #{ track.name } by #{ track.artist }, duration: #{  track.duration } "
    if txt =~ /RIGH/ 
      puts "Skip to next right."
    end
    if txt =~ /LEFT/ 
      puts "Skip to next left."
    end

    if txt =~ /PLPZ/ 
      state = itunes.player_state.get.to_s
      if state =~ /playing/
        itunes.pause
        puts "Paused."
      else 
        itunes.play
        puts "Play."
      end
    end

  rescue => e
    puts "Ooopsie with iTunes link: #{e}"
  end
  if (txt =~ /pause/)
    puts "replied with pause toggle."
    stream.send("toggled pause")
  else
   #  stream.send(message.answer)
  end
end

# xmpp4r Jabber:Iq instances arriving:
#
switchboard.on_iq do |message|
  p "Got message iq: "
			# Jabber::IqQuery < Jabber::XMPPElement < REXML::Element
  if (message.query.namespace=='http://buttons.foaf.tv/') 
    puts "Got a buttons message!"
    b = message.query.first_element('button').text.to_s
    if (b == 'PLPZ')
      puts "Got PLPZ: Playing and/or pausing or vice-versa."

    end
    
  end
  
end

switchboard.run!

#todo - send presence?
# http://stdlib.rubyonrails.org/libdoc/rexml/rdoc/index.html


# migrating from xmpp api
#    m = Message::new(to, body).set_type(:normal).set_id('1').set_subject(subject)
#    cl.send m

#source = "<a xmlns:x='foo' xmlns:y='bar'><x:b id='1'/><y:b id='2'/></a>"
#doc = Document.new source
#doc.elements["/a/x:b"].attributes["id"]	                     # -> '1'
#XPath.first(doc, "/a/m:b", {"m"=>"bar"}).attributes["id"]   # -> '2'
#doc.elements["//x:b"].prefix                                # -> 'x'
#doc.elements["//x:b"].namespace	                             # -> 'foo'
#XPath.first(doc, "//m:b", {"m"=>"bar"}).prefix  

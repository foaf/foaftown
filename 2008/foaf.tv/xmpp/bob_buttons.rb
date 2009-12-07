#!/usr/bin/env ruby
# http://rubyosa.rubyforge.org/  http://snippets.dzone.com/posts/show/5149
require 'rbosa'               
require 'rubygems'
require 'xmpp4r'
include Jabber

begin
  jid = JID::new('bob.notube@gmail.com/itunes')
  password = 'gargonza' 
  cl = Client::new(jid)
  cl.connect
  cl.auth(password)
rescue
  p "Something went wrong with XMPP setup"
end

begin 
  itunes = OSA.app('iTunes')      
  track = itunes.current_track
  p track                     # <OSA::Itunes::FileTrack:0x1495e20>
  p track.name                # "Over The Rainbow" 
  p track.artist              # "Keith Jarrett" 
  p track.duration            # 362.368988037109 
  p track.date_added.to_s     # "2006-06-30" 
  p track.enabled?            # true
  to = "buttons@foaf.tv"
  subject = "iTunes status update"
  body = "Currently playing #{ track.name } by #{ track.artist }, duration: #{  track.duration } "
  m = Message::new(to, body).set_type(:normal).set_id('1').set_subject(subject)
  cl.send m
rescue => e
  puts "Ooopsie with iTunes link: #{e}"
end

switchboard.run!


#!/usr/bin/env ruby -rubygems

# Basic XMPP connectivity
# danbri@danbri.org

# config: put the following 3 lines (no '#' marks and a real password!) into ~/.switchboardrc
# --- 
# jid: buttons@foaf.tv
# password: xxxxxxx


require 'switchboard'

switchboard = Switchboard::Client.new
switchboard.plug!(AutoAcceptJack, NotifyJack)

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

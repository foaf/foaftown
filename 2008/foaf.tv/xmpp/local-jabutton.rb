
#!/usr/bin/ruby

require 'rubygems'

def localLink
  require 'ahoy'
  puts "localLink at: #{Time.now}"
  user = Ahoy::User.new("danbri")
  user.interface = "en1"
  user.sign_in
  sleep 1
  if user.contacts != nil
    chat = user.chat(user.contacts.first)
    chat.on_reply do |reply|
      puts reply, " at #{Time.now}"
    end
  end
  chat.send("hello from ruby")
end

def Lurk
  loop do
    sleep 1
  end
end


def serverLink 
  require 'xmpp4r-simple'
  puts "serverLink at: #{Time.now}"
  myBareJid = 'bob.notube@gmail.com'
  myBareBuddy = 'alice.notube@gmail.com'
  im = Jabber::Simple.new(myBareJid,ENV['BUTTONS_TEST'])
  im.deliver(myBareBuddy, "Hey there friend!")
  im.received_messages { |msg| puts "serverLink: ", msg.body if msg.type == :chat }
end

puts "Start at: #{Time.now}"


local = Thread.new{localLink()}.join
remote = Thread.new{serverLink()}.join

lurk = Thread.new{Lurk()}.join

puts "End at: #{Time.now}"

# behaviour:
# with remote commented out, local can talk to bonjour ichat locally.
# with local commented out, remote (via gmail ui) shows message arrive, but responses aren't shown by this script
# with both active, local errors:
#   /Library/Ruby/Gems/1.8/gems/ahoy-0.0.2/lib/ahoy/xmpp4r_hack.rb:13:in `initialize': Connection refused - connect(2) (Errno::ECONNREFUSED)
#  from local-jabutton.rb:42:in `join'
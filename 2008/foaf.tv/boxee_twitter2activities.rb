#!/usr/bin/env ruby -rubygems

# Extract a basic activity stream from Boxee's Twitter output
# Dan Brickley <danbri@danbri.org>
#  
# Written as part of the NoTube project - http://www.notube.tv/
# Opensource, do what you like but don't blame me.
# 
# Sample output:
# User: bandriball		verb: likes		title:  DocArchive: John Simpson Returns to 1989		uri: http://bit.ly/1fqbmD
# User: bandriball		verb: likes		title:  October 15, 2009 - Guest: Jennifer Burns		uri: http://bit.ly/3nCXKK
# User: bandriball		verb: likes		title:  36 Crazy Fists		uri: http://bit.ly/supxQ
# User: bandriball		verb: likes		title:  Carl Sagan - 'A Glorious Dawn'  ft Stephen Hawking (Cosmos Remixed)		uri: http://bit.ly/uaJeZ
# User: bandriball		verb: recommended		title:  DigitalP: 19 Oct 09		uri: http://bit.ly/nTpY5
# User: bandriball		verb: likes		title:  DigitalP: 19 Oct 09		uri: http://bit.ly/nTpY5
# User: bandriball		verb: likes		title:  DocArchive: Iran and the West - part three		uri: http://bit.ly/4Cl9UA
# User: bandriball		verb: recommended		title:  Le mystère Picasso		uri: http://bit.ly/19vN4g
# User: bandriball		verb: listening to		title:  Frédéric Chopin on lastfm		uri: http://bit.ly/1oojaX
# User: bandriball		verb: likes		title:  Le mystère Picasso		uri: http://bit.ly/19vN4g
# User: bandriball		verb: watching		title:  Le mystère Picasso		uri: http://bit.ly/19vN4g
# User: bandriball		verb: watching		title:  Hyperland		uri: http://bit.ly/3Gp4Z2
# User: bandriball		verb: likes		title:  Hyperland		uri: http://bit.ly/3Gp4Z2


require 'rss'
require 'open-uri'
rss_feed = "http://twitter.com/statuses/user_timeline/85093859.rss" # bandriball

def deBitly(id = 'NIL')
  return id # todo: http deref
end

# GOT: bandriball: watching Hyperland on Boxee. check it out at http://bit.ly/3Gp4Z2
def parseBoxee(str) 
  # puts "GOT: #{str}"
  str =~ /([^:]+):\s*(likes|recommended|listening to|watching)(.*) on Boxee\. .* at (.*)/
  user,verb,title,uri = $1, $2, $3, $4
  uri = deBitly(uri)
  puts "User: #{user}\t\tverb: #{verb}\t\ttitle: #{title}\t\turi: #{uri}\n"
end



rss_content = ""
open(rss_feed) do |f|
   rss_content = f.read
end
rss = RSS::Parser.parse(rss_content, false)

puts "Title: #{rss.channel.title}"
puts "RSS URL: #{rss.channel.link}"
puts "Total entries: #{rss.items.size}"
rss.items.each do |item|
#   puts "<a href='#{item.link}'>#{item.title}</a>"
#   puts "Published on: #{item.date}"
#   puts "#{item.description}"
   parseBoxee(item.description)
end



#!/usr/bin/env ruby -rubygems

# Extract a basic activity stream from Boxee's Twitter output
# Dan Brickley <danbri@danbri.org>
#  
# Written as part of the NoTube project - http://www.notube.tv/

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



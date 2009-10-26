#!/usr/bin/env ruby -rubygems

# Extract a basic activity stream from Boxee's Twitter output
# Dan Brickley <danbri@danbri.org>
#  
# Written as part of the NoTube project - http://www.notube.tv/
# Opensource, do what you like but don't blame me.
# 
# Sample output:
# User: bandriball		verb: likes		title:  36 Crazy Fists		uri: http://www.joost.com/33i7he9
# User: bandriball		verb: likes		title:  Carl Sagan - 'A Glorious Dawn'  ft Stephen Hawking (Cosmos Remixed)		uri: http://www.youtube.com/watch?v=zSgiXGELjbc&amp;feature=youtube_gdata&amp;fmt=18
# User: bandriball		verb: recommended		title:  DigitalP: 19 Oct 09		uri: http://downloads.bbc.co.uk/podcasts/worldservice/digitalp/digitalp_20091020-1032a.mp3
# User: bandriball		verb: likes		title:  DigitalP: 19 Oct 09		uri: http://downloads.bbc.co.uk/podcasts/worldservice/digitalp/digitalp_20091020-1032a.mp3
# User: bandriball		verb: likes		title:  DocArchive: Iran and the West - part three		uri: http://downloads.bbc.co.uk/podcasts/worldservice/docarchive/docarchive_20090803-1017a.mp3
# User: bandriball		verb: recommended		title:  Le mystère Picasso		uri: http://www.imdb.com/title/tt0049531
# User: bandriball		verb: listening to		title:  Frédéric Chopin on lastfm		uri: http://www.last.fm/listen/artist/Frédéric Chopin/fans
# User: bandriball		verb: likes		title:  Le mystère Picasso		uri: http://www.imdb.com/title/tt0049531
# User: bandriball		verb: watching		title:  Le mystère Picasso		uri: http://www.imdb.com/title/tt0049531
# User: bandriball		verb: watching		title:  Hyperland		uri: http://www.imdb.com/title/tt0188677
# User: bandriball		verb: likes		title:  Hyperland		uri: http://www.imdb.com/title/tt0188677


require 'rss'
require 'open-uri'
rss_feed = "http://twitter.com/statuses/user_timeline/85093859.rss" # bandriball

def deBitly(id = 'NIL')
  require 'net/http'
  require 'uri'
  url = URI.parse(id)
  uu = nil
  if url.path.size > 0
    req = Net::HTTP::Get.new(url.path)
    begin
    res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
    case res
    when Net::HTTPRedirection
     uu = res['Location']
    end
   end
  end
  return uu
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

#puts "Title: #{rss.channel.title}"
#puts "RSS URL: #{rss.channel.link}"
puts "Total entries: #{rss.items.size}"
rss.items.each do |item|
#   puts "<a href='#{item.link}'>#{item.title}</a>"
#   puts "Published on: #{item.date}"
#   puts "#{item.description}"
   parseBoxee(item.description)
end



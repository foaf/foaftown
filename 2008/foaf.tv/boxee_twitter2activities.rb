#!/usr/bin/env ruby -rubygems

# Extract a basic activity stream from Boxee's Twitter output
# Dan Brickley <danbri@danbri.org>
#  
# Written as part of the NoTube project - http://www.notube.tv/
# Opensource, do what you like but don't blame me.
# 
# Sample output:
# Cornercase:foaf.tv danbri$ ./boxee_twitter2activities.rb 
# Boxee Activities: Twitter / bandriball
# Total entries: 13
# verb: likes		title:  DocArchive: John Simpson Returns to 1989		uri: http://downloads.bbc.co.uk/podcasts/worldservice/docarchive/docarchive_20091015-1428a.mp3
# verb: likes		title:  October 15, 2009 - Guest: Jennifer Burns		uri: http://www.thedailyshow.com/full-episodes/252488/thu-october-15-2009-jennifer-burns
# verb: likes		title:  36 Crazy Fists		uri: http://www.joost.com/33i7he9
# verb: likes		title:  Carl Sagan - 'A Glorious Dawn'  ft Stephen Hawking (Cosmos Remixed)		uri: http://www.youtube.com/watch?v=zSgiXGELjbc&feature=youtube_gdata&fmt=18
# verb: recommended		title:  DigitalP: 19 Oct 09		uri: http://downloads.bbc.co.uk/podcasts/worldservice/digitalp/digitalp_20091020-1032a.mp3
# verb: likes		title:  DigitalP: 19 Oct 09		uri: http://downloads.bbc.co.uk/podcasts/worldservice/digitalp/digitalp_20091020-1032a.mp3
# verb: likes		title:  DocArchive: Iran and the West - part three		uri: http://downloads.bbc.co.uk/podcasts/worldservice/docarchive/docarchive_20090803-1017a.mp3
# verb: recommended		title:  Le mystère Picasso		uri: http://www.imdb.com/title/tt0049531
# verb: listening to		title:  Frédéric Chopin on lastfm		uri: http://www.last.fm/listen/artist/Frédéric Chopin/fans
# verb: likes		title:  Le mystère Picasso		uri: http://www.imdb.com/title/tt0049531
# verb: watching		title:  Le mystère Picasso		uri: http://www.imdb.com/title/tt0049531
# verb: watching		title:  Hyperland		uri: http://www.imdb.com/title/tt0188677
# verb: likes		title:  Hyperland		uri: http://www.imdb.com/title/tt0188677


require 'optparse'
require 'rss'
require 'open-uri'
require 'iconv' 

options = {}
optparse = OptionParser.new do|opts|
  opts.banner = "Usage: boxee_twitter2activities.rb [options]"
  options[:verbose] = false
  opts.on( '-v', '--verbose', 'Output more information' ) do
    options[:verbose] = true
  end
  options[:user] = nil
  opts.on( '-u', '--user USER', 'Username on microblogging site.' ) do|u|
    options[:user] = u
  end
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
  # could add identi.ca or statusnet in general if supported by boxee or twitter
end
optparse.parse!

userid = 'bandriball' # default for testing, also try with: -u libbyboxee
if options[:user]
  userid = options[:user]
end
rss_feed = "http://twitter.com/statuses/user_timeline/"+userid+".rss"
# rss_feed = "http://twitter.com/statuses/user_timeline/85093859.rss" # bandriball

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
  return uu.gsub(/&amp;/, '&')
end

def deIplayer(u)
  if (u =~ /http:\/\/www.bbc.co.uk\/iplayer\/episode\/(\w*)\//)
     return ("http://www.bbc.co.uk/programmes/#{$1}")
  end
  return u
end

# GOT: bandriball: watching Hyperland on Boxee. check it out at http://bit.ly/3Gp4Z2
def parseBoxee(str) 
  # puts "GOT: #{str}"
  str =~ /([^:]+):\s*(likes|recommended|listening to|watching)(.*) on Boxee\. .* at (.*)/
  user,verb,title,uri = $1, $2, $3, $4
  if (uri == nil)
     # puts "No URI; skipping..."
     return;
  end
  uri = deBitly(uri)
  uri = deIplayer(uri)


  # http://po-ru.com/diary/fixing-invalid-utf-8-in-ruby-revisited/
  ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
  verb_u8 = ic.iconv(verb + ' ')[0..-2]
  title_u8 = ic.iconv(title + ' ')[0..-2]
  uri_u8 = ic.iconv(uri + ' ')[0..-2]

  puts "verb: #{verb_u8}\t\ttitle: #{title_u8}\t\turi: #{uri_u8}\n"
end



rss_content = ""
open(rss_feed) do |f|
   rss_content = f.read
end
rss = RSS::Parser.parse(rss_content, false)

puts "Boxee Activities: #{rss.channel.title}"
#puts "RSS URL: #{rss.channel.link}"
puts "Total entries: #{rss.items.size}"
rss.items.each do |item|
#   puts "<a href='#{item.link}'>#{item.title}</a>"
#   puts "Published on: #{item.date}"
#   puts "#{item.description}"
   parseBoxee(item.description)
end



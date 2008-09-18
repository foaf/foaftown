#!/usr/bin/ruby
#
# Read BBC genres list for MB artists, and a last.fm history
# Emit a genres profile for that account holder.
# see http://mashed-audioandmusic.dyndns.org/#artistgenre
#
# Ultimately this should allow other services to be swapped in for 
# music prefs info (eg. Facebook music pref field, Myspace buddies, etc).


require 'net/http'
    require 'uri'

    def fetch(uri_str, limit = 10)
      # You should choose better exception.
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0

      response = Net::HTTP.get_response(URI.parse(uri_str))
      case response
      when Net::HTTPSuccess     then response
      when Net::HTTPRedirection then fetch(response['location'], limit - 1)
      else
        response.error!
      end
    end

userid='HarryHalpin'
userid='danbri'
userid='darobin'
artists=fetch('http://ws.audioscrobbler.com/1.0/user/'+userid+'/topartists.txt?type=12month').body

genres={}
gf = File.new('musicbrainz_artist_genres.txt') # orig: http://mashed-audioandmusic.dyndns.org/musicbrainz_artist_genres.txt.gz
gf.each do |g|
  g.chomp!
  mbid,genre=g.split(/\s/,2)
#   puts "genre: #{genre} mbid: #{mbid}"
  if (genres[mbid]==nil) 
    genres[mbid] = genre;
  else 
    STDERR.puts "Already got genre."
  end
end

profile={}
# puts "Got artists, genres"
artists.split(/\n/).each do |line|
  mbid,i,label=line.split(/,/,3)
  #  puts "MBID: #{mbid} I: #{i} Label: #{label}"
  g=genres[mbid]
#   puts "Genre is: #{ g } \n\n"
  if (g)

# Robin's use case: "but I don't listen to World music!"
#      if (g =~ /World/) 
#          puts "World artist: #{line} "
#      end
    if (profile[g])
      profile[g] = profile[g] + 1
    else
      profile[g]=1
    end
  end
end

profile.each_pair do |cat,score|
  puts "#{cat}: #{score}"
end

# todo: 
# - aren't computers good at sorting?
# - autogenerate foaf/rdfa 
# - how to represent this? :interest using bbc pages for topics?
# - post to foaf hosts via oauth would be nice

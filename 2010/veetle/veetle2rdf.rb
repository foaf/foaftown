#!/usr/bin/ruby -rubygems
require 'json'
require 'net/http'
data=''
Net::HTTP.start('veetle.com', 80) do |http| 
   x = http.get('/channel-listing-cross-site.js').body  
   x.gsub!(/VEETLE\.channelList\.preFetch\(\);/,'')
   x.gsub!(/VEETLE\.channelList\.list=/,'')
   x.gsub!(/; VEETLE\.channelList\.postFetch\(\);/,'')
   data = JSON.parse(x)
end

data.each do |c|
  puts "\n\n"
  puts "Channel: #{c['channelId']}  t:#{c['title']}  d:#{c['description']}  v:#{c['numberOfViews']} pop:#{c['popularityIndex']}"
  puts "\n\n"
   
  Net::HTTP.start('veetle.com', 80) do |http| 
     p = '/index.php/channel/ajaxEverything/' + c['channelId']
     y = http.get(p).body  
     print "\n\nChannel List data..."  
     l = JSON.parse(y)
     l.each_key do |k|
       print "\t#{k}: #{l[k]}\n"
     end

     if (l['programme'] != nil) 
       if (l['payload'] != nil) 
      
       print "Got a programme list:\n"
       print l['programme']
       l['programme']['payload'].each do |item|
         print "Item: #{item['playOrder']}  t: #{item['title']} d:#{item['description']} l:#{item['durationInSeconds']}\n\n"
       end
       puts
     end
    end
	# programme: payload[{"playOrder":0,"title":"8 Mile","description":"","durationInSeconds":6355},{"playOrder":1,"title":"17 Again","description":"","durationInSeconds":6111},{"playOrder":2,"title":"30 Days of Night","description":"","durationInSeconds":6785},{"playOrder":3,"title":"50 First Dates","description":"","durationInSeconds":5944},{"playOrder":4,"title":"300","description":"","durationInSeconds":6996}
  end
end


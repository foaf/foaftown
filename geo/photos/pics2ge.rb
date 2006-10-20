#!/usr/bin/env ruby
require 'rubygems'
require 'json'

#file = ARGV.pop
file = '_f.js' 
pics = `cat #{file}`

def esc(str)
   str = str.to_s.gsub("&", "&amp;")
   str = str.gsub("\"", "&apos;")
   str = str.gsub("\"", "&quot;")
   str = str.gsub("<", "&lt;")
   str.gsub(">", "&gt;")
end

res = JSON.parse pics

puts '<?xml version="1.0" encoding="UTF-8"?>'
puts "\n"
puts '<kml xmlns="http://earth.google.com/kml/2.0">'
puts "\n"
puts "<Folder><name>foaftown tester</name>\n"

res["results"]["bindings"].each do |pic| 

  id = esc pic['id']['value']
  owner = esc pic['owner']['value']
  secret = esc pic['secret']['value']
  server = esc pic['server']['value']
  title = esc pic['title']['value']
  lat = esc pic['latitude']['value'] if pic['latitude']
  lon = pic['longitude']['value'] if pic['longitude']

  # See  http://www.flickr.com/services/api/misc.urls.html
  s_url = "http://static.flickr.com/" + server + "/" + id + "_" + secret + "_s.jpg"
  m_url = "http://static.flickr.com/" + server + "/" + id + "_" + secret + "_m.jpg"
  image_url = "http://static.flickr.com/" + server + "/" + id + "_" + secret + ".jpg"

  img_page = "http://www.flickr.com/photos/" + owner +"/" + id 

#  puts "#{title} #{id} #{lat} #{lon} #{s_url} #{img_page}"

puts "<Folder>
   <name>#{title}</name>
   <visibility>1</visibility>
   <Placemark>
     <description><![CDATA[ 

	<a href='#{img_page}'><img alt='#{title}' 
			width='240' src='#{m_url}' /></a>  
	by #{owner} at lat:#{lat} lon:#{lon} 

	]]></description>
      <name> #{title} </name>
        <View>
          <longitude>#{lon}</longitude>
          <latitude>#{lat}</latitude>
	  <range>0</range>
	  <tilt>30</tilt>
          <heading>0</heading>
        </View>
      <visibility>1</visibility>
      <styleUrl>root://styleMaps#default?iconId=0x307</styleUrl>
      <Style>
       <icon>#{m_url}</icon>
      </Style>
      <Point>
       <coordinates>#{lon},#{lat},0</coordinates>
      </Point>
    </Placemark>
  </Folder>\n"

end

puts "</Folder>\n";
puts "</kml>\n\n";




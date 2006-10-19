#!/usr/bin/env ruby

require 'rubygems'
require 'json'

pics = `cat f.js`

res = JSON.parse pics

puts '<?xml version="1.0" encoding="UTF-8"?>'
puts "\n"
puts '<kml xmlns="http://earth.google.com/kml/2.0">'
puts "\n"
puts "<Folder><name>SemLife Test</name>\n"



res["results"]["bindings"].each do |pic| 
  id = pic['id']['value']
  owner = pic['owner']['value']
  secret = pic['secret']['value']
  server = pic['server']['value']
  title= pic['title']['value']
  lat=pic['latitude']['value']
  lon=pic['longitude']['value']

  # See  http://www.flickr.com/services/api/misc.urls.html
  s_url = "http://static.flickr.com/" + server + "/" + id + "_" + secret + "_s.jpg"
  img_page = "http://www.flickr.com/photos/" + owner +"/" + id 

  puts "#{title} #{id} #{lat} #{lon} #{s_url} #{img_page}"

puts "<Folder>
   <name>image placemark</name>
   <visibility>1</visibility>
   <Placemark>
     <description><![CDATA[ <img src='#{s_url}' /> $media placemark, by $who at lat:#{lat} lon:#{lon} ]]></description>
      <name> </name>
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
       <icon>#{s_url}</icon>
      </Style>
      <Point>
       <coordinates>#{lon},#{lat},0</coordinates>
      </Point>
    </Placemark>
  </Folder>\n"

end

puts "</Folder>\n";
puts "</kml>\n\n";




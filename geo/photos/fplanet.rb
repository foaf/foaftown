#!/usr/bin/env ruby


require 'rubygems'
Gem.path.push("/home/danbri/.gems")
require 'json'

# Ruby script to make KML for a Flickr group specified by its ID code
# Uses XSLT transforms by Danny Ayers
# Assumes some unix environment currently, including xsltproc commandline
# by Dan Brickley <danbrickley@gmail.com>
# $Id$

# Ruby script to make KML for a Flickr group specified by its ID code
# Uses XSLT transforms by Danny Ayers
# Assumes some unix environment currently, including xsltproc commandline
# by Dan Brickley <danbrickley@gmail.com>
# $Id$

# Notes:
#
# We use JSON that has been transformed from XML
# rather than Flickr's native JSON output. This is to explore 
# possibility of a compatibility layer with SPARQL-accessed RDF data
# eg. such as that archived by the Net::Flickr::Backup CPAN module.
# Our JSON is in a tabular structure specified by W3C as a representation 
# of the results we might get back from an RDF query. Basically, a bit like SQL.
# 
# To achieve this we create some scratch files (_*.xml etc) and run 
# XSLT on the commandline. Bit of a mess. But you'll live.
# 
# Other mess:
# JSON library is a Ruby gem installation. How do we do that on Dreamhost?
#
# see http://norman.walsh.name/2006/10/20/examples/login

# Escape a string for printing to XML
# 
def esc(str)
   str = str.to_s.gsub("&", "&amp;")
   str = str.gsub("\"", "&apos;")
   str = str.gsub("\"", "&quot;")
   str = str.gsub("<", "&lt;")
   str.gsub(">", "&gt;")
end

# return a Flickr username, given a Flickr ID
# todo: failure conditions? - bad ID? no name set?
#
def nameFromID(user_id, cache)

  return cache[user_id] if cache[user_id]

  require 'net/http'
  require 'uri'
  api_key=ENV["FLICKR_API_KEY"] 
  uri="http://api.flickr.com/services/rest/?method=flickr.people.getInfo&api_key=#{api_key}&user_id=#{user_id}"
  who = Net::HTTP.get(URI.parse(uri))
  STDERR.puts("REST API user lookup: #{uri}")
  who =~ /<username>(.*)<\/username>/ # dumbass. use an api. any api!
  name = ""
  name = $1 if $1
  cache[user_id] = name
  STDERR.puts("Cached user lookup: #{user_id} as '#{name}' ")
  return name
end


# Assuming our data is in file, return it KMLized
#
def json2kml(js, name="")
  res = JSON.parse js

  kml = ""

  kml += '<?xml version="1.0" encoding="UTF-8"?>'
  kml += "\n"
  kml += '<kml xmlns="http://earth.google.com/kml/2.0">'
  kml += "\n"
  kml += "<Folder><name>foaftown tester #{name}</name>\n"
  name_cache = {}

  res["results"]["bindings"].each do |pic| 
    id = esc pic['id']['value']
    owner = esc pic['owner']['value']
    secret = esc pic['secret']['value']
    server = esc pic['server']['value']
    title = esc pic['title']['value']
    lat = esc pic['latitude']['value'] if pic['latitude']
    lon = pic['longitude']['value'] if pic['longitude']
    acc = pic['accuracy']['value'] if pic['accuracy']
    # See  http://www.flickr.com/services/api/misc.urls.html
    s_url = "http://static.flickr.com/" + server + "/" + id + "_" + secret + "_s.jpg"
    m_url = "http://static.flickr.com/" + server + "/" + id + "_" + secret + "_m.jpg"
    image_url = "http://static.flickr.com/" + server + "/" + id + "_" + secret + ".jpg"
    img_page = "http://www.flickr.com/photos/" + owner +"/" + id 
    #  puts "#{title} #{id} #{lat} #{lon} #{s_url} #{img_page}"
    STDERR.puts("Making KML for: #{title} #{id} #{lat} #{lon} #{s_url} #{img_page}")
    kml += "<Folder>
    <name>#{title}</name>
    <visibility>1</visibility>
    <Placemark>
      <description><![CDATA[ 

       <p>
	<a href='#{img_page}'><img alt='#{title}' 
			width='240' src='#{m_url}' /></a>  <br />
	by <a href='http://www.flickr.com/photos/#{owner}/'>#{nameFromID(owner,name_cache)}</a>
        <br /><small>at lat:#{lat} lon:#{lon} map level: #{acc}</small></p>
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
  kml += "</Folder>\n";
  kml += "</kml>\n\n";
  return kml
end

def getGroupMapXML(group_id)
  require 'net/http'
  require 'uri'
  api_key=ENV["FLICKR_API_KEY"]
  uri="http://api.flickr.com/services/rest/?min_taken_date=1970-01-01%2000:00:00&bbox=-180,-90,180,90&method=flickr.photos.search&name=value&api_key=#{api_key}&group_id=#{group_id}&extras=license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo&per_page=500&accuracy=6"
  xdata = Net::HTTP.get(URI.parse(uri))
  xdata.gsub!("&quot;","&apos;") # so we can XSLT into JSON
  return xdata
end


def storeGroupMapJSON(group_id)
  mymapdata = getGroupMapXML(group_id)
  fdata = File.new("_fdata.xml","w")
  fdata.puts(mymapdata)
  fdata.close
  `xsltproc flickr-sparqlxml.xsl _fdata.xml > _tmp.xml`
  `xsltproc pretty-xml.xsl _tmp.xml > _fdata_sparql.xml`
  `xsltproc flickr-sparqljson.xsl _fdata.xml > _fdata_json.js`
end

def getGroupKML(group_id)
  storeGroupMapJSON(group_id)
  file = File.new("_fdata_json.js", "r")
  js=""
  while (line = file.gets) # todo: get string from file must be easier
    js = js + line  
  end
  file.close
  return json2kml(js, "group "+group_id)
end

def storeGroupKML(pool, dir="")
  mykml = getGroupKML(pool)
  fn= "_pool_#{pool}.kml"
  kfile = File.new(dir+fn,"w+")
  kfile.puts(mykml)
  STDERR.puts("Stored KML for pool #{pool} in #{dir} file: #{fn} ")
  kfile.close
end

group = "43935391225@N01" # B.A.
dir = "./examples/"
#storeGroupKML(group, dir)



#storeGroupKML("52240190192@N01",dir)# http://www.flickr.com/groups/iranian/pool/map
#storeGroupKML("43935391225@N01",dir) # http://www.flickr.com/groups/bsas/pool/map
#storeGroupKML("46594087@N00",dir) # http://www.flickr.com/groups/bristol/pool/map
 

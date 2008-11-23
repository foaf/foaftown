#!/usr/bin/env ruby

# Reads a file, outputs a basic RDFa-ization of it
# Dan Brickley <http://danbri.org/>

oiltype="foaf:Organization oilit:OilIndustryOrganization"
oiltype="oilit:OilIndustryProduct"

file = ARGV.shift

if file==nil 
  warn("no file specified")
  exit(1)
end

STDERR.puts "Reading file: #{file}"

f = File.open(file,'r')
if f == nil
  warn("No file found: #{file} ")
  exit(1)
end

f.each_line do |line|
 line.gsub!(/<a href="([^"]*)">([^<]*)<\/a>\s*<br\s*\/>/i) do  
    "<div><a typeof='#{oiltype}' rev='foaf:primaryTopic' about='#{$1}#itself' "+
    "href='#{$1}' property='foaf:name' >#{$2}</a></div>\n"
 end

 puts line

end

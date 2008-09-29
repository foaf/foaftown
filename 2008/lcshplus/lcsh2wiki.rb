#!/usr/bin/ruby

require 'rubygems'
require 'json/pure'

def search(str)
  str.gsub!(/\s+/,"%20")
  str.gsub!(/'/,"\\'")
  str.gsub!(/\([^\)]+\)/,"")
  c="curl -s -e http://danbri.org/  'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{str}%20site:wikipedia.org'"
  puts "Cmd: #{c}"
  res = `#{c}`
  return res
end


# Ok, we get ourselves a working subset of lcsh labels
st= ARGV.shift
if (st==nil)
  st='bristol' 
end
st="#{st}"
st.chomp!

puts "Grepping lcsh subset for term: #{st} into _tmp_st.nt"
`grep prefLabel lcsh.nt | grep -i '#{st}' > _st.nt`

# we get the labels and concept IDs
comm= "roqet -r json -e 'select ?c ?n from <file:_st.nt> where { ?c <http://www.w3.org/2004/02/skos/core#prefLabel> ?n }' " 
lcsh = `#{comm}`

# fix syntax bug, http://bugs.librdf.org/mantis/view.php?id=279    ""ordered" : false,

lcsh.gsub!(/""ordered/,"\"ordered")
lcsh.gsub!(/""distinct/,"\"distinct")

data = JSON.parse(lcsh)

#curl -e http://danbri.org/  'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=Bristol%20Buses%20site:wikipedia.org'

rows = data['results']['bindings']
rows.each do |r|
  prefLabel = r['n']['value']
  puts "Searching: #{prefLabel}"
  hits = JSON.parse(search(prefLabel))
  hits['responseData']['results'].each do |h|
    #http://en.wikipedia.org/wiki/
    url = h['unescapedUrl']
    title = h['titleNoFormatting']
    title.gsub!(/\- Wikipedia, the free encyclopedia/,"")
    url =~ /\/([^\/]+)$/
    id = $1
    puts "Got: #{id} Title: #{title} "
  end
  puts "\n"
end




# from a phrase to wikipedia URIs
#curl -e http://danbri.org/  'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=Bristol%20Buses%20site:wikipedia.org'
#
#{"responseData": {"results":[{"GsearchResultClass":"GwebSearch","unescapedUrl":"http://en.wikipedia.org/wiki/Bristol_Riots","url":"http://en.wikipedia.org/wiki/Bristol_Riots","visibleUrl":"en.wikipedia.org","cacheUrl":"http://www.google.com/search?q\u003dcache:5V7VhgmhIWkJ:en.wikipedia.org","title":"\u003cb\u003eBristol\u003c/b\u003e Riots - Wikipedia, the free encyclopedia","titleNoFormatting":"Bristol Riots - Wikipedia, the free encyclopedia",

#!/usr/bin/ruby

# using a data/ dir

i=1
accountName='modanbri'
accountName='laroyo'
#accountName='danbri'
page=1
size=50
max=1000

def grddl(fn, i) 
  puts "Pseudo-GRDDLing #{fn}"
  rfn = "data/skos-#{i}.rdf"
  puts "Running: xsltproc yt2skos.xsl #{fn} > #{rfn}"
  `xsltproc yt2skos.xsl #{fn} > #{rfn}`
  `rapper -c file:#{rfn}`
end


while (true) do
  break() if (i>2000)
  url = "http://gdata.youtube.com/feeds/api/users/laroyo/favorites?start-index=#{i}&max-results=#{size}"
  puts "Page: #{page} i=#{i} url=#{url}"
  fn = "data/_page#{i}.xml"
  `curl --silent '#{url}' > #{fn} `
  score = `grep entry #{fn} | wc -l`.to_i
  puts "Entries: #{score}"   
  break() if score==0
 
  grddl(fn, i)

  i=i+50
end


#!/usr/bin/ruby

# Fetches mailman raw archives from a base URI
#
# NOT suitable yet for untrusted archives due to use of curl.
# 
# Dan Brickley <http://danbri.org/>

# Requirements: a 'data/' subdirectory should exist.

toc = 'http://lists.burri.to/pipermail/geowanking/'
require 'open-uri'
require 'pp'
require 'zlib'

gzips=[]

def fetch (uri, fn='')
  puts "Archiving: #{uri} as #{fn} "
  `cd data; curl -O '#{uri}'` # only if we trust the toc page! # IMPORTANT
			# to generalise this, use pure ruby not commndline
			# see below for non-working attempt.	

   ## no joy:
   #  gz = open(uri).read
   #  month = Zlib::Deflate.deflate(gz)
   #  File.open("data2/"+fn, 'w') do |f2|  
   #   f2.puts(gz)
   #  end  
   # http://stdlib.rubyonrails.org/libdoc/zlib/rdoc/index.html


end



open( toc ) do |f|
  pp  f.meta
  pp "Content-Type: " + f.content_type
  pp "last modified" + f.last_modified.to_s
  no = 1
  # print the first three lines
  f.each do |line|
    # We want the gziped archived
    # <td><A href="2008-September.txt.gz">[ Gzip'd Text 15 KB ]</a></td>
    if (line =~ /href="([^"]+)">\[ Gzip/ ) 
      puts "GZIP! #{$1} "
      gzips.push( $1)
    end
  end
end

gzips.each do |rel|
  puts "Gzip URI: #{rel}"
  fetch(toc+rel,rel)
end



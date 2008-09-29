#!/usr/bin/ruby
#
# This is a quick hack utility to summarise the link structure of 
# news.bbc.co.uk, and operates over a local crawled copy of the site
# (I used curlmirror), by default in the dest/ subdirectory.
#
# See below for a 'find' script that evokes this program on each file. 
# Ultimately the ruby script should handle this logic. 
#
# The idea here: links are metadata. BBC News articles have hardcoded
# "see also" links to other (*previous*) BBC stories, plus to key Web URLs.
# So we can build an index of this linking structure to determine some 
# implicit similarity data about the articles. This includes their topics,
# and should allow us to suggest relevant *future* URLs for older articles.
# TODO:
# Think about computing a score for topical closeness that takes into account
# the fact that only previous pages are allowed to be added at authorship time.
# So the presence of page-A as a see-also topic for page-B is more impressive
# if lots of other pages existed as 'competition', at the moment B was tagged.
#
# dc:creator [ :openid <http://danbri.org/>; :mbox <mailto:danbri@danbri.org> ].


# Run it on a subset with:
# 		find dest/1/hi/world/ -name \*.html -exec ruby ./arr.rb {} \; 



# Notes:
# clean these defaults out: 
# BBC, News, BBC News, news online, world, uk, international, foreign, british, online, service
# Todo: crawl everything
# get titles
# normalise URIs
# extract special keywords
# generate rdf/a files
# language? welsh etc
# skosify categories
# offsite vs internal crossrefs
# other link metadata?
# page types?
# special case sport?

def path2url(file)
  a=('http://news.bbc.co.uk' +  file.gsub(/^(\.\/)*dest/,"") )
  a.gsub!(/\/\//,"/")
  return(a)
end

def normal(file, rel) 
  #  puts "norming: \t\tfile: #{file} url: #{rel}"
  if (rel =~ /^http:/)
    return(rel)
  end
  file = "#{file}"
  current=path2url(file)
  current.gsub!( /([^\/]+)$/,"")
  a=current+rel
  a.gsub!(/\/\/$/,"/")
  return(a)
end

def dotfix(url)
#  puts "#Fixing: #{url}"
  if (! url =~ /\.\./)
#    puts "# its ok already, returning. "    
    return(url)
  else
    # at least one ..
    new=''
    found_pair=false
    url.scan(/(.*)\/(\w+)\/\.\.\/(.*)$/) do
#      puts "# Found a pair. #{$1} - #{$2} - #{$3}"
      new = $1 + '/' + $3
      found_pair=true
    end
#    puts "# Found pair is: #{found_pair}"        
    if (found_pair==true)
      url = new
      if (url =~ /\.\./)
#        puts "# new url has dots, retrying. "    
        return(dotfix(url))
      else
        return(url)
      end
    end
#    puts "# Got dots but no pair. returning."
    return(url)
  end
  post = dedot(url)
  if (post =~ /\.\./)
    url = dotfix(post)
  else 
    return(post)
  end
end

 
# we want a local file path, and the real Web URL
def extract(file,myurl)
  STDERR.puts "# Scanning: #{myurl} via file:#{file}"
  doc=""
  dct='http://purl.org/dc/terms/'
  #  rdf = "<dc:Document rdf:about='#{myurl}'  xmlns:dc='http://purl.org/dc/terms/' xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'>\n"
  nt = ''
  File.read(file).each do |x| 
    doc += x
  end
  doc.gsub!(/\n/, "")
  doc.gsub!(/\s+/, " ")

  if (doc =~ /<title>\s*([^<]*)\s*<\/title>/) 
    # puts "title: #{$1}"
    t = $1
    t.gsub!(/\s*$/,"")
    nt += "<#{myurl}> <#{dct}title> \"#{t}\" . \n"
  end
  doc.scan(/<meta name="([^"]*)" con∫tent="([^"]*)"\s*\/>/) do
    p=$1
    v=$2
    p.downcase!
    puts "#{p}: #{v}" 
  end
  doc.scan(/<div\s+class="arr">\s*<a\s+href="([^"]*)">\s*([^<]*)\s*<\/a>\s*<\/div>/) do
    rt = $2
    rl = $1
    n = normal(file,rl)
    #  puts "# Starting dotfix with #{n}"
    n = dotfix(n)
     n.chomp!
    nt += "<#{myurl}> <#{dct}relation> <#{n}> .\n"
    rt.chomp!
    rt.gsub!(/\s*$/,"")
    nt += "<#{n}> <#{dct}title> \"#{rt}\" .\n"
  end
  puts "\n"
  puts nt
end




### main script:
file = ARGV.shift

if (file != nil) 
  STDERR.puts "# Found argv #{file} - running in single doc mode."
  url=path2url(file)
  extract(file, url)
else      
  STDERR.puts "# Running in huge list of files mode (sampler)."

  # todo = `find . -name \*.html -exec ruby ./arr.rb {} \\; `
  todo = `find dest/1/hi/world/ -name \*.html -exec ruby ./arr.rb {} \\; `
  todo.each do |file|
    file.chomp!
    STDERR.puts "# Using: #{file}"
    url=path2url(file)
    extract(file, url)
  end
end

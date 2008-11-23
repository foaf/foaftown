#!/usr/bin/env ruby

# for each of peo/, com/, pro/ (people, companies, products)
# we get a list of articles for that person
# 
# <BR><A HREF = "../../2article/0405_14.htm" > AAPG 2004 Convention, Dallas (May 2004)</A>
#
# We scan out lines like these from each hub page, and emit RDF (in NTriples line syntax).
#
# Dan Brickley <http://danbri.org/>

# Target website
article_base = 'http://www.oilit.com/2journal/2article/'
index_base = 'http://www.oilit.com/2journal/2index/'

title = {}

# RDF vocabs
dc = 'http://purl.org/dc/elements/1.1/'
foaf = 'http://xmlns.com/foaf/0.1/'

peo = `find 2peo -name \\*.htm -print `
com = `find 2com -name \\*.htm -print `
pro = `find 2pro -name \\*.htm -print `
all = peo+com+pro

all.split(/\n/).each do |idx|
  puts 
  thing = index_base+idx+"#itself" # URI of 'the thing itself'
  puts "# Scanning index file: #{idx}"

  tidyargs = "-bare -clean -numeric -utf8 -asxml -quiet "
  
#  f = File.open(idx,'r')
#  if f == nil
#    warn("No file found: #{file} ")
#    exit(1)
#  end
#  doc = f.read

  doc = `cat #{idx} | tidy #{tidyargs} `
  #  STDERR.puts "Loaded doc #{idx} tidily. #{doc.size}"
  doc.gsub!(/\n/,' ')

  # puts "\n\n\n"+doc+"\n\n\n"

  doc.gsub(/"\.\.\/\.\.\/2article\/([^"]*)"\s*>\s*([^<]+)\s*<\/A/i) do
    a = $1
    t = $2
    article = article_base+a

    if (title[article] == nil )
      puts "# Setting title=#{t} for article=#{article} "
      c=t
      c.gsub!(/"/,'\'')
      c.gsub!(/[^[:graph:]]/, '') 
      title[article] = c
      puts "<#{article}> <#{dc}title> \"#{t}\" . "
    else 
      puts "# Skipping title=#{t} for article=#{article}, already got a title: #{title[article]}"
    end

    puts "<#{article}> <#{foaf}topic> <#{thing}> . "
  end
  puts "\n"
end


 

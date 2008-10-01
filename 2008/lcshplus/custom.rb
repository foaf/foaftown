#!/usr/bin/ruby
#
# Hand-crafted parser for LCSH SKOS ntriples 
# 

f = File.new('tree.nt')

# <http://lcsh.info/sh85016247#concept> <http://www.w3.org/2004/02/skos/core#prefLabel> "Brachycentrus"@en .
# <http://lcsh.info/sh96011169#concept> <http://www.w3.org/2004/02/skos/core#narrower> <http://lcsh.info/sh85077475#concept> .
# <http://lcsh.info/sh96011169#concept> <http://www.w3.org/2004/02/skos/core#prefLabel> "Prerogative, Royal--France"@en .

broader = {}
labels = {}
f.each do |c|
#  puts "Got: #{c}"
  c.chomp!
  c =~ /\s*<http:\/\/lcsh.info\/(\w*\d+)#concept>\s+<([^>]+)>\s+(.*)\s*\.\s*$/
  s = $1
  p = $2
  o = $3
  if (o==nil)
    puts "Skipping; no object. line: #{c}"
    break()
  end
  o.chomp!
  o.gsub!(/"@en\s*/,'"')
#  puts "parsed: #{s} -- #{p} -- '#{o}' #{o.class}"
  if (o =~ /^"/)
#    puts "Literal label on #{s}: #{o}"
    labels[s] = o
  else
#    puts "Resource"
     o =~ /(\w+\d+)/
     o = $1
    if (p =~ /broader/) 
#      puts "broader"   
      if broader[s] != nil
        puts "Got a value for #{s} already: #{broader[s]}"
      else
        broader[s] = o
        puts "broader #{s} = #{o}"
      end
    elsif (p =~ /narrower/)
#      puts "narrower (reversing lookup)"
      if broader[o] != nil
#        puts "Got a value for #{o} already: #{broader[o]}"
      else
        broader[o] = s
        puts "broader #{o} = #{s}"
      end
    else 
      puts "Unexpected value."
    end
  end
end

broader.each_pair do |x,y|
  puts "#{x} > #{y}"
end

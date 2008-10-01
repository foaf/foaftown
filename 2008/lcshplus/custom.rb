#!/usr/bin/ruby
#
# Hand-crafted parser for LCSH SKOS ntriples 
# 
# we can extract a subset of the ntriples first, to reduce working set.
#
# egrep '(prefLabel|broader|narrower)' lcsh.nt > tree.nt
#
# <http://lcsh.info/sh85016247#concept> <http://www.w3.org/2004/02/skos/core#prefLabel> "Brachycentrus"@en .
# <http://lcsh.info/sh96011169#concept> <http://www.w3.org/2004/02/skos/core#narrower> <http://lcsh.info/sh85077475#concept> .
# <http://lcsh.info/sh96011169#concept> <http://www.w3.org/2004/02/skos/core#prefLabel> "Prerogative, Royal--France"@en .


store = true
data = "/Users/danbri/working/foaftown/2008/lcshplus/data/"

f = File.new('tree.nt')
#f = File.new('1000.nt') # head -1000 tree.nt > 1000.nt

require 'treemap'
require 'dbm'

#broader = {}
broader = DBM.new(data + "broader.dbm")

#labels = {}
labels = DBM.new(data + "labels.dbm")

store = false
if (store==true)
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
  #        puts "Got a value for #{s} already: #{broader[s]}"
        else
          broader[s] = o
   #        puts "broader #{s} = #{o}"
        end
      elsif (p =~ /narrower/)
  #      puts "narrower (reversing lookup)"
        if broader[o] != nil
  #        puts "Got a value for #{o} already: #{broader[o]}"
        else
          broader[o] = s
  #        puts "broader #{o} = #{s}"
        end
      else 
  #      puts "Unexpected value."
      end
    end
  end
end

puts "Stored? #{store}"

root = Treemap::Node.new(:label => "All", :size => 1000, :color => "#FFCCFF")

highest=nil
cache={}
i=0
  broader.each_pair do |x,y|
    if (i>100000)
      puts "100k"
      break()
    end
    print "#{i}   "
    l1 = labels[x]
    l2 = labels[y]
#    puts "#{x} #{l1} > #{y} #{l2}"
    c1 = Treemap::Node.new(:label => l1 , :size => 2 )
    c2 = Treemap::Node.new(:label => l2 , :size => 2 )
    c1.add_child(c2)
    root.add_child(c1)
    i = i + 1
  end

output = Treemap::HtmlOutput.new do |o|
  o.width = 850
  o.height = 850
  o.center_labels_at_depth = 1
end
puts output.to_html(root)


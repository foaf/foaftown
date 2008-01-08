#!/usr/bin/env ruby
#
# Proof of concept FOAF "knows" contact list Bloom filter. danbri@danbri.org

require 'rubygems'
gem 'bloomfilter'
require 'bloomfilter/BloomFilter'



# also needed: gem install RubyInline

# this version uses the gem packaged successor to BloominSimple


require 'json'

# we pass in a hasher block
# http://blog.rapleaf.com/dev/?p=6
bf = BloomFilter.new(1000) do |item| Digest::SHA1.digest(item.downcase.strip).unpack("VVVV") end


#see also http://ajax.suaccess.org/ruby/ruby-on-rails-converting-between-numeric-bases/
#http://www.faqs.org/rfcs/rfc2045.html
# perl: http://perldoc.perl.org/functions/pack.html
#    b	A bit string (ascending bit order inside each byte, like vec()).
#http://safari.oreilly.com/9780596529864/array_pack_directives
#http://www.rubycentral.com/pickaxe/ref_c_array.html#Array.pack
puts "############"

js = `roqet -q bloomer.rq -r json`; # get contact list as prop/value pairs
res = JSON.parse js
res["results"]["bindings"].each do |contact|
    prop = contact['prop']['value']
    val = contact['val']['value']
     print "Adding: '#{prop} #{val}' ; "
    bf.add("#{prop} #{val}")
    puts
end

puts                bf.include?("http://xmlns.com/foaf/0.1/mbox mailto:d.m.steer@lse.ac.uk")     # => true
puts                bf.include?("http://xmlns.com/foaf/0.1/mbox mailto:santaclaus@npole.example.com")    # => false
puts                bf.include?("http://xmlns.com/foaf/0.1/openid http://santa.example.com/")    # => false
 

puts "Serializing: "

puts bf.class
puts bf.guts.class
puts bf.guts.size

#puts bf.save("tmp/b1")

i=0
while(i<bf.guts.size) 
  puts i
  i +=1 
  puts bf.guts[i]
end

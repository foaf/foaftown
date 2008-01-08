#!/usr/bin/env ruby
#
# Proof of concept FOAF "knows" contact list Bloom filter. danbri@danbri.org

require 'rubygems'
require 'BloominSimple'
require 'json'
require 'digest/sha1'

# we pass in a hasher block
#bf = BloominSimple.new(1_000_000) { |item| Digest::SHA1.digest(item.downcase.strip).unpack("VVVV") }
bf = BloominSimple.new(1000) do |item| Digest::SHA1.digest(item.downcase.strip).unpack("VVVV") end


# see also http://ajax.suaccess.org/ruby/ruby-on-rails-converting-between-numeric-bases/
# http://www.faqs.org/rfcs/rfc2045.html
# perl: http://perldoc.perl.org/functions/pack.html
#     b	A bit string (ascending bit order inside each byte, like vec()).
# http://safari.oreilly.com/9780596529864/array_pack_directives
# http://www.rubycentral.com/pickaxe/ref_c_array.html#Array.pack
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

puts                bf.includes?("http://xmlns.com/foaf/0.1/mbox mailto:d.m.steer@lse.ac.uk")     # => true
puts                bf.includes?("http://xmlns.com/foaf/0.1/mbox mailto:santaclaus@npole.example.com")    # => false
puts                bf.includes?("http://xmlns.com/foaf/0.1/openid http://santa.example.com/")    # => false
 

puts "Serializing to base 16: "
a= eval "0b"+bf.bitfield.to_s()
puts a.to_s(base=16)

puts "a is "+a.to_s

s = [a.to_s].pack("m")
puts "Base64: #{s}"

#puts bf.hashnums
puts bf.class

#puts "Binary: "
#a= eval "0b"+bf.bitfield.to_s()
#puts a.to_s(base=2)

#%w{wonderful ball stereo jester flag shshshshsh nooooooo newyorkcity}.each do |a|
#  puts "#{sprintf("%15s", a)}: #{bf.includes?(a)}"
#end

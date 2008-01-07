#!/usr/bin/env ruby
#
# Proof of concept FOAF "knows" contact list Bloom filter. danbri@danbri.org

require 'rubygems'
require 'BloominSimple'
require 'json'
require 'digest/sha1'

#bf = BloominSimple.new(1_000_000) { |item| Digest::SHA1.digest(item.downcase.strip).unpack("VVVV") }
bf = BloominSimple.new(1000) { |item| Digest::SHA1.digest(item.downcase.strip).unpack("VVVV") }

js = `roqet -q bloomer.rq -r json`; # get contact list as prop/value pairs
res = JSON.parse js
res["results"]["bindings"].each do |contact|
    prop = contact['prop']['value']
    val = contact['val']['value']
    # puts "Adding to bloom: #{prop} #{val} "
    bf.add("#{prop} #{val}")
end

#puts                bf.includes?("http://xmlns.com/foaf/0.1/mbox mailto:d.m.steer@lse.ac.uk")     # => true
#puts                bf.includes?("http://xmlns.com/foaf/0.1/mbox mailto:santaclaus@npole.example.com")    # => false
#puts                bf.includes?("http://xmlns.com/foaf/0.1/openid http://santa.example.com/")    # => false
 

puts "Serializing to base 16: "
a= eval "0b"+bf.bitfield.to_s()
puts a.to_s(base=16)

s = [a.to_s].pack("m")
puts "Base64: #{s}"

puts bf.hashnums

#puts "Binary: "
#a= eval "0b"+bf.bitfield.to_s()
#puts a.to_s(base=2)

#%w{wonderful ball stereo jester flag shshshshsh nooooooo newyorkcity}.each do |a|
#  puts "#{sprintf("%15s", a)}: #{bf.includes?(a)}"
#end

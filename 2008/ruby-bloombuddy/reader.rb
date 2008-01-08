#!/usr/bin/env ruby
require 'rubygems'
gem 'bloomfilter'
require 'bloomfilter/BloomFilter'
require 'json'
bf = BloomFilter.new(1000) do |item| Digest::SHA1.digest(item.downcase.strip).unpack("VVVV") end

puts                bf.include?("http://xmlns.com/foaf/0.1/mbox mailto:d.m.steer@lse.ac.uk")     # => true
puts                bf.include?("http://xmlns.com/foaf/0.1/mbox mailto:santaclaus@npole.example.com")    # => false
puts                bf.include?("http://xmlns.com/foaf/0.1/openid http://santa.example.com/")    # => false


require 'Base64'

class BloomFilter

  def to_web
    Base64.encode64("#{@bits.size} #{@bits.to_s}")
  end

  def from_web(str)
   @bits = Base64.decode64(str)
   return @bits.size
  end


  def guts
    puts "Serializing: "
    i=0
    asc=""
    while(i< @bits.size) 
      i +=1 
      v = @bits[i]? 1 : 0 
      asc += v.to_s
    end
    return asc
  end
end





buddies="MTAwMCAAAgoAEFAFAgAA4IUAysAEIAAoAApACAAQAAACACAABBIAWEBBCEAA
QAQEMAkAAQQApBAACABYCAAAAEAAAAAAAAABCUEADCgARAAACYCQAAAEyCAI
AAgQAQAAMAAIAEABBAQQAEIQAVAQSAgCAAEAMAIQAABBAAgAEIAEjQ=="

puts bf.from_web(buddies)

puts "Workie?"

puts                bf.include?("http://xmlns.com/foaf/0.1/mbox mailto:d.m.steer@lse.ac.uk")     # => true
puts                bf.include?("http://xmlns.com/foaf/0.1/mbox mailto:santaclaus@npole.example.com")    # => false
puts                bf.include?("http://xmlns.com/foaf/0.1/openid http://santa.example.com/")    # => false


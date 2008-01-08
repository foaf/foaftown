#!/usr/bin/env ruby

require 'BloominSimple'
 
bf = BloominSimple.new(1000) { |item| Digest::SHA1.digest(item.downcase.strip).unpack("VVVV") }
t1= eval "0x8140a000048840080200000804800004802212010009026040802000000081042010400002004000008208008800000460812080000000000000010000008000010008000100001000000300400010108800440104a00280000409020a008800010000000800020420828284000004100010000000000004000400640"
# Pad out the binary from the left if needed (is this right?)
bs = t1.to_s(base=2)
puts "bits: #{bs}\n"
puts "Length of bitstring is : #{bs.length}"
missing = 1000-bs.length # should it be 1000 long?
puts "Missing #{missing} chars; padding with leading 0"
while (missing>0) 
 bs = "0#{bs}"
 missing -= 1
end
puts "Length of bs is now: #{bs.length}"

puts "\n\nBinary:\n "
a= eval "0b"+bf.bitfield.to_s()
puts a.to_s(base=2)
print "\n"+a.to_s+"\n"
i=0
bs.scan(/./u) do |c| 
    print ":" +c 
    bf.bitfield[i] = 1 if c=="1"
    bf.bitfield[i] = 0 if c=="0"
    i+=1
end

puts
puts "Re-Serializing in base 16: "
a= eval "0b"+bf.bitfield.to_s()
puts a.to_s(base=16)
#> > s.unpack("m")                  # decodes s

s = [a.to_s].pack("m")
puts "Base64: #{s}"
#puts "Binary2: "
#a= eval "0b"+bf.bitfield.to_s()
#puts a.to_s(base=2)


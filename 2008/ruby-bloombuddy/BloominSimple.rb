#!/usr/bin/ruby

#        NAME: BloominSimple
#      AUTHOR: Peter Cooper
#     LICENSE: MIT ( http://www.opensource.org/licenses/mit-license.php )
#   COPYRIGHT: (c) 2007 Peter Cooper
# DESCRIPTION: Very basic, pure Ruby Bloom filter. Uses my BitField, pure Ruby
#              bit field library (http://snippets.dzone.com/posts/show/4234).
#              Supports custom hashing (default is 3).
#
require 'benchmark'
require 'bitfield'

class BloominSimple
  attr_reader :bitfield, :hasher
  
  def initialize(bitsize, &block)
    @bitfield = BitField.new(bitsize)
    @size = bitsize
    @hasher = block || lambda do |word|
      word = word.downcase.strip
      [h1 = word.sum, h2 = word.hash, h2 + h1 ** 3]
    end
  end
  
  def add(item)
    @hasher[item].each { |hi| @bitfield[hi % @size] = 1 }
  end
  
  def includes?(item)
    @hasher[item].each { |hi| return false unless @bitfield[hi % @size] == 1 } and true
  end
end


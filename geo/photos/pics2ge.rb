#!/usr/bin/env ruby

require 'rubygems'
require 'json'

pics = `cat f.js`

res = JSON.parse pics


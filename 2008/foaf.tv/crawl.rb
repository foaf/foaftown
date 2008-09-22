#!/usr/bin/ruby

i=1
accountName='modanbri'
page=1
size=50
max=1000
while (true) do
  break if (i>2000)
  url = "http://gdata.youtube.com/feeds/api/users/modanbri/favorites?start-index=#{i}&max-results=#{size}"
  puts "Page: #{page} i=#{i} url=#{url}"
  i=i+50
  
end

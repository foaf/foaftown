# todayTwits.rb @VERSION
#
# Copyright (c) 2008 Libby Miller
# Licensed under the MIT (MIT-LICENSE.txt)

require 'java'
require 'rubygems'
require 'uri'
require 'open-uri'
require 'net/http'
require 'json/pure'

import 'org.h2.Driver' 

module JavaLang
  include_package "java.lang"
end

module JavaSql
  include_package 'java.sql'
end

class TodaysTwits


 def TodaysTwits.foo(text)
       u = "http://twitter.com/statuses/update.json"
       url = URI.parse u
       puts "sending update #{text}"
                  
       req = Net::HTTP::Post.new(url.path)
       req.basic_auth 'username', 'password' # put the real username and pass here
       req.set_form_data({'status'=>text}, ';') 
       res = Net::HTTP.new(url.host, url.port).start {|http|http.request(req) }

       j = nil
       begin
           j = JSON.parse(res.body)
       rescue OpenURI::HTTPError=>e
           case e.to_s
               when /^404/
                   raise 'Not Found'
               when /^304/
                   raise 'No Info'
               when /^error/
                   raise 'Error'
           end
       end

 end

 # Fix up today's date in the format we want
 # Probably a better way!

 begin
  arr = []
  d = Date.today
  da = DateTime.now # this is GMT apparantly 

# Adding 5 mins to current time
# Date, Time, DateTime can all do this I think but googling around 
# this seems the best way 

  da1 = DateTime.now + (5/1440.0) 
  h = da.hour
  m = da.min
  m0 = da.min

  h1 = da1.hour
  m1 = da1.min
  if h < 10
    h = "0#{h}"
  end
  if m < 10
    m = "0#{m}"
  end

  if h1 < 10
    h1 = "0#{h1}"
  end
  if m1 < 10
    m1 = "0#{m1}"
  end

  # t is now, t1 is 5 mins head

  t = "#{h}:#{m}:00"
  t1 = "#{h1}:#{m1}:00"
  puts "date #{d}"
  puts "time is #{t} t1 is #{t1}"
  conn = JavaSql::DriverManager.getConnection("jdbc:h2:tcp://localhost/~/test","sa","");
  stmt = conn.createStatement

  # Get anything now or in the next 5 mins - non-inclusive for 5 mins' time
  # So at 55, things at 00 will have to wait for the next thing
  # but 58 will be caught

  txt = "SELECT * FROM beeb WHERE D = '#{d}' AND T >= '#{t}' AND T < '#{t1}';"
  rs = stmt.executeQuery(txt)
  while (rs.next) do
    #puts "found: #{rs.getString("d")} #{rs.getString("name")}\n"
    txt = rs.getString("name")
    if txt.length > 61 
      txt = txt[0,58]+"..."
    end
    ti = rs.getTime("t")
    tim = 0
    if ti.to_s =~ /(\d\d):(\d\d):(\d\d)/
      tim = $2
    end
    mdiff = tim.to_i - m0

    # Text niceness

    if mdiff > 0
      arr.push("In a few minutes on Radio 4: #{txt} #pid:#{rs.getString("pid")} http://www.bbc.co.uk/programmes/#{rs.getString("pid")}")
    elsif mdiff < 0 #should never happen
      arr.push("Just started on Radio 4: #{txt} #pid:#{rs.getString("pid")} http://www.bbc.co.uk/programmes/#{rs.getString("pid")}")
    else
      arr.push("Starting now on Radio 4: #{txt} #pid:#{rs.getString("pid")} http://www.bbc.co.uk/programmes/#{rs.getString("pid")}")
    end
    puts "#{arr.length} items to send"
  end
  rs.close
  stmt.close
  conn.close()

  # Send the found data to Twitter

  now = 0
  while now < arr.length
    TodaysTwits.foo(arr[now])    
    now += 1
  end

rescue JavaLang::ClassNotFoundException
  puts "ClassNotFoundException"
rescue JavaSql::SQLException
  puts "SQLException"

  end

end




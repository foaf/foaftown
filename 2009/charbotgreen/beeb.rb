# beeb.rb @VERSION
#
# Copyright (c) 2008 Libby Miller 
# Licensed under the MIT (MIT-LICENSE.txt)

require 'rubygems'
require 'net/http'
require 'uri'
require 'open-uri'
require 'json/pure'
require 'java'

import 'org.h2.Driver'

module JavaLang
  include_package "java.lang"
end
  
module JavaSql
  include_package 'java.sql'
end
  


class Twitter

   def Twitter.status()

       u = "http://www.bbc.co.uk/radio4/programmes/schedules/fm/today.json"
       da = DateTime.now - (30/1440.0)
       url = URI.parse u 
       puts "checking for updates #{url}"

       req = Net::HTTP::Get.new(url.path)

       # retrieve the json data
       # should be some error checking here

       res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }

       # Parse the json data

       j = nil
       begin
           j = JSON.parse(res.body)
       rescue OpenURI::HTTPError=>e
           case e.to_s
               when /^404/
                   raise 'Not Found'
               when /^304/
                   raise 'No Info'
           end
       end

       j = j['schedule']['day']['broadcasts']
       puts "found #{j.length} results"

       # Make sure the table is empty

       begin
           conn = JavaSql::DriverManager.getConnection("jdbc:h2:tcp://localhost/~/test","sa",""); 
           stmt1 = conn.createStatement
           sq1 = "DROP table beeb;"
           stmt1.executeUpdate(sq1);
           stmt1.close
       rescue JavaLang::ClassNotFoundException
           stmt1.close
           conn.close()
           puts "ClassNotFoundException"
       rescue JavaSql::SQLException=>e
           stmt1.close
           conn.close()
           puts "[1] SQLException #{e.backtrace}"
       end

       # Create the table

       begin
           conn = JavaSql::DriverManager.getConnection("jdbc:h2:tcp://localhost/~/test","sa",""); 
           stmt2 = conn.createStatement
           sq2 = "CREATE TABLE if not exists beeb(DT TIMESTAMP, PID VARCHAR(8), D DATE, T TIME, NAME VARCHAR(255));" 
           stmt2.executeUpdate(sq2);
           stmt2.close
       rescue JavaLang::ClassNotFoundException
           stmt2.close
           conn.close()
           puts "ClassNotFoundException"
       rescue JavaSql::SQLException=>e
           stmt2.close
           conn.close()
           puts "[2] SQLException #{e.backtrace}"
       end

       # Insert the data

       begin
           conn = JavaSql::DriverManager.getConnection("jdbc:h2:tcp://localhost/~/test","sa",""); 
           stmt = conn.createStatement            
           now = 0
           while now < j.length
              dt = j[now]['start']
              pid = j[now]['programme']['pid']
              txt = j[now]['programme']['display_titles']['title']
              puts "#{now} #{dt} #{txt}"
              if dt!=nil && dt =~ /(.*)T(.*)Z/
                d = $1
                t = $2 
                ds = "#{d} #{t}"
                sql = "INSERT INTO beeb VALUES('#{ds}','#{pid}','#{d}','#{t}',?);"
                pstmt = conn.prepareStatement(sql)
                pstmt.setString(1,txt);
                rs = pstmt.executeUpdate()
              end
              now = now + 1
           end
           stmt.close
           conn.close()
       rescue JavaLang::ClassNotFoundException
           stmt.close
           conn.close()
           puts "ClassNotFoundException"
       rescue JavaSql::SQLException=>e
           stmt.close
           conn.close()
           puts "[0] SQLException"
       end
   end

end


Twitter.status()


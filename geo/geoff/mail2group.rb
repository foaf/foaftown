#!/usr/bin/ruby

# Scans local mbox files for some mailing list.
# Tries to count and summarise poster frequency.
# 
# Dan Brickley <http://danbri.org/>

require 'digest/sha1'
admin = ['bounces@lists.burri.to','geowanking@lists.burri.to']


def mbox2sgapi(mbox)
  mbox= mbox.chomp
#  base ='http://socialgraph.apis.google.com/otherme?pretty=1&q='
  base='http://socialgraph.apis.google.com/lookup?fme=1&pretty=1&sgn=1&q='  # mailto%3Adanbri%40danbri.org'

  #  hbase ='http://socialgraph.apis.google.com/otherme?pretty=1&q=sgn%3A%2F%2Fmboxsha1%2F%3Fpk%3D'
  hbase='http://socialgraph.apis.google.com/lookup?fme=1&pretty=1&sgn=1&q=sgn%3A%2F%2Fmboxsha1%2F%3Fpk%3D'

  hash = Digest::SHA1.hexdigest('mailto:'+mbox)
  return([ hbase+hash, base+mbox])
end  



emails = {}
Dir['data/*.txt'].each { |file|
  if FileTest.size?(file) then
    mbox = File.new(file, "r")
    while(line = mbox.gets)
       next unless (line =~ /From:/)
#      puts "X: "+line

       e = line.scan(/[A-Za-z0-9._]+@[\w.]+/)[0]
       if (e)
          next if admin.member?(e)
#         puts "Email: '#{e}'"
         e = e.downcase
         if (emails[e] == nil) 
           emails[e] = 1
         else
           emails[e] = emails[e]+1
         end
       end

       e = line.scan(/[A-Za-z0-9._]+ at [\w.]+/)[0]
       if (e)
         next if admin.member?(e)
         e = e.downcase
         e.gsub!(/ at /,"@")
#         puts "Semi-hidden Email: '#{e}'"
         if (emails[e] == nil) 
           emails[e] = 1
         else
           emails[e] = emails[e]+1
         end
       end


    end
    mbox.close
  end
}

posters = []
emails.each_pair do |email, count|  
  # puts "Email: #{email} count: #{emails[email]} "
  posters.push([email, count])
end

sorted = posters.sort { |x, y| y[1] <=> x[1] }  # via pair_sort_bm.rb 

sorted.each do |x|
  who=x[0]
  c=x[1]
  puts "#{c}: \t#{who} "

  # TODO: see http://code.google.com/apis/socialgraph/docs/api.html
  # urls = mbox2sgapi(who)
  #  puts "Not-working-yet Lookups: \n  hashed=#{urls[0]} \n  unhashed: #{urls[1]} \n\n"  
end

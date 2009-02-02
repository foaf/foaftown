CharBotGreen Installation Instructions
--------------------------------------

CharBotGreen is a twitter bot written in jruby using 
http://www.bbc.co.uk/radio4/programmes/schedules/fm/today.json
(see http://www.bbc.co.uk/programmes/developers#alternateserialisations)

The author is Libby Miller, http://nicecupoftea.org 
The license is MIT (MIT-License.txt).

There are four easy steps:


1. Installing jruby 
-------------------

# see http://wiki.jruby.org/wiki/Getting_Started#Installing_JRuby

curl -O http://dist.codehaus.org/jruby/jruby-bin-1.1.6RC1.zip
unzip jruby-bin-1.1.6RC1.zip


2. Installing h2
----------------

curl -O http://www.h2database.com/h2-2008-09-26.zip
unzip h2-2008-09-26.zip

nohup java -cp h2/bin/h2.jar org.h2.tools.Server &


3. Installing Json Pure
-----------------------

PATH=$PATH:jruby-1.1.6RC1/bin:h2/bin/h2.jar
export PATH

jruby -S gem install json_pure 


4. Running the ruby files
-------------------------

CLASSPATH=h2/bin/h2.jar
export CLASSPATH

curl -O http://svn.foaf-project.org/foaftown/2009/charbotgreen/beeb.rb
curl -O http://svn.foaf-project.org/foaftown/2009/charbotgreen/todaysTwits.rb

# edit the todaysTwits.rb with the correct username and password

jruby beeb.rb # run once a day between 1am and 5:20am
jruby todaysTwits.rb # run every 5 minutes

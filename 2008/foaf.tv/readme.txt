


see also mashablemusic

http://gdata.youtube.com/schemas/2007/categories.cat

atom schema

http://code.google.com/apis/youtube/developers_guide_protocol.html#Authentication

my profile at youtube
http://gdata.youtube.com/feeds/api/users/modanbri

From which you can determine that I have a certain number of favourited vids:

<gd:feedLink 
rel='http://gdata.youtube.com/schemas/2007#user.favorites' 
href='http://gdata.youtube.com/feeds/api/users/modanbri/favorites' 
countHint='362'/>


...and get a link to the atom for them.


This has different kinds of categorisation.

Tokenized text keywords, in a http://gdata.youtube.com/schemas/2007/keywords.cat 
namespace. This is empty since it would otherwise contain millions of tokens.

also we see categories.cat, eg.
<media:category label="Music"
 scheme="http://gdata.youtube.com/schemas/2007/categories.cat"
	>Music</media:category>



Using XSLT to access this, try:

cd tmp/
svn co http://svn.foaf-project.org/foaftown/2008/foaf.tv/
cd foaf.tv/
xsltproc atom2html.xsl modanbri-favourites.xml > foo.html



 roqet -e 'select * from <file:z.rdf> where { ?x <http://xmlns.com/foaf/0.1/interest_topic> ?y } '  -r json > interests.json.txt


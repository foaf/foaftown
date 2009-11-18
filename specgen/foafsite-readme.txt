TODO before we can use it for real

* get rid of 'validation queries' link by default
* read opts from commandline
* use same css as http://xmlns.com/foaf/spec/
* the subclassof link --- check it works with border terms (subclasses of non foaf stuff)
* domain/range - also check border: 
** fix based_near (how? what do we link to? #term_SpatialThing currently ... how?)







How to use this with FOAF site:

ie. for the real foaf spec

1. set up subdir with relevant symlinks
2. run the script
3. compare output to what we hope for



TellyClub:specgen danbri$ ./specgen5.py foaf-live/ http://xmlns.com/foaf/0.1/ foaf
ok
Printing to  foaf-live/_tmp_spec.html





_tmp_spec.html	doc		foaf-update.txt	index.rdf	style.css	template.html
TellyClub:specgen danbri$ ls  -l foaf-live/
total 392
-rw-r--r--  1 danbri  staff  177151 Sep  8 15:00 _tmp_spec.html
lrwxrwxrwx  1 danbri  staff      59 Nov 14 13:23 doc -> /Users/danbri/working/foaf/trunk/xmlns.com/htdocs/foaf/doc/
-rw-r--r--  1 danbri  staff    2115 Sep  8 15:00 foaf-update.txt
lrwxrwxrwx  1 danbri  staff      69 Nov 14 13:23 index.rdf -> /Users/danbri/working/foaf/trunk/xmlns.com/htdocs/foaf/spec/index.rdf
-rw-r--r--  1 danbri  staff    1127 Sep  8 15:00 style.css
lrwxrwxrwx  1 danbri  staff      72 Nov 14 13:23 template.html -> /Users/danbri/working/foaf/trunk/xmlns.com/htdocs/foaf/0.1/template.html


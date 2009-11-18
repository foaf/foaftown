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



23:16 danbri: libby, what's foo, foo1, foo2, ...?
23:16 danbri:       zz = eg % (term.id,term.uri,"rdfs:Class","Class", sn, term.label, term.comment, term.status,term.status,foo,foo1+foo2+foo3+foo4+foo5, s,term.id, term.id)
23:16 danbri: i'm trying to understand your improvements to specgen
23:16 libby: just bits of text
23:17 libby: looks like foo is in-domian-of
23:18 libby: foo2 is subclass of
23:18 libby: foo3 is has_subclass
23:18 libby: foo4 is isdefinedby
23:19 danbri: in-damian-of?
23:19 libby: foo5 dijointwith
23:19 libby: domain
23:19 libby: foo6 functional prop
23:19 danbri: ok, so not the validation rules?
23:19 danbri: i was trying to figure out which one to comment out
23:19 danbri: that matches             <p style="float: right; font-size: small;">[<a href="#term_%s">#</a>] <!-- %s --> [<a href="#glance">back to top</a>]</p>
23:20 danbri: i left in <!-- %s --> for now, so i didn't have to think too har
23:20 danbri: d

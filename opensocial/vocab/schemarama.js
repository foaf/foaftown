// Generates basic RDF schema for OpenSocial from Javascript API base
//
// do 'svn co http://opensocial-resources.googlecode.com/svn/spec/0.8/opensocial/'
// then
// java -cp /Users/danbri/working/rhino/js.jar org.mozilla.javascript.tools.shell.Main -f 
//     opensocial/opensocial.js -f opensocial/name.js -f opensocial/person.js  -f schemarama.js
//
// Emits RDFa HTML. To validate: http://validator.w3.org/
// and to convert to RDF/XML see http://www.w3.org/2007/08/pyRdfa/
// put "Options MultiViews" in Apache .htaccess to conneg the schema (at least in a basic way)
//
// Author: Dan Brickley <danbri@danbri.org>

function propdiv(p, c, ns) 
{
  // print("<!-- making prop, class, ns: ",p," ; ",c," ; ",ns,"-->");
  return("<div typeof='rdf:Property' id='doc_"+p+"' about='"+ns+p+
  "' property='rdfs:label' content='"+p+"'>"+
  "<a rel='rdfs:domain' resource='"+ns+c+"' href='#doc_"+ p +"'>"+
  "<span>"+p+"</span></a></div>\n");
}

function classdiv(c, ns) 
{
  return("<div typeof='rdfs:Class owl:Class' about='"+ns+c+"'>"+
  "<h1>Class: <span property='rdfs:label'>"+c+"</span></h1>"+
  "<h2>Properties:</h2>");
}

function do_class(c,ns)
{
  print(classdiv(c,ns));
  var myClass;
  try 
    {
      myClass = eval ("opensocial."+c+".Field" );
    } 
  catch(err) {
    print("Caught an exception. "+err); 
  }

  if (!myClass) 
  {
    print("Can't find class: "+c);
  } else 
  {
    for (prop in myClass) { print(propdiv( myClass[prop],c,nsuri)); }
    print("</div>");
  }
}

/* ---------------------------------------------------------------------------------------------- */

// Generate an RDFa HTML doc:

print ('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">\
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"        xmlns:foaf="http://xmlns.com/foaf/0.1/"\
	xmlns:owl="http://www.w3.org/2002/07/owl#" \
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" \
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
	xmlns:dc="http://purl.org/dc/elements/1.1/">');

nsuri = 'http://danbri.org/2008/opensource/_latest#'

print("<head><title>Experimental ontology from OpenSocial javascript</title></head>");
print("<body>");
print("<div typeof='owl:Ontology'>");
classes=['Person','Name','Email','Phone','Url','Organization','Address','Message','Activity','MediaItem','Activity'];
for (c in classes) { do_class(classes[c],nsuri);}
print("</div>\n</body>\n</html>");


/* Enums: opensocial.Enum.Smoker, opensocial.Enum.Drinker, 
opensocial.Enum.Gender, opensocial.Enum.LookingFor, opensocial.Enum.Presence 

 irc help: See http://chatlogs.planetrdf.com/swig/2008-06-26#T11-53-16
 similar rdfs: http://sw.joanneum.at/scovo/schema.html
 issues: xmlliteral */

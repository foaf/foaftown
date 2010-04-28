var loaded = false;
var isHashUri = function(uri) {
    return uri.indexOf("#") != -1;
};

function shortLink(url){
  url = url.replace("http://opengraphprotocol.org/schema/", "og:");
  url = url.replace("http://xmlns.com/foaf/0.1/", "foaf:");
  url = url.replace("http://www.w3.org/2000/01/rdf-schema#", "rdfs:");
  url = url.replace("http://www.w3.org/2002/07/owl#", "owl:");
  url = url.replace("http://purl.org/dc/terms/", "dcterms:");
  url = url.replace("http://dbpedia.org/resource/", "dbpedia:");
  url = url.replace("http://purl.org/vocab/bio/0.1/", "bio:");
  url = url.replace("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf:");
  url = url.replace("http://www.w3.org/2000/01/rdf-schema#", "rdfs:");
  url = url.replace("http://www.w3.org/2004/02/skos/core#", "skos:");
  url = url.replace("http://www.w3.org/2001/XMLSchema#", "xsd:");
  url = url.replace("http://rdfs.org/sioc/ns#", "sioc:");
  url = url.replace("http://purl.org/rss/1.0/", "rss1:");
  url = url.replace("http://usefulinc.com/ns/doap#", "doap:");
  url = url.replace("http://www.w3.org/2007/05/powder#", "powder:");


 
  return url;
}

jQuery(function ($) {
    $('#ganchor').click(function() {
	if (loaded) {
	    return true;
	} else {
	    loaded = true;
	}
	var rdfjson = $("html").rdf().databank.dump();
	var width = 800;
	var height = 500;
	var g = new Graph();
	
	$.each(rdfjson, function (subj, predvals) { 	
	    // jQuery-ese idiom for "continue"
	    // we're skipping assertions about the page itself
	    if (!isHashUri(subj))
		return true;
//	    g.addNode( shortLink ( subj) );
 	    g.addNode( shortLink(subj) , {  label: shortLink(subj), getShape : function(r,x,y) { return r.rect(x-30, y-13, 62, 33).attr({"fill": "#f00", "stroke-width": 2}); } } );

	    $.each(predvals, function (pred, objvals) {

		var  linkType = shortLink(pred);   
   	        g.addNode( pred , {  label: linkType, getShape : function(r,x,y) { return r.circle(x,y,8 ).attr({"fill": "#f00", "stroke-width": 1}); } } );
//   	        g.addNode( pred , {  label: linkType, getShape : function(r,x,y) { return r.g.arrow(x,y,8).attr({"fill": "#f00", "stroke-width": 1}); } } );

		g.addEdge( shortLink(subj) , pred, { directed : true });	

		$.each(objvals, function (k, obj) {

		    //g.addNode( shortLink( obj.value ) );
       	            g.addNode( shortLink(obj.value) , {  label: shortLink(obj.value), getShape : function(r,x,y) { 
				return r.rect(x,y, 40, 25, 10).attr({"fill": "000", "stroke-width": 2})
; } 
		    } );

		    g.addEdge(pred,  shortLink ( obj.value ) , { directed : true });

		    /*
		    var triple = {
		        subject: subj,
		        predicate: pred,
		        object: obj.value, 
		        objtype: obj.type
		    };
                    */
		});
	    });
	});

	var layouter = new Graph.Layout.Spring(g);
	layouter.layout();

	var renderer = new Graph.Renderer.Raphael("graph", g, width, height);
	renderer.draw();

    });
});

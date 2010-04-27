var loaded = false;
var isHashUri = function(uri) {
    return uri.indexOf("#") != -1;
};

function shortLink(url){
  url = url.replace("http://opengraphprotocol.org/schema/", "og:");
  url = url.replace("http://xmlns.com/foaf/0.1/", "foaf:");
  url = url.replace("http://www.w3.org/2000/01/rdf-schema#", "rdfs:");
  url = url.replace("http://www.w3.org/2002/07/owl#", "owl:");

//  url = url.replace("", "x:");
  url = url.replace("http://purl.org/dc/terms/", "dcterms:");
  url = url.replace("http://dbpedia.org/resource/", "dbpedia:");
  url = url.replace("http://purl.org/vocab/bio/0.1/", "bio:");

//  url = url.replace("", "x:");
  url = url.replace("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf:");
  //alert ("Short link:"+url);
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
	    g.addNode(subj);

//            g.addNode( subj, {  label: subj, getShape : function(r,x,y) { return r.rect(x-30, y-13, 62, 33).attr({"fill": "#f00", "stroke-width": 4}); } } );

	    $.each(predvals, function (pred, objvals) {

		var  linkType = shortLink(pred);   
   	        g.addNode( pred , {  label: linkType, getShape : function(r,x,y) { return r.circle(x,y,8 ).attr({"fill": "#f00", "stroke-width": 1}); } } );

		g.addEdge(subj, pred, { directed : true });	

		$.each(objvals, function (k, obj) {
		    g.addNode(obj.value);
		    g.addEdge(pred, obj.value, { directed : true });

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

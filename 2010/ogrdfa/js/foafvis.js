var loaded = false;
var isHashUri = function(uri) {
    return uri.indexOf("#") != -1;
};

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
//		alert("triple: "+subj+ predvals);
//    	    g.addNode( { label: subj, getShape : function(r,x,y) { return r.rect(x-30, y-13, 62, 33).attr({"fill": "#f00", "stroke-width": 2}); } } );
	    $.each(predvals, function (pred, objvals) {
		g.addNode(pred) ;
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

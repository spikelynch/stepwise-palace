
var RADIUS = 20;

var CONSTRAINT = {
    'A' : 0,
    'B' : 80,
    'C' : 160,
    'D' : 240,
    'E' : 320
};

var TOLERANCE = 0.1;

var constrain = true;

var path = [];

var visited = {};

var head;



function highlight_head(d, on) {
    d3.select("#C" + d.id).classed("head", on);
    for ( var i = 0; i < d.links.length; i++ ) {
	var l = d.links[i];
	if( ! visited[l.target] ) {
	    d3.select("#L" + l.link).classed("next", on);
	    d3.select("#C" + l.target).classed("next", on);
	}
    }
}

function highlight_path(oh, nh) {
    d3.select("#C" + oh.id).classed("head", false);
    d3.select("#C" + oh.id).classed("path", true);
    for ( var i = 0; i < oh.links.length; i++ ) {
	var l = oh.links[i];
	d3.select("#L" + l.link).classed("next", false);
 	d3.select("#C" + l.target).classed("next", false);
	console.log("Path link " + oh.id + " to " + l.target);
	if( l.target == nh.id ) {
	    console.log("Classing link path " + l.link);
	    d3.select("#L" + l.link).classed("path", true);
	}
    }
}



function click_node(d) {
    console.log("Clicked node " + d.id);
    if( visited[d.id] ) {
	console.log("Node " + d.id + " is in the path");
	if( d.id == head.id ) {
	    console.log("This is the head node - removing");
	    path.pop();
	    highlight_head(d, false);
	    if( path.length ) {
		head = path[path.length - 1];
		highlight_head(head, true);
	    } else {
		head = null;
	    }
	    delete visited[d.id];
	} else {
	    console.log("Clicked a path node not the head - nop");
	}
    } else {
	if( head ) {
	    console.log("Head is " + head.id);
	    for( i = 0; i < head.links.length; i++ ) {
		console.log("Link " + i + ": " + head.links[i].target);
		if( head.links[i].target == d.id ) {
		    console.log(d.id + " is next to head");
		    highlight_path(head, d);
		    highlight_head(d, true);
		    path.push(d);
		    visited[d.id] = true;
		    head = d;
		    break;
		}
	    }
	    if( head.id != d.id ) {
		console.log("Node " +  d.id + " is not next");
	    } else {
		console.log("Path extended to " + d.id);
	    }
	} else {
	    // if head's not defined, any node can start the
	    // path
	    highlight_head(d, true);
	    path.push(d);
	    visited[d.id] = true;
	    head = d;
	    console.log("Started path");
	}
    }
}
	
	





function draw_force_graph(elt, w, h) {       

    var cx = 0.5 * w;
    var cy = 0.5 * h;

    var fill = d3.scale.category10();


    fg_vis = d3.select(elt).append("svg:svg")
	.attr("width", w)
	.attr("height", h);


    force = d3.layout.force()
	.nodes(nodes)
	.links(links)
	.size([w, h])
	.charge(-1000)
	.gravity(0.5);

    links = fg_vis.selectAll("link")
	.data(links)
	.enter().append("svg:line")
	.attr("class", function(d) { return d.class })
	.attr("id", function(d) { return "L" + d.id })
	.attr("x1", function(d) { return d.source.x; })
	.attr("y1", function(d) { return d.source.y; })
	.attr("x2", function(d) { return d.target.x; })
	.attr("y2", function(d) { return d.target.y; })

    nodes = fg_vis.selectAll("g.node")
	.data(nodes)
	.enter().append("svg:g")
	.attr("class", "node")
	.on("click", function(d) {
	    click_node(d);
	    d3.event.stopPropagation();
	})
	.call(force.drag);
    
    nodes.append("svg:circle")
	.attr("class", function(d) { return d.class })
	.attr("id", function(d) { return "C" + d.id })
	.attr("cx", 0)
	.attr("cy", 0)
	.attr("r", RADIUS );
    
    nodes.append("svg:text")
	.attr("text-anchor", "middle")
	.attr("class", "label")
	.attr("dx", 0)
	.attr("dy", ".35em")
	.text(function(d) { return d.name });


    fg_vis.style("opacity", 1e-6)
	.transition()
	.duration(1000)
	.style("opacity", 1);



    force.on("tick", function(e) {


	
	nodes.attr("transform", function(d) {
	    var r = CONSTRAINT[d.class];
	    
	    if( constrain ) {
		var x = d.x - cx;
		var y = d.y - cy;
		var r0 = Math.sqrt(x * x + y * y);
		
		if( r - r0 > TOLERANCE || r - r0 < -TOLERANCE ) {
		    if( r0 ) {
			x = x * r / r0;
			y = y * r / r0;
		    } else {
			x = r;
			y = 0;
		    }
		    d.x = cx + x;
		    d.y = cy + y
		}
	    }
	    return "translate(" + d.x + "," + d.y + ")"
	});
	links.attr("x1", function(d) { return d.source.x; })
	    .attr("y1", function(d) { return d.source.y; })
	    .attr("x2", function(d) { return d.target.x; })
	    .attr("y2", function(d) { return d.target.y; });

    });

    d3.select("#ctrl_constrain").on("click", function(e) {
	constrain = this.checked;
	force.start();
    });



    force.start();
}



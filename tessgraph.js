
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


function free_neighbours(d) {
    var nexts = [];
    for( var i = 0; i < d.links.length; i++ ) {
	if( !visited{d.links[i].target} ) {
	    nexts.push(d.links[i].target);
	}
    }
    return nexts;
}


function find_randumb(d) {
    var nexts = free_neighbours(d);
    if( nexts.length ) {
	var choice = Math.floor(Math.random() * nexts.length);
	
    





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



function highlight_path(oh, nh, on) {
    d3.select("#C" + oh.id).classed("head", !on);
    d3.select("#C" + oh.id).classed("path", on);
    for ( var i = 0; i < oh.links.length; i++ ) {
	var l = oh.links[i];
	if( on ) {
	    d3.select("#L" + l.link).classed("next", false);
 	    d3.select("#C" + l.target).classed("next", false);
	}
	if( l.target == nh.id ) {
	    console.log("Classing link path " + l.link);
	    d3.select("#L" + l.link).classed("path", on);
	}
    }
}


function path_text_push(d) {
    var str = d.class + " " + d.name;
    d3.select("#path").append("div").attr("class", d.class).text(str);
}

function path_text_pop(d) {
    var elt = document.getElementById("path");
    var last = elt.lastChild;
    if( last ) {
	elt.removeChild(last);
    }
}



function click_node_old(d) {
    console.log("Clicked node " + d.id);
    if( visited[d.id] ) {
	console.log("Node " + d.id + " is in the path");
	if( d.id == head.id ) {
	    console.log("This is the head node - removing");
	    path.pop();
	    path_text_pop();
	    highlight_head(d, false);
	    if( path.length ) {
		highlight_path(path[path.length - 1], d, false);
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
		    highlight_path(head, d, true);
		    highlight_head(d, true);
		    path.push(d);
		    visited[d.id] = true;
		    head = d;
		    path_text_push(head);
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
	    path_text_push(head);
	    console.log("Started path");
	}
    }
}


function add_to_path(d) {
    if( head ) {
	if( d.id != head.id ) {
	    return;
	}
	for( i = 0; i < head.links.length; i++ ) {
	    if( head.links[i].target == d.id ) {
		highlight_path(head, d, true);
		highlight_head(d, true);
		path.push(d);
		visited[d.id] = true;
		head = d;
		path_text_push(head);
		break;
	    }
	}
    } else {
	highlight_head(d, true);
	path.push(d);
	visited[d.id] = true;
	head = d;
	path_text_push(head);
    }
}


function remove_from_path(d) {
    if( ! head || d.id != head.id ) {
	return;
    }
    path.pop();
    path_text_pop();
    highlight_head(d, false);
    if( path.length ) {
	highlight_path(path[path.length - 1], d, false);
	head = path[path.length - 1];
	highlight_head(head, true);
    } else {
	head = null;
    }
    delete visited[d.id];
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

    d3.select("#ctrl_find").on("click", function(e) {
	delete_path();
	find_path();
    });


    force.start();
}



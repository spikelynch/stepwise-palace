
var RADIUS = 20;



var CONSTRAIN_BULLSEYE = {
    'A' : 0,
    'B' : 80,
    'C' : 160,
    'D' : 240,
    'E' : 320
};

var CONSTRAIN_LINES_X = {
    'A' : 100,
    'B' : 250,
    'C' : 400,
    'D' : 550,
    'E' : 700
};

var CONSTRAIN_LINES_Y = {
    'B' : 90,
    'C' : 30,
    'D' : 22,
    'E' : 45
};

var TOLERANCE = 0.1;
var NUDGE = 0.2;

var constrain = 'none';
var mode = 'path';

var path = [];

var visited = {};

var taken = {};


var nopattern = 1;

var head;

var cx, cy;


function constrain_bullseye(d) {
    var x = d.x - cx;
    var y = d.y - cy;
    var r0 = Math.sqrt(x * x + y * y);
    var r = CONSTRAIN_BULLSEYE[d.class];
    
    if( Math.abs(r - r0) > TOLERANCE ) {
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


function constrain_lines(d) {

    var x0 = CONSTRAIN_LINES_X[d.class];
    
    if( Math.abs(d.x - x0) > TOLERANCE ) {
	d.x = x0;
    }
    if( d.class != 'A' ) {
	var y0 = CONSTRAIN_LINES_Y[d.class] * d.classi  + 40;
	if( Math.abs(d.y - y0) > TOLERANCE ) {
	    d.y += NUDGE * ( y0 - d.y );
	}
    }

}



function intrand(n) {
    return Math.floor(Math.random() * n);
}


x
function free_neighbours(d) {
    var nexts = [];
    for( var i = 0; i < d.links.length; i++ ) {
	var t = d.links[i].target;
	if( !visited[t] ) {
	    nexts.push(t);
	}
    }
    return nexts;
}

function id_to_node(id) {
    var nid = "#N" + id;
    var node = null;
    d3.select(nid).each(function(d1) { node = d1 } );
    return node;
}


function find_randumb(d) {
    add_to_path(d);
    var nexts = free_neighbours(d);
    if( nexts.length ) {
	var n = intrand(nexts.length);
	var node = id_to_node(nexts[n]);
	return find_randumb(node);
    } else {
	console.log("Dead end.");
    }
}






function clear_path() {
    while( head ) {
	remove_from_path(head);
    }
}



function highlight_head(d, on) {
    d3.select("#C" + d.id).classed("head", on);
    for ( var i = 0; i < d.links.length; i++ ) {
	var l = d.links[i];
	if( ! visited[l.target] ) {
	    var n = id_to_node(l.target);
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


function add_node_to_path(d) {
    if( visited[d.id] ) {
	if( head && d.id == head.id ) {
	    remove_from_path(d);
	}
    } else {
	add_to_path(d);
    }
}




function add_to_path(d) {
    if( head ) {
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

    cx = 0.5 * w;
    cy = 0.5 * h;

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
	.attr("id", function(d) { return "N" + d.id }) 
	.on("click", function(d) {
	    if( mode == 'path' ) {
		add_node_to_path(d);
	    } else {
		partition(d);
	    }
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
	.attr("title", function(d) { return d.name })
	.text(function(d) { return d.label });


    fg_vis.style("opacity", 1e-6)
	.transition()
	.duration(1000)
	.style("opacity", 1);

    var constraints = {
	none: function(d) {},
	rings: constrain_bullseye,
	lines: constrain_lines
    };

    force.on("tick", function(e) {
	nodes.attr("transform", function(d) {
	    constraints[constrain](d);
	    return "translate(" + d.x + "," + d.y + ")"
	});
	links.attr("x1", function(d) { return d.source.x; })
	    .attr("y1", function(d) { return d.source.y; })
	    .attr("x2", function(d) { return d.target.x; })
	    .attr("y2", function(d) { return d.target.y; });

    });

    d3.select("#ctrl_constrain").on("change", function(e) {
	constrain = this.value;
	force.start();
    });

    d3.select("#ctrl_mode").on("change", function(e) {
	mode = this.value;
	clear_path();
	force.start();
    });

    d3.select("#ctrl_clear").on("click", function(e) {
	clear_path();
    });

    d3.select("#ctrl_find").on("click", function(e) {
	clear_path();
	var anode = id_to_node(40);
	find_randumb(anode);
    });


    force.start();
}



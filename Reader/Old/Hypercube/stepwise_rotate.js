
// Hypercube rotation

var rot90 = [ [ 0, -1 ], [ 1, 0 ] ];
var rot270 = [ [ 0, 1 ], [ -1, 0 ] ];

var WIDTH = 1200;
var HEIGHT = 600;

var CX = WIDTH / 2;
var CY = HEIGHT / 2;

var SIZE = 120;
var XSPACE = 140;
var WXSPACE = 3 * XSPACE + 20;
var WYSPACE = XSPACE;
var WZSPACE = 100;
var SCREEN = 400;
var ZSPACE = XSPACE;
var OFFSET = SIZE / 2;

var LEADING = SIZE / 10;
var TEXT_OFFSET = LEADING + 1;

var ROTATE_TIME = 2000;

function distance(z) {
    return ;
}



function room_position(coords) {
    var w = wfact(coords[3]);
    var zfact = SCREEN / (SCREEN - coords[2] * ZSPACE + w[2]);
    var x = CX + zfact * ( XSPACE * coords[0] + w[0] - OFFSET);
    var y = CY + zfact * ( XSPACE * coords[1] + w[1] - OFFSET );
    
    return "translate(" + x + ", " + y + ") scale(" + zfact + ")";
}

// wfacts returns a [ x, y, z ] based on the point's w
// coordinate

function wfact(w) {
    var x = WXSPACE * w;
    var y = WYSPACE * w;
    var z = 0;
    if( w != 0 ) {
        z = WZSPACE;
    }
    return [ x, y, z ];
}


function room_opacity(room) {
    if( room.coords[2] == 1 && room.coords[3] == 0 ) {
        return .75;
    } else {
        return 0.2;
    }
}


function hypercube(elt) {
    var svg = d3.select(elt).append("svg:svg")
        .attr("width", WIDTH)
	    .attr("height", HEIGHT);

    nodes = svg.selectAll("g")
    	.data(rooms)
    	.enter()
    	.append("g")
        .attr("transform", function(d) { 
            var t = room_position(d.coords);
            console.log(t);
            return t;
        } )
        .attr("opacity", room_opacity);

    nodes.append("rect")
        .attr("class", function(d) { return "cell" + d.coords[2] } )
        .attr("width", SIZE)
        .attr("height", SIZE);
   
    nodes.each(add_stanza);
}


function add_stanza(d, i) {

    var lines = stanzas[d.name];

    for( l = 0; l < lines.length; l++ ) {
        d3.select(this).append("text")
	        .attr("text-anchor", "start")
	        .attr("class", "poem")
	        .attr("dx", 0)
	        .attr("dy", TEXT_OFFSET + l * LEADING)
            .text(lines[l]);
    }
}


function rotate_render(c1, c2) {
    plane_rotate(c1, c2, 1);
}


// rotate_coords - rotate the room coordinates before
// transitioning the shapes

function plane_rotate(c1, c2, dir) {
    var m;

    if( dir > 0 ) {
        m = rot90;
    } else {
        m = rot270;
    }
    
    nodes.transition()
        .duration(1000)
        .attr("transform", function (d) {
            var nc = rotate_point(d.coords, c1, c2, m);
            d.coords = nc;
            return room_position(nc);
        })
        .attr("opacity", room_opacity);
}


function rotate_point(p1, c1, c2, m) {
    var x = p1[c1];
    var y = p1[c2];
    var x1 = m[0][0] * x + m[0][1] * y;
    var y1 = m[1][0] * x + m[1][1] * y;
    var p2 = p1;
    p2[c1] = x1;
    p2[c2] = y1;
    return p2;
}


// code to view a 9-stanza slice of SP.

// render(cx, cy, cz, cw, w, z)
//
// First four arguments are the two axes to use for the table
// rendering (cx and cy) and the two coords to use for depth1 and
// depth2.  w and z are the two depth values.

var cx = 0;
var cy = 1;
var cz = 2;
var cw = 3;

var z = 1;
var w = 1;

var rot90 = [ [ 0, -1 ], [ 1, 0 ] ];
var rot270 = [ [ 0, 1 ], [ -1, 0 ] ];


function render(set_cx, set_cy, set_cz, set_cw, set_z, set_w) {
    cx = set_cx;
    cy = set_cy;
    cz = set_cz;
    cw = set_cw;
    z = set_z;
    w = set_w;
    for ( var y = 0; y < 3; y++ ) {
        for ( var x = 0; x < 3; x++ ) {
            var f = cell(x, y);
            var html = stanzas[f].join('<br />');
            var r = y + 1;
            var c = x + 1;
            var id = '#r' + y + 'c' + x;
            $(id).html(html);
        }
    }
    $("#note").text('[' + cx + ', ' + cy + ', ' + cz + ', ' + cw + '] - ' + z + ', ' + w);
}


function rotate_render(c1, c2) {
    plane_rotate(c1, c2, 1);
    render_slice(1, 1);
}
 

function render_slice(z, w) {
    var slice = pick_slice(z, w);
    console.log(slice);
    for ( var y = 0; y < 3; y++ ) {
        for ( var x = 0; x < 3; x++ ) {
            var id = 'r' + y + 'c' + x;
            var f = slice[id];
            if( f ) {
                var html = stanzas[f].join('<br />');
                $('#' + id).html(html);
            } else {
                $('#' + id).text(id + '???');
            }
        }
    }
}
 

    



function cell(x, y) {
    var cc = [];
    cc[cx] = x;
    cc[cy] = y;
    cc[cw] = w;
    cc[cz] = z;
    var key = cc.join('');
    return coords[key];
}


function random_slice(e) {
    var coords = permute4();
    var sl1 = randint(3);
    var sl2 = randint(3);
    console.log(coords);
    console.log(sl1 + ' ' + sl2);
    render(coords[0], coords[1], coords[2], coords[3], sl1, sl2);
}

    



function permute4() {
    var c = [ 0, 1, 2, 3 ];
    var p = [];
    while( c.length ) {
        p.push(c.splice(randint(c.length), 1));
    }
    return p;
}

function randint(n) {
    return Math.floor(Math.random() * n);
}



function plane_rotate(c1, c2, dir) {
    var m;

    if( dir > 0 ) {
        m = rot90;
    } else {
        m = rot270;
    }

    for ( var k in coords ) {
        var x = coords[k][c1];
        var y = coords[k][c2];
        var x1 = m[0][0] * x + m[0][1] * y;
        var y1 = m[1][0] * x + m[1][1] * y;
        coords[k][c1] = x1;
        coords[k][c2] = y1;
    }
    
}


function pick_slice(z, w) {
    var slice = {};
    for ( var k in coords ) {
        var c = coords[k];
        if( c[2] == z && c[3] == w ) {
            var x = c[0] + 1;
            var y = c[1] + 1;
            var t = 'r' + x + 'c' + y;
            slice[t] = k;
        }
    }
    return slice;
}

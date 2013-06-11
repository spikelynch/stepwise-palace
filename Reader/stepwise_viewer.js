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

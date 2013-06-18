#!/usr/bin/perl


use strict;


sub rch {
    return chr(65 + int(rand() * 26));
}




sub strings_r {
    my ( $depth ) = @_;

    if( !$depth ) {
	return rch();
    }

    my $x = '';
    
    my $t = "--" x $depth;
    for ( 0, 1, 2 ) {
	$x .= $t . strings_r($depth - 1) . "\n";
    }

    return $x;
}


print strings_r(4);

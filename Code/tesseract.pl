#!/usr/bin/perl

use strict;

use Data::Dumper;

my $tess = [];

my @path = naive($tess, [ 1, 1, 1, 1 ] );

print Dumper(\@path) . "\n\n";

print "Path is " . scalar(@path) . " cells long\n";




# naive - Markov path which gives up if no escape

sub naive {
    my ( $tess, $coords ) = @_;

    $tess->[$coords->[0]][$coords->[1]][$coords->[2]][$coords->[3]] = 1;

    my $exits = free_neighbours($tess, $coords);

    if( my $n = scalar @$exits ) {
	my $r = int(rand($n));
	my $next = $exits->[$r];
	print Dumper({ next => $next});
	return ( $coords, naive($tess, $next) );
    } else {
	return ( $coords );
    }
}

sub free_neighbours {
    my ( $tess, $coords ) = @_;

    my $free = [];

    for my $i ( 0..3 ) {
	for my $v ( range($coords->[$i]) ) {
	    my $t = 0;
	    my @next = @$coords;
	    $next[$i] = $v;
	    if( !$tess->[$next[0]][$next[1]][$next[2]][$next[3]] ) {
		push @$free, \@next;
	    }
	}
    }

    return $free;
}

sub range {
    my ( $c ) = @_;

    my @r = ();

    for my $i ( -1, 0, 1 ) {
	if( $c + $i > -2 && $c + $i < 2 ) {
	    push @r, $c + $i;
	}
    }

    return @r;
}

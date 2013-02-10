#!/usr/bin/perl

use strict;
use JSON;


my $nodes = [];
my $nodeindex = {};
my $links = [];

my $i = 0;

for my $x ( -1 .. 1 ) {
    for my $y ( -1 .. 1 ) {
	for my $z ( -1 .. 1 ) {
	    for my $w ( -1 .. 1 ) {
		my $name = name($x, $y, $z, $w);
		my $node = {
		    name => $name,
		    links => [ links($x, $y, $z, $w) ],
		    id => $i,
		    class => class($x, $y, $z, $w)
		};
		push @$nodes, $node;
		$nodeindex->{$name} = $i;
		$i++;
	    }
	}
    }
}

my $linkback = {};
my $link_id = 0;

for my $node ( @$nodes ) {
    my @nlinks = ();
    for my $link ( @{$node->{links}} ) {
	my $linkprint = join('-', sort ( $node->{name}, $link ));
	my $source = $nodeindex->{$node->{name}};
	my $target = $nodeindex->{$link};
	if( my $lb = $linkback->{$linkprint} ) {
	    # link has been created, but need to find its ID to 
	    # add it to the node's outgoing links.
	    push @nlinks, {
		link => $lb,
		target => $target
	    };
	} else {
	    my $link = {
		id => $link_id,
		source => $source,
		target => $target
	    };
	    push @$links, $link;
	    push @nlinks, {
		link => $link_id,
		target => $target
	    };
	    $linkback->{$linkprint} = $link_id;
	    $link_id++;
	}
    }
    delete $node->{links};
    $node->{links} = \@nlinks;
}



my $js = JSON->new();

my $nodes_js = $js->pretty->encode($nodes);

print "var nodes = $nodes_js;\n\n";

my $links_js = $js->pretty->encode($links);

print $links_js;
print "var links = $links_js;\n\n";




sub links { 
    my @coords = @_;

    my @links = ();
    for my $i ( 0..3 ) {
	for my $c ( -1, 1 ) {
	    my @n = @coords;
	    $n[$i] += $c;
	    if( $n[$i] > -2 && $n[$i] < 2 ) {
		push @links, name(@n);
	    }
	}
    }
    return @links;
}


sub name {
    return join(' ', @_);
}				    
		   

sub class {
    my ( $x, $y, $z, $w ) = @_;

    my $zeroes = 0;
    for my $c ( $x, $y, $z, $w ) {
	if( !$c ) {
	    $zeroes++;
	}
    }
    my @classes = qw(E D C B A);

    return $classes[$zeroes];

}

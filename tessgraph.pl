#!/usr/bin/perl

use strict;
use JSON;
use Data::Dumper;


my $PRINT_JSON = './force_graph_data.js';

my $PRINT_MAPS = './maps.';


my $nodes = [];
my $nodeindex = {};
my $alllinks = {};
my $links = [];

my $i = 0;
my $start = undef;

build_nodes();

if( $PRINT_JSON ) {

    my $js = JSON->new();

    open(JSONF, ">$PRINT_JSON") || die("$!");

    my $nodes_js = $js->pretty->encode($nodes);

    print JSONF "var nodes = $nodes_js;\n\n";

    my $links_js = $js->pretty->encode($links);

    print JSONF "var links = $links_js;\n\n";
    close(JSONF);
}

if( $PRINT_MAPS ) {
    
    my $maps = {
	from_b => maps("BCDE"),
	from_e => maps("EBCD"),
	c_through => maps("CDEDC")
    };

    for my $label ( keys %$maps ) {
	open(MAPSF, ">$PRINT_MAPS${label}.txt") || die($!);
	print MAPSF "$label\n\n$maps->{$label}\n";
	close MAPSF;
    }

}


sub build_nodes {
    my $counts = {};
    for my $x ( -1 .. 1 ) {
	for my $y ( -1 .. 1 ) {
	    for my $z ( -1 .. 1 ) {
		for my $w ( -1 .. 1 ) {
		    my $name = name($x, $y, $z, $w);
		    my $class = class($x, $y, $z, $w);
		    $counts->{$class}++;
		    my $node = {
			name => $name,
			links => [ links($x, $y, $z, $w) ],
			id => $i,
			class => $class,
			classi => $counts->{$class},
			label => $class . $counts->{$class}
		    };
		    push @$nodes, $node;
		    $nodeindex->{$name} = $i;
		    if( !$x && !$y && !$z && !$w ) {
			$start = $i;
		    }
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
	    $alllinks->{$source}{$target} = 1;
	}
	delete $node->{links};
	$node->{links} = \@nlinks;
    }
}



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
#    return join(' ', @_);
    return sprintf("% 2d % 2d % 2d % 2d", @_);

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


# Recursive print of nodes by class following a string pattern
# (for eg CDEDC) with no self-intersection


sub maps {
    my ( $pattern ) = @_;

    my @start = ();

    for my $node ( @$nodes ) {
	if( $node->{class} eq substr($pattern, 0, 1) ) {
	    push @start, $node;
	}
    }

    my $map = '';

    for my $node ( @start ) {
	$map .= map_r($node, substr($pattern, 1)) . "\n---\n";
    }

    return $map;
}







sub map_r {
    my ( $node, $pattern, @visited ) = @_;
    push @visited, $node->{label};

    my $nextc = substr($pattern, 0, 1);

    if( !$nextc ) {
	return join(' ', @visited) . "\n";
    }

    my @next = ();
    my %vhash = map { $_ => 1 } @visited;

    for my $link_id ( sort keys %{$alllinks->{$node->{id}}} ) {
	my $target = $nodes->[$link_id];
	if( $target->{class} eq $nextc && !$vhash{$target->{label}}  ) {
	    push @next, $target;
	}
    }
    if( !@next ) {
	return "<-- exhausted\n";
    }
    my $tab = "    " x scalar(@visited);
    my $map = '';
    for my $target ( sort { $a->{classi} <=> $b->{classi} } @next ) {
	$map .= map_r($target, substr($pattern, 1), @visited);
    }

    return $map;

}



sub next_class {
    my ( $class, $next ) = @_;

    my $nclass = chr(ord($class) + $next);
    if( $nclass =~ /^[B-E]$/ ) {
	return $nclass;
    } else {
	return undef;
    }
}

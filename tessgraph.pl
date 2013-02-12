#!/usr/bin/perl

use strict;
use JSON;
use Data::Dumper;

my $patstr = "A" . "BCDEDCDEDC" x 8;

my $PRINT_JSON = 0;
my $SEARCH = 1;
my $SEARCH_BACKTRACK = 1;


my $MAX_BACKTRACK = 1000;

my @pat = split(//, $patstr);

my $nodes = [];
my $nodeindex = {};
my $links = [];

my $i = 0;
my $start = undef;

build_nodes();

if( $PRINT_JSON ) {

    my $js = JSON->new();

    my $nodes_js = $js->pretty->encode($nodes);

    print "var nodes = $nodes_js;\n\n";

    my $links_js = $js->pretty->encode($links);

    print $links_js;
    print "var links = $links_js;\n\n";
    
}

if( $SEARCH ) {
    for ( 1 .. $SEARCH ) {
	my $path = search(start => $start);
	print "Length = " . scalar(@$path) . "\n";
	print "Path   = " . join(' ', map { $_->{id} } @$path) . "\n";
	if( @$path == 81 ) {
	    exit;
	}
    }
}


sub neighbours { 
    my ( $node, $class ) = @_;

    my $nexts = [];

    #print "From $node->{id} next class $class\n";

    LINK: for my $link ( @{$node->{links}} ) {
	my $next = $nodes->[$link->{target}];
	next LINK if $next->{visited};
	next LINK if $next->{class} ne $class;
	next LINK if $node->{path_taken}{$link->{target}};
	push @$nexts, $next;
    }
    return $nexts;
}


sub search {
    my %params = @_;

    my $start = $params{start};

    my $path = [];

    for my $node ( @$nodes ) {
	delete $node->{visited};
	delete $node->{path_taken};
    }

    my $head = $nodes->[$start];

    my $searching = 1;
    my $i = 0;
    my $n = $MAX_BACKTRACK;

    while( $searching && @$path < 81 ) {
	my $nexts = neighbours($head, $pat[$i + 1]);
	if( @$nexts ) {
	    my $next = pick(@$nexts);
	    push @$path, $head;
	    $head->{visited} = 1;
	    $head->{path_taken}{$next->{id}} = 1;
	    $head = $next;
	    $i++;
	} else {
	    if( $SEARCH_BACKTRACK ) {
		print "Backing up:";
	      BACKTRACK: while( @$path ) {
		  my $ohead = pop @$path;
		  print " $ohead->{id}";
		  $i--;
		  if( @$path ) {
		      my $l = scalar(@$path);
		      $head = $path->[$l - 1];
		      my $nexts = neighbours($head, $pat[$i]);
		      if( @$nexts ) {
			  last BACKTRACK;
		      }
		      $head->{path_taken} = {};
		  }
	      }
		print "\n";
		$n--;
		if( !@$path || !$n ) {
		    $searching = 0;
		}
	    } else {
		$searching = 0;
	    }
	}
    }
    return $path;
}





sub pick {
    my @list = @_;
    
    my $n = int(rand(scalar @list));
    
    return $list[$n];
} 













sub build_nodes {

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




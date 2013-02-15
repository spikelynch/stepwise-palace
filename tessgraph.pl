#!/usr/bin/perl

use strict;
use JSON;
use Data::Dumper;

my $patstr = "BCDEDCDEDC" x 8;

my $PRINT_JSON = 1;
my $SEARCH = 0;
my $SEARCH_BACKTRACK = 1;


my $MAX_BACKTRACK = 100000;

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

    #print "From $node->{id} $node->{class} next class $class: ";

    LINK: for my $link ( @{$node->{links}} ) {
	my $next = $nodes->[$link->{target}];
	next LINK if $next->{visited};
	next LINK if $next->{class} ne $class;
	next LINK if $node->{path_taken}{$link->{target}};
	push @$nexts, $next;
    }
    #print nlist($nexts) . "\n";
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
    my $n = 0;
    my $longest = 0;

    SEARCH: while( $searching ) {
	my $nexts = neighbours($head, $pat[$i]);

	if( @$nexts ) {
	    my $next = pick(@$nexts);
	    push @$path, $head;
	    $head->{visited} = 1;
	    $head->{path_taken}{$next->{id}} = 1;
	    $head = $next;
	    $i++;
	    if( $i == 81 ) {
		print "FOUND IT!\n";
		last SEARCH;
	    }
	} else {
	    if( $SEARCH_BACKTRACK ) {
		#print "Backing up:\n";
	      BACKTRACK: while( @$path ) {
		  $head = pop @$path;
		  $i--;
		  my $nexts = neighbours($head, $pat[$i]);
		  if( @$nexts ) {
		      #print "Ending backtrack at $head->{id}\n";
		      last BACKTRACK;
		  }
		  delete $head->{visited};
		  delete $head->{path_taken};
	      }
		#print "\n";
		$n++;
		if( !@$path ) {
		    $searching = 0;
		}
		if( $n > $MAX_BACKTRACK ) {
		    print "Giving up at $n\n";
		    $searching = 0;
		}
	    } else {
		$searching = 0;
	    }
	}
	if( @$path > $longest ) {
	    $longest = scalar(@$path);
	    if( $longest > 60 ) {
		print "L $longest:\n" . join(' ', map { $_->{id} } @$path) . "\n";
	    }
	}
	
    }
    return $path;
}



sub nlist {
    my ( $n )  = @_;
    
    return '[ ' . join(' ', map { $_->{id} } @$n) . ' ]';
}


sub pick {
    my @list = @_;
    
    my $n = int(rand(scalar @list));
    
    return $list[$n];
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




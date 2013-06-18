#!/usr/bin/perl

# Old search code from tessgraph.pl, removed and parked here.

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











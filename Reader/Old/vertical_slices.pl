#!/usr/bin/perl

use JSON;
use Data::Dumper;

use constant X => 0;
use constant Y => 1;
use constant Z => 2;
use constant T => 3;

my $NAMES = {
    0 => 'X',
    1 => 'Y', 
    2 => 'Z',
    3 => 'T'
};

my $PATH_COORDS = './path.json';

my $path = read_path($PATH_COORDS);

my $r1 = shift @$path;
my $last = undef;

print "Room,X,Y,Z,T,U,A,F\n";

while ( my $r2 = shift @$path ) {
    my $s = slice($r1->{coords}, $r2->{coords}, $last);
    my $coords = { X => 1, Y => 1, T => 1 };
    delete $coords->{$s};
    # remove any remaining coords with value == 0
    for my $k ( keys %$coords ) {
        if( $r1->{coords}[$k] == 0 ) {
            delete $coords->{$k};
        }
    }
    # whatever remains is the face turned to the front
    my ( $face ) = keys %$coords;
    my $val = '';
    if( defined $face ) {
        $val = $r1->{coords}[$face];
    }
    print join(',', $r1->{name}, @{$r1->{coords}}, $NAMES->{$s}, $NAMES->{$face}, $val) . "\n";
    $last = $s;
    $r1 = $r2;
}



sub slice {
    my ( $r1, $r2, $last_u ) = @_;

    my $step = undef;

    COORD: for $c ( X, Y, Z, T ) {
        if( $r1->[$c] != $r2->[$c] ) {
            $step = $c;
            last COORD;
        }
    }

    die("Couldn't find step") unless defined $step;

    if( $step == Z ) {
        if( defined $last_u ) {
            return $last_u;
        } else {
            return undef;
        }
    } else {
        return $step;
    }
}   


sub room {
    my ( $r ) = @_;
    my $s = $r->{name};
    $s .= " " . join(', ', @{$r->{coords}});
    return $s;
}


sub read_path {
    my ( $file ) = @_;

    local $/ = undef;
    my $data = undef;

    open(my $fh, $file) || die("Couldn't open $file: $!");

    my $json = <$fh>;
    close $fh;
    $data = decode_json($json);

    return $data;
}


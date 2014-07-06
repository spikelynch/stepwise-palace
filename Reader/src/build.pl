#!/usr/bin/perl

use strict;
use Data::Dumper;
use JSON;
use Template;

my $PATH_COORDS = './coords.json';

my $DIR = '../Poem';
my $VERSES_RE = qr/^SP[A-I]/;

my $TEMPLATES = './';
my $OUTPUT = './';
my $HTML_TT = 'poem.html.tt';
my $JSON_TT = 'poem.json.tt';

my $HTML_OUT = 'index.html';
my $JSON_OUT = 'path.js';

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




my $path = read_path($PATH_COORDS);

my $last = undef;

my $moves = {};

for my $room ( @$path ) {
    if ( $last ) {
        my ( $c, $d ) = move( $last, $room );
#        print room($last) . ",$c, $NAMES->{$c}, $d\n";
        $moves->{$last->{name}} = {
            to => $room->{name},
            coord => $c,
            dir => $d
        }
    }
    $last = $room;
}


my $stanzas = read_stanzas();

my $tt = Template->new({ INCLUDE_PATH => $TEMPLATES, OUTPUT_PATH => $OUTPUT });

for my $s ( @$stanzas ) {
    my $vars = {
        title => $s->{title},
        fig => $s->{fig},
        lines => $s->{lines},
        coords => 
    $tt->process($HTML_TT, { stanzas => $stanzas }, $HTML_OUT) || die(
    "Error writing $HTML_OUT: " . $tt->error()
);

my $path_json = encode_json($moves);

$tt->process($JSON_TT, { json => $path_json }, $JSON_OUT) || die(
    "Error writing $JSON_OUT: " . $tt->error()
);

sub move {
    my ( $r1, $r2 ) = @_;

    my ( $c, $d ) = diff($r1, $r2);

    if( $c == Z ) {
        return ( 'Y', $d );
    }

    if( $c == T ) {
        return ( 'Z', $d );
    }

    my $nd = undef;

    # rules for translating X/Y moves (in the poem's model)
    # to an X move on the screen
    
    if( $c == X ) {
        my $oc = $r2->{coords}[Y];
        if( $oc == -1 ) {
            $nd = $d;
        } elsif( $oc == 1 ) {
            $nd = -$d;
        } else {
            if( $r2->{coords}[X] == 0 ) {
                $nd = $d;
            } else {
                $nd = -$d;
            }
        }
    } else {
        my $oc = $r2->{coords}[X];
        if( $oc == -1 ) {
            $nd = -$d;
        } elsif( $oc == 1 ) {
            $nd = $d;
        } else {
            if( $r2->{coords}[Y] == 0 ) {
                $nd = -$d;
            } else {
                $nd = $d;
            }
        }
    }


    return ('X', $nd);
}




sub diff {
    my ( $r1, $r2 ) = @_;

    for my $c ( X, Y, Z, T ) {
        my $d = $r2->{coords}[$c] - $r1->{coords}[$c];
        if( $d ) { 
            return ( $c, $d );
        }
    }

    warn("Two adjacent rooms with same coordinates");
    warn(Dumper({ r1 => $r1, r2 => $r2 }));
    die;
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





sub read_stanzas {
    opendir(my $dh, $DIR) || die("Can't open $DIR $!");

    my $stanzas = [];

    while( my $item = readdir($dh) ) {
        next if $item =~ /~$/;
        if( $item =~ /$VERSES_RE/ ) {
            read_file("$DIR/$item", $stanzas);
        }
    }
    
    return $stanzas;
}

sub read_file {
    my ( $file, $stanzas ) = @_;

    open VERSES, $file || die("Can't open $file: $!");

    my $stanza = undef;

    while ( my $line = <VERSES> ) {
        chomp $line;
        if( $line =~ /^Figure\s+([A-E]\d+):\s*([A-Z].*)$/ ) {
            my ( $fig, $title ) = ( $1, $2 );
            if( $stanza ) {
                $stanza->{next} = $fig;
                push @$stanzas, $stanza 
            }
            $stanza = { fig => $fig, title => $title, lines => [] }
        } else {
            if( $line =~ /^[^\s]/ ) {
                if( !$stanza ) {
                    die ("Nude line $line in $file");
                }
                push @{$stanza->{lines}}, $line
            }
        }
    }
    if( $stanza ) {
        push @$stanzas, $stanza 
    }
}



#!/usr/bin/perl

my $TIME = {
    -1 => 'past',
    0 => 'present',
    1 => 'future'
};

my $HEIGHT = {
    -1 => 'deeps',
    0 => 'ground',
    1 => 'heaven'
};

my $X = {
    -1 => 'west',
    0 => 'centre',
    1 => 'east'
};

my $Y = {
    -1 => 'south',
    0 => 'centre',
    1 => 'north'
};

my $Tmove = {
    -1 => 'past',
    1 => 'future'
};

my $Hmove = {
    -1 => 'down',
    1 => 'up'
};

my $Xmove = {
    -1 => 'west',
    1 => 'east'
};

my $Ymove = {
    -1 => 'south',
    1 => 'north'
};


my $DIM = [ $X, $Y, $TIME, $HEIGHT ];
my $MOVE = [ $Xmove, $Ymove, $Tmove, $Hmove ];

my $last = undef;

while ( <DATA> ) {
    chomp;
    my ( $label, @coords ) = split(/\s+/);
    
    if( scalar(@coords) == 4 ) {

	my @words = map { $DIM->[$_]{$coords[$_]} } ( 0..3 );
	my $location = join("\t", @words);
	my $m;
	if( $last ) {
	    my $delta = [];
	    my $move = [];
	    for my $i ( 0..3 ) {
		$delta->[$i] = $coords[$i] - $last->[$i];
		$move->[$i] = $MOVE->[$i]{$delta->[$i]};
	    }
	    ( $m ) = map { $move->[$_] ? ( $move->[$_] ) : () } 0..3;
	} else {
	    $m = 'enter';
	}
	print "$label\t$m\t$location\n";
	$last = [];
	@$last = @coords;

    } else {
	print "$_\n";
    }
}



__DATA__
A1 0 0 0 0
B4 0 0 0 -1
C3 -1 0 0 -1
B1 -1 0 0 0
C6 -1 1 0 0
D10 -1 1 0 -1
E7 -1 1 1 -1
D7 -1 0 1 -1
C13 0 0 1 -1
B6 0 0 1 0
C5 -1 0 1 0
D12 -1 1 1 0
C18 0 1 1 0
D19 0 1 1 -1
C16 0 1 0 -1
B7 0 1 0 0
C24 1 1 0 0
D30 1 1 0 -1
E15 1 1 1 -1
D32 1 1 1 0
E16 1 1 1 1
D20 0 1 1 1
E8 -1 1 1 1
D8 -1 0 1 1
C14 0 0 1 1
B5 0 0 0 1
C4 -1 0 0 1
D11 -1 1 0 1
C17 0 1 0 1
D31 1 1 0 1
C22 1 0 0 1
D28 1 0 1 1
C23 1 0 1 0
D27 1 0 1 -1
C21 1 0 0 -1
B8 1 0 0 0
C19 1 -1 0 0
D22 1 -1 0 -1
E11 1 -1 1 -1
D24 1 -1 1 0
E12 1 -1 1 1
D23 1 -1 0 1
E10 1 -1 -1 1
D26 1 0 -1 1
E14 1 1 -1 1
D18 0 1 -1 1
E6 -1 1 -1 1
D6 -1 0 -1 1
C12 0 0 -1 1
B3 0 0 -1 0
C2 -1 0 -1 0
D9 -1 1 -1 0
C15 0 1 -1 0
D29 1 1 -1 0
C20 1 0 -1 0
D21 1 -1 -1 0
C7 0 -1 -1 0
D14 0 -1 -1 1
C9 0 -1 0 1
D16 0 -1 1 1
C10 0 -1 1 0
D15 0 -1 1 -1
C8 0 -1 0 -1
B2 0 -1 0 0
C1 -1 -1 0 0
D2 -1 -1 0 -1
E3 -1 -1 1 -1
D4 -1 -1 1 0
E4 -1 -1 1 1
D3 -1 -1 0 1
E2 -1 -1 -1 1
D1 -1 -1 -1 0
E1 -1 -1 -1 -1
D13 0 -1 -1 -1
E9 1 -1 -1 -1
D25 1 0 -1 -1
E13 1 1 -1 -1
D17 0 1 -1 -1
E5 -1 1 -1 -1
D5 -1 0 -1 -1
C11 0 0 -1 -1

Slightly better 
C6 -1 1 0 0
B7 0 1 0 0
C24 1 1 0 0
B8 1 0 0 0
C19 1 -1 0 0
B2 0 -1 0 0
C1 -1 -1 0 0
D2 -1 -1 0 -1
E3 -1 -1 1 -1
D4 -1 -1 1 0
E4 -1 -1 1 1
D3 -1 -1 0 1
E2 -1 -1 -1 1
D1 -1 -1 -1 0
E1 -1 -1 -1 -1
D13 0 -1 -1 -1
C7 0 -1 -1 0
D14 0 -1 -1 1
C9 0 -1 0 1
D16 0 -1 1 1
C10 0 -1 1 0
D15 0 -1 1 -1
C8 0 -1 0 -1
D22 1 -1 0 -1
E11 1 -1 1 -1
D24 1 -1 1 0
E12 1 -1 1 1
D23 1 -1 0 1
E10 1 -1 -1 1
D21 1 -1 -1 0
E9 1 -1 -1 -1
D25 1 0 -1 -1
C20 1 0 -1 0
D26 1 0 -1 1
C22 1 0 0 1
D28 1 0 1 1
C23 1 0 1 0
D27 1 0 1 -1
C21 1 0 0 -1
D30 1 1 0 -1
E15 1 1 1 -1
D32 1 1 1 0
E16 1 1 1 1
D31 1 1 0 1
E14 1 1 -1 1
D29 1 1 -1 0
E13 1 1 -1 -1
D17 0 1 -1 -1
C15 0 1 -1 0
D18 0 1 -1 1
C17 0 1 0 1
D20 0 1 1 1
C18 0 1 1 0
D19 0 1 1 -1
C16 0 1 0 -1
D10 -1 1 0 -1
E7 -1 1 1 -1
D12 -1 1 1 0
E8 -1 1 1 1
D11 -1 1 0 1
E6 -1 1 -1 1
D9 -1 1 -1 0
E5 -1 1 -1 -1
D5 -1 0 -1 -1
C11 0 0 -1 -1
B3 0 0 -1 0
C2 -1 0 -1 0
D6 -1 0 -1 1
C12 0 0 -1 1
B5 0 0 0 1
C4 -1 0 0 1
D8 -1 0 1 1
C14 0 0 1 1
B6 0 0 1 0
C5 -1 0 1 0
D7 -1 0 1 -1
C13 0 0 1 -1
B4 0 0 0 -1
C3 -1 0 0 -1
B1 -1 0 0 0
A1 0 0 0 0

Very wiggly

E1 -1 -1 -1 -1
D13 0 -1 -1 -1
C7 0 -1 -1 0
D1 -1 -1 -1 0
E2 -1 -1 -1 1
D14 0 -1 -1 1
C9 0 -1 0 1
D3 -1 -1 0 1
E4 -1 -1 1 1
D16 0 -1 1 1
C10 0 -1 1 0
D4 -1 -1 1 0
E3 -1 -1 1 -1
D15 0 -1 1 -1
C8 0 -1 0 -1
D2 -1 -1 0 -1
C1 -1 -1 0 0
B2 0 -1 0 0
C19 1 -1 0 0
B8 1 0 0 0
C21 1 0 0 -1
D22 1 -1 0 -1
E11 1 -1 1 -1
D27 1 0 1 -1
C23 1 0 1 0
D24 1 -1 1 0
E12 1 -1 1 1
D28 1 0 1 1
C22 1 0 0 1
D23 1 -1 0 1
E10 1 -1 -1 1
D26 1 0 -1 1
C20 1 0 -1 0
D21 1 -1 -1 0
E9 1 -1 -1 -1
D25 1 0 -1 -1
E13 1 1 -1 -1
D17 0 1 -1 -1
C15 0 1 -1 0
D29 1 1 -1 0
E14 1 1 -1 1
D18 0 1 -1 1
C17 0 1 0 1
D31 1 1 0 1
E16 1 1 1 1
D20 0 1 1 1
C18 0 1 1 0
D32 1 1 1 0
E15 1 1 1 -1
D19 0 1 1 -1
C16 0 1 0 -1
D30 1 1 0 -1
C24 1 1 0 0
B7 0 1 0 0
C6 -1 1 0 0
B1 -1 0 0 0
C3 -1 0 0 -1
D10 -1 1 0 -1
E7 -1 1 1 -1
D7 -1 0 1 -1
C5 -1 0 1 0
D12 -1 1 1 0
E8 -1 1 1 1
D8 -1 0 1 1
C4 -1 0 0 1
D11 -1 1 0 1
E6 -1 1 -1 1
D6 -1 0 -1 1
C2 -1 0 -1 0
D9 -1 1 -1 0
E5 -1 1 -1 -1
D5 -1 0 -1 -1
C11 0 0 -1 -1
B3 0 0 -1 0
C12 0 0 -1 1
B5 0 0 0 1
C14 0 0 1 1
B6 0 0 1 0
C13 0 0 1 -1
B4 0 0 0 -1
A1 0 0 0 0

Final?

C6 -1 1 0 0
B7 0 1 0 0
C24 1 1 0 0
B8 1 0 0 0
C19 1 -1 0 0
B2 0 -1 0 0
C1 -1 -1 0 0
D2 -1 -1 0 -1
E3 -1 -1 1 -1
D4 -1 -1 1 0
E4 -1 -1 1 1
D3 -1 -1 0 1
E2 -1 -1 -1 1
D1 -1 -1 -1 0
E1 -1 -1 -1 -1
D13 0 -1 -1 -1
C7 0 -1 -1 0
D14 0 -1 -1 1
C9 0 -1 0 1
D16 0 -1 1 1
C10 0 -1 1 0
D15 0 -1 1 -1
C8 0 -1 0 -1
D22 1 -1 0 -1
E11 1 -1 1 -1
D24 1 -1 1 0
E12 1 -1 1 1
D23 1 -1 0 1
E10 1 -1 -1 1
D21 1 -1 -1 0
E9 1 -1 -1 -1
D25 1 0 -1 -1
C20 1 0 -1 0
D26 1 0 -1 1
C22 1 0 0 1
D28 1 0 1 1
C23 1 0 1 0
D27 1 0 1 -1
C21 1 0 0 -1
D30 1 1 0 -1
E15 1 1 1 -1
D32 1 1 1 0
E16 1 1 1 1
D31 1 1 0 1
E14 1 1 -1 1
D29 1 1 -1 0
E13 1 1 -1 -1
D17 0 1 -1 -1
C15 0 1 -1 0
D18 0 1 -1 1
C17 0 1 0 1
D20 0 1 1 1
C18 0 1 1 0
D19 0 1 1 -1
C16 0 1 0 -1
D10 -1 1 0 -1
E7 -1 1 1 -1
D12 -1 1 1 0
E8 -1 1 1 1
D11 -1 1 0 1
E6 -1 1 -1 1
D9 -1 1 -1 0
E5 -1 1 -1 -1
D5 -1 0 -1 -1
C11 0 0 -1 -1
B3 0 0 -1 0
C2 -1 0 -1 0
D6 -1 0 -1 1
C12 0 0 -1 1
B5 0 0 0 1
C4 -1 0 0 1
D8 -1 0 1 1
C14 0 0 1 1
B6 0 0 1 0
C5 -1 0 1 0
D7 -1 0 1 -1
C13 0 0 1 -1
B4 0 0 0 -1
C3 -1 0 0 -1
B1 -1 0 0 0
A1 0 0 0 0


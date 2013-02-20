#!/usr/bin/perl

use strict;

use Data::Dumper;

my $stack = [];
my $layer = [];

while( <DATA> ) {
    chomp;
    if( /([A-E][0-9]+)\s+([A-E][0-9]+)\s+([A-E][0-9]+)/ ) {
	push @$layer, [ $1, $2, $3 ];
    } elsif( /==/ ) {
	my $row = uncoil($layer);
	push @$stack, $row;
	$layer = [];
    } else {
	die("Bad data row $_\n");
    }
}

for my $row ( @$stack ) {
    print join('   ', map { sprintf("%-3s", $_) } @$row) . "\n";
}



sub uncoil {
    my ( $layer ) = @_;
    
    # uncoil:
    #
    #   0  7  6
    #   1  8  5
    #   2  3  4
    my $row = [];
    
    push @$row, $layer->[0][0];
    push @$row, $layer->[1][0];
    push @$row, $layer->[2][0];
    push @$row, $layer->[2][1];
    push @$row, $layer->[2][2];
    push @$row, $layer->[1][2];
    push @$row, $layer->[0][2];
    push @$row, $layer->[0][1];
    push @$row, $layer->[1][1];

    return $row;
}

__DATA__
E1  D2  E3  
D1  C1  D4  
E2  D3  E4  
==
D13 C8  D15                           
C7  B2  C10 
D14 C9  D16 
==
E9  D22 E11 
D21 C19 D24                           
E10 D23 E12 
==
D25 C21 D27 
C20 B8  C23                           
D26 C22 D28 
==
E13 D30 E15 
D29 C24 D32                           
E14 D31 E16 
==
D17 C16 D19 
C15 B7  C18                           
D18 C17 D20 
==
E5  D10 E7  
D9  C6  D12                           
E6  D11 E8  
==
D5  C3  D7  
C2  B1  C5                            
D6  C4  D8  
==
C11 B4  C13 
B3  A1  B6                            
C12 B5  C14 
==

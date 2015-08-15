use strict;
use warnings;

use Test::More tests => 1000;

use Games::Catan::Dice;

my $die = Games::Catan::Dice->new();

for ( 1 .. 1000 ) {

  my $result = $die->roll();

  ok( $result >= 2 && $result <= 12, "rolled $result" );
}


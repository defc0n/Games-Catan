package Games::Catan::Dice;

use Moo;

sub roll {

  return ( int( rand( 6 ) ) + 1 ) + ( int( rand( 6 ) ) + 1 );
}

1;

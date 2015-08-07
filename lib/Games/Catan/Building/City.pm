package Games::Catan::Building::City;

use Moo;

with( 'Games::Catan::Building' );

has num_points => ( is => 'ro',
		    isa => Int,
		    required => 0,
		    default => 2 );

1;

package Games::Catan::Building::Settlement;

use Moo;

with( 'Games::Catan::Building' );

has num_points => ( is => 'ro',
		    isa => Int,
		    required => 0,
		    default => 1 );

1;

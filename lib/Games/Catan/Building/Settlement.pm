package Games::Catan::Building::Settlement;

use Moo;
use Types::Standard qw( Int );

with( 'Games::Catan::Building' );

has num_points => ( is => 'ro',
		    isa => Int,
		    required => 0,
		    default => 1 );

1;

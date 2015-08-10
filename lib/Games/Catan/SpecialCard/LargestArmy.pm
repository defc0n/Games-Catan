package Games::Catan::SpecialCard::LargestArmy;

use Moo;
use Types::Standard qw( Int );

with( 'Games::Catan::SpecialCard' );

has num_points => ( is => 'ro',
		    isa => Int,
		    required => 0,
		    default => 1 );

1;

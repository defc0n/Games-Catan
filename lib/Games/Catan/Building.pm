package Games::Catan::Building;

use Moo::Role;
use Types::Standard qw( Int );

has num_points => ( is => 'ro',
		    isa => Int,
		    required => 1 );

has player => ( is => 'ro',
		isa => 'Games::Catan::Player',
		required => 1 );



1;

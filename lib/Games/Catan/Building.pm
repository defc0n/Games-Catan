package Games::Catan::Building;

use Moo::Role;
use Types::Standard qw( ConsumerOf );

has player => ( is => 'ro',
		isa => ConsumerOf['Games::Catan::Player'],
		required => 1 );

1;

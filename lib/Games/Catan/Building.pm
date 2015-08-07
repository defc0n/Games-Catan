package Games::Catan::Building;

use Moo::Role;
use Types::Standard qw( InstanceOf );

has player => ( is => 'ro',
		isa => InstanceOf['Games::Catan::Player'],
		required => 1 );

1;

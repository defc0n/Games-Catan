package Games::Catan::Road;

use Moo;
use Types::Standard qw( ConsumerOf );

has player => ( is => 'ro',
		isa => ConsumerOf['Games::Catan::Player'],
		required => 1 );

1;

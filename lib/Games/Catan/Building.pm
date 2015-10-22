package Games::Catan::Building;

use Moo::Role;
use Types::Standard qw( ConsumerOf Maybe Int );

has player => ( is => 'ro',
		isa => ConsumerOf['Games::Catan::Player'],
		required => 1 );

has intersection => ( is => 'rw',
		      isa => Maybe[Int],
		      required => 0,
		      clearer => 1 );

1;

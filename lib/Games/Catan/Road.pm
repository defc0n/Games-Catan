package Games::Catan::Road;

use Moo;
use Types::Standard qw( ConsumerOf InstanceOf );

use Games::Catan::Cost;

has player => ( is => 'ro',
		isa => ConsumerOf['Games::Catan::Player'],
		required => 1 );

has cost => ( is => 'ro',
	      isa => InstanceOf['Games::Catan::Cost'],
	      required => 0,
	      default => sub { Games::Catan::Cost->new( brick => 1,
							lumber => 1 ) } );

1;

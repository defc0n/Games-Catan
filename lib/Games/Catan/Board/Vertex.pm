package Games::Catan::Board::Vertex;

use Moo;
use Types::Standard qw( InstanceOf );

has building => ( is => 'rw',
		  isa => InstanceOf['Games::Catan::Building'],
		  required => 0 );

1;

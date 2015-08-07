package Games::Catan::Board::Tile;

use Moo;
use Types::Standard qw( Int Str );

has terrain => ( is => 'ro',
		 isa => Str,
		 required => 1 );

has number => ( is => 'ro',
		isa => Int,
		required => 1 );

1;

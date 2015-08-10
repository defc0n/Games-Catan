package Games::Catan::Board::Tile;

use Moo;
use Types::Standard qw( Enum InstanceOf Maybe );

has terrain => ( is => 'ro',
		 isa => Enum[qw( hills forest mountains fields pasture desert )],
		 required => 1 );

has number => ( is => 'ro',
		isa => Enum[qw( 2 3 4 5 6 7 8 9 10 11 12 )],
		required => 1 );

has robber => ( is => 'rw',
		isa => Maybe[InstanceOf['Games::Catan::Robber']],
		required => 0 );

sub BUILD {

  my ( $self ) = @_;

  # make sure that 7 and desert go together
  if ( ( $self->terrain eq 'desert' && $self->number != 7 ) ||
       ( $self->number == 7 && $self->terrain ne 'desert' ) ) {

    die( "A desert must be a 7 and vice versa" );
  }
}

1;

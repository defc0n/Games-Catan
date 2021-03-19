package Games::Catan::Board::Tile;

use Moo;
use Types::Standard qw( Enum InstanceOf Maybe ArrayRef Int );

has terrain => (
    is       => 'ro',
    isa      => Enum[qw( hills forest mountains fields pasture desert )],
    required => 1,
);

has number => (
    is       => 'ro',
    isa      => Enum[ 2 .. 12 ],
    required => 1,
);

has robber => (
    is       => 'rw',
    isa      => Maybe[InstanceOf['Games::Catan::Robber']],
    required => 0,
    clearer  => 1,
);

has vertices => (
    is       => 'ro',
    isa      => ArrayRef[Int],
    required => 1,
);

sub BUILD {
    my ( $self ) = @_;

    # Make sure that 7 and desert go together.
    return if $self->terrain eq 'desert' && $self->number == 7;
    return if $self->terrain ne 'desert' && $self->number != 7;

    die "A desert must be a 7 and vice versa";
}

1;

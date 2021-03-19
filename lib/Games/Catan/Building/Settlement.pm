package Games::Catan::Building::Settlement;

use Moo;
use Types::Standard qw( Int InstanceOf );

with( 'Games::Catan::Building' );

has num_points => (
    is       => 'ro',
    isa      => Int,
    required => 0,
    default  => 1,
);

has cost => (
    is       => 'ro',
    isa      => InstanceOf['Games::Catan::Cost'],
    required => 0,
    default  => sub {
        Games::Catan::Cost->new(
            brick  => 1,
            lumber => 1,
            wool   => 1,
            grain  => 1,
        )
    },
);

1;

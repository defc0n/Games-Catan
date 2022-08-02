package Games::Catan::SpecialCard::LargestArmy;

use Moo;
with 'Games::Catan::SpecialCard';

use Types::Standard qw( Int );

has num_points => (
    is       => 'ro',
    isa      => Int,
    required => 0,
    default  => 2,
);

1;

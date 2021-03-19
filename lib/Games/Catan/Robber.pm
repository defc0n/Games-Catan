package Games::Catan::Robber;

use Moo;
use Types::Standard qw( InstanceOf );

has game => (
    is       => 'ro',
    isa      => InstanceOf['Games::Catan'],
    required => 1,
);

1;

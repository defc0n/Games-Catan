package Games::Catan::SpecialCard;

use Moo::Role;
use Types::Standard qw( InstanceOf ConsumerOf Maybe );

has game => (
    is => 'ro',
    isa => InstanceOf['Games::Catan'],
    required => 1,
);

has player => (
    is       => 'rw',
    isa      => Maybe[ConsumerOf['Games::Catan::Player']],
    required => 0,
    clearer  => 1,
);

1;

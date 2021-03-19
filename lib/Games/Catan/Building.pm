package Games::Catan::Building;

use Moo::Role;
use Types::Standard qw( ConsumerOf InstanceOf Maybe Int );

has game => (
    is       => 'ro',
    isa      => InstanceOf['Games::Catan'],
    required => 1,
);

has player => (
    is       => 'ro',
    isa      => ConsumerOf['Games::Catan::Player'],
    required => 1,
);

has intersection => (
    is       => 'rw',
    isa      => Maybe[Int],
    required => 0,
    clearer  => 1,
);

has logger => (
    is       => 'ro',
    isa      => InstanceOf['Log::Any::Proxy'],
    required => 0,
    default  => sub { Log::Any->get_logger() },
);

1;

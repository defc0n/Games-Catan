package Games::Catan::Road;

use Moo;
use Types::Standard qw( ConsumerOf InstanceOf );

use Games::Catan::Cost;

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

has cost => (
    is       => 'ro',
    isa      => InstanceOf['Games::Catan::Cost'],
    required => 0,
    default  => sub {
        Games::Catan::Cost->new(
            brick  => 1,
            lumber => 1,
        )
    },
);

has logger => (
    is       => 'ro',
    isa      => InstanceOf['Log::Any::Proxy'],
    required => 0,
    default  => sub { Log::Any->get_logger() },
);

sub buy {
    my ( $self, $location ) = @_;

    my ( $u, $v ) = @$location;
    my $road = shift @{ $self->player->roads };

    $self->game->board->graph->set_edge_attribute( $u, $v, 'road', $road );
    $self->logger->info( $self->player->color . " built a road" );
}

1;

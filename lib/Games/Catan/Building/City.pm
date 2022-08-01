package Games::Catan::Building::City;

use Moo;
with 'Games::Catan::Building';

use Types::Standard qw( Int InstanceOf );

has num_points => (
    is       => 'ro',
    isa      => Int,
    required => 0,
    default  => 2,
);

has cost => (
    is       => 'ro',
    isa      => InstanceOf['Games::Catan::Cost'],
    required => 0,
    default  => sub {
        Games::Catan::Cost->new(
            ore         => 3,
            grain       => 2,
            settlements => 1,
        )
    },
);

sub buy {
    my ( $self, $location ) = @_;

    $self->game->board->upgrade_settlement( $location );
    $self->logger->info( $self->player->color . " upgraded to a city." );
}

1;

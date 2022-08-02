package Games::Catan::DevelopmentCard::Knight;

use Moo;
with 'Games::Catan::DevelopmentCard';

use Types::Standard qw( Int Bool );

has playable => (
    is       => 'ro',
    isa      => Bool,
    required => 0,
    default  => 1,
);

has num_points => (
    is       => 'ro',
    isa      => Int,
    required => 0,
    default  => 0,
);

sub play {
    my ( $self ) = @_;

    # Mark this card as being played so it can't be played again in the future.
    $self->played( 1 );

    # Increase the size of this player's army.
    $self->player->army_size( $self->player->army_size + 1 );

    $self->logger->info( $self->player->color . " played a Knight." );

    # The player who played the cards gets to activate the robber & steal.
    $self->player->activate_robber;
}

1;

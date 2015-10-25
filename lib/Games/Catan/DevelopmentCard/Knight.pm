package Games::Catan::DevelopmentCard::Knight;

use Moo;

with( 'Games::Catan::DevelopmentCard' );

use Types::Standard qw( Int Bool );

has playable => ( is => 'ro',
                  isa => Bool,
                  required => 0,
                  default => 1 );

has num_points => ( is => 'ro',
                    isa => Int,
                    required => 0,
                    default => 0 );

sub play {

    my ( $self ) = @_;

    $self->logger->info( $self->player->color . " played a Knight." );

    # mark this card as being played so it can't be played again in the future
    $self->played( 1 );

    # increase the size of this player's army
    $self->player->army_size( $self->player->army_size + 1 );
}

1;

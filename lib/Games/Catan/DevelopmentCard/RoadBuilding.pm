package Games::Catan::DevelopmentCard::RoadBuilding;

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
    my ( $self, $paths ) = @_;

    $self->logger->info(
	$self->player->color . " is playing Road Building"
    );

    for my $path ( @$paths ) {
	my ( $u, $v ) = @$path;

	# Grab one of the players roads to build.
	my $road = shift @{ $self->player->roads };

	# No more roads!
	last unless $road;

	# Place it on the board.d
	$self->game->board->graph->set_edge_attribute( $u, $v, 'road', $road );

	$self->logger->info( $self->player->color . " built a road" );
    }

    # It is possible this could affect who has the longest road.
    $self->game->update_longest_road;

    $self->played( 1 );

    $self->logger->info(
	$self->player->color . " finished Road Building"
    );
}

1;

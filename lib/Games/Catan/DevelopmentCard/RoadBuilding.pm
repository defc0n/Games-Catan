package Games::Catan::DevelopmentCard::RoadBuilding;

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

    my ( $self, $paths ) = @_;

    $self->logger->info( $self->player->color . " played Road Building." );

    foreach my $path ( @$paths ) {

	my ( $u, $v ) = @$path;

	# grab one of the players roads to build
	my $road = shift( @{$self->player->roads} );

	# no more roads!
	last if !$road;

	# place it on the board
	$self->game->board->graph->set_edge_attribute( $u, $v, 'road', $road );

	$self->logger->info( $self->player->color . " built a road." );
    }

    # its possible this could affect who has the longest road
    $self->game->update_longest_road();

    $self->played( 1 );
}

1;

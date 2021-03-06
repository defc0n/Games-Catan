package Games::Catan::Building::City;

use Moo;
use Types::Standard qw( Int InstanceOf );

with( 'Games::Catan::Building' );

has num_points => ( is => 'ro',
		    isa => Int,
		    required => 0,
		    default => 2 );

has cost => ( is => 'ro',
	      isa => InstanceOf['Games::Catan::Cost'],
	      required => 0,
              default => sub { Games::Catan::Cost->new( ore => 3,
						        grain => 2,
							settlements => 1 ) } );

sub buy {

    my ( $self, $location ) = @_;

    $self->logger->info( $self->player->color . " upgraded to a city." );

    $self->game->board->upgrade_settlement( $location );
}

1;

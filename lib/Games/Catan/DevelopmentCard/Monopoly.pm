package Games::Catan::DevelopmentCard::Monopoly;

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

    my ( $self, $resource ) = @_;

    $self->logger->info( $self->player->color . " played Monopoly." );

    my %valid_resources = ('brick' => 1, 'grain' => 1, 'lumber' => 1, 'ore' => 1, 'wool' => 1);

    die( "$resource is not a valid resource to steal" ) if !$valid_resources{$resource};

    $self->logger->info( $self->player->color . " has decided to steal $resource." );

    foreach my $player ( @{$self->game->players} ) {

	# dont steal from ourself
	next if ( $player->color eq $self->player->color );

	# take away each one of that resource from other player
	while ( my $stolen_resource = shift( @{$player->$resource()} ) ) {

	    $self->logger->info( $self->player->color . " stole a $resource from " . $player->color );

	    # give it to this player who played the card
	    push( @{$self->player->$resource()}, $stolen_resource );
	}
    }

    $self->played( 1 );
}

1;

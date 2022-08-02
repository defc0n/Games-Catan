package Games::Catan::DevelopmentCard::Monopoly;

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
    my ( $self, $resource ) = @_;

    $self->logger->info(
	$self->player->color . " is playing Monopoly."
    );

    my %valid_resources = map { $_ => 1 } qw(
        brick
        grain
        lumber
        ore
        wool
    );

    die "$resource is not a valid resource to steal"
        unless $valid_resources{$resource};

    $self->logger->info(
        $self->player->color . " has decided to steal $resource."
    );

    for my $player ( @{ $self->game->players } ) {

	# Don't steal from ourself.
	next if $player->color eq $self->player->color;

	# Take away each one of that resource from other player.
	while ( my $stolen_resource = shift( @{ $player->$resource } ) ) {
	    # Give it to this player who played the card
	    push @{ $self->player->$resource }, $stolen_resource;

	    $self->logger->info(
                sprintf(
                    "%s stole a %s from %s.",
                    $self->player->color,
                    $resource,
                    $player->color,
                )
            );
	}
    }

    $self->played( 1 );

    $self->logger->info(
	$self->player->color . " finished Monopoly."
    );
}

1;

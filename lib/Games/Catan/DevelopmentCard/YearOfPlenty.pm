package Games::Catan::DevelopmentCard::YearOfPlenty;

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
    my ( $self, $resources ) = @_;

    $self->logger->info(
	$self->player->color . " is playing Year of Plenty"
    );

    my %valid_resources = map { $_ => 1 } qw(
        brick
        grain
        lumber
        ore
        wool
    );

    die "$resources->[0] is not a valid resource to take"
        unless $valid_resources{$resources->[0]};

    die "$resources->[1] is not a valid resource to take"
        unless $valid_resources{$resources->[1]};

    $self->logger->info(
        sprintf(
            "%s took %s and %s from the bank",
            $self->player->color,
            $resources->[0],
            $resources->[1],
        )
    );

    # Take these away from the bank.
    for my $resource ( @$resources ) {
        my $resource_card = shift @{ $self->game->bank->$resource };

        # Give it to this player who played the card.
        push @{ $self->player->$resource }, $resource_card;
    }

    $self->played( 1 );

    $self->logger->info(
	$self->player->color . " finished Year of Plenty"
    );
}

1;

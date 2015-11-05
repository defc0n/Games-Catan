package Games::Catan::DevelopmentCard::YearOfPlenty;

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

    my ( $self, $resources ) = @_;

    $self->logger->info( $self->player->color . " played Year of Plenty." );

    my %valid_resources = ('brick' => 1, 'grain' => 1, 'lumber' => 1, 'ore' => 1, 'wool' => 1);

    die( "$resources->[0] is not a valid resource to take" ) if !$valid_resources{$resources->[0]};
    die( "$resources->[1] is not a valid resource to take" ) if !$valid_resources{$resources->[1]};

    $self->logger->info( $self->player->color . " has decided to take $resources->[0] and $resources->[1] from the bank." );

    # take these away from the bank
    foreach my $resource ( @$resources ) {

        my $resource_card = shift( @{$self->game->bank->$resource()} );

        # give it to this player who played the card
        push( @{$self->player->$resource()}, $resource_card );
    }

    $self->played( 1 );
}

1;

package Games::Catan::DevelopmentCard;

use Moo::Role;
use Types::Standard qw( Bool InstanceOf ConsumerOf Maybe );

has game => (
    is       => 'ro',
    isa      => InstanceOf['Games::Catan'],
    required => 1,
);

has player => (
    is       => 'rw',
    isa      => Maybe[ConsumerOf['Games::Catan::Player']],
    required => 0,
);

has played => (
    is       => 'rw',
    isa      => Bool,
    required => 0,
    default  => 0,
    trigger  => sub { shift->game->check_winner() },
);

has cost => (
    is       => 'ro',
    isa      => InstanceOf['Games::Catan::Cost'],
    required => 0,
    default  => sub {
        Games::Catan::Cost->new(
            ore   => 1,
            wool  => 1,
            grain => 1,
        )
    },
);

has logger => (
    is       => 'ro',
    isa      => InstanceOf['Log::Any::Proxy'],
    required => 0,
    default  => sub { Log::Any->get_logger() },
);

sub buy {
    my ( $self ) = @_;

    my $development_card = shift( @{$self->game->development_cards} );
    $self->logger->info(
        $self->player->color . " bought a " . ref $development_card
    );

    # Set player as the owner of the card.
    $development_card->player( $self->player );

    # Add it to the list of playerdev cards.
    push @{ $self->player->development_cards }, $development_card;
}

1;

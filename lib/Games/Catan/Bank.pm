package Games::Catan::Bank;

use Moo;
use Types::Standard qw( InstanceOf ArrayRef );

use Games::Catan::ResourceCard::Brick;
use Games::Catan::ResourceCard::Lumber;
use Games::Catan::ResourceCard::Ore;
use Games::Catan::ResourceCard::Grain;
use Games::Catan::ResourceCard::Wool;

has brick => (
    is       => 'ro',
    isa      => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Brick']],
    required => 0,
    default  => sub { [] },
);

has lumber => (
    is       => 'ro',
    isa      => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Lumber']],
    required => 0,
    default  => sub { [] },
);

has ore => (
    is       => 'ro',
    isa      => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Ore']],
    required => 0,
    default  => sub { [] },
);

has grain => (
    is       => 'ro',
    isa      => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Grain']],
    required => 0,
    default  => sub { [] },
);

has wool => (
    is       => 'ro',
    isa      => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Wool']],
    required => 0,
    default  => sub { [] },
);

sub BUILD {
    my ( $self ) = @_;

    # Initialize the resource cards, 19 of each
    for ( 1 .. 19 ) {
        push @{$self->brick}, Games::Catan::ResourceCard::Brick->new();
        push @{$self->lumber}, Games::Catan::ResourceCard::Lumber->new();
        push @{$self->ore}, Games::Catan::ResourceCard::Ore->new();
        push @{$self->grain}, Games::Catan::ResourceCard::Grain->new();
        push @{$self->wool}, Games::Catan::ResourceCard::Wool->new();
    }
}

sub give_resource_cards {
    my ( $self, $cards ) = @_;

    for my $card ( @$cards ) {
	if ( $card->isa( 'Games::Catan::ResourceCard::Brick' ) ) {
	    push @{$self->brick}, $card;
	}
	elsif ( $card->isa( 'Games::Catan::ResourceCard::Lumber' ) ) {
	    push @{$self->lumber}, $card;
	}
	elsif ( $card->isa( 'Games::Catan::ResourceCard::Ore' ) ) {
	    push @{$self->ore}, $card;
	}
	elsif ( $card->isa( 'Games::Catan::ResourceCard::Grain' ) ) {
	    push @{$self->grain}, $card;
	}
	elsif ( $card->isa( 'Games::Catan::ResourceCard::Wool' ) ) {
	    push @{$self->wool}, $card;
	}
	else {
	    die "Unknown resource card.";
	}
    }
}

1;

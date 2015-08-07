package Games::Catan::Bank;

use Moo;
use Types::Standard qw( InstanceOf ArrayRef );

use Games::Catan::ResourceCard::Brick;
use Games::Catan::ResourceCard::Lumber;
use Games::Catan::ResourceCard::Ore;
use Games::Catan::ResourceCard::Grain;
use Games::Catan::ResourceCard::Wool;

has brick => ( is => 'ro',
	       isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Brick']],
	       required => 0,
	       default => sub { [] } );

has lumber => ( is => 'ro',
		isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Lumber']],
		required => 0,
		default => sub { [] } );

has ore => ( is => 'ro',
	     isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Ore']],
	     required => 0,
	     default => sub { [] } );

has grain => ( is => 'ro',
	       isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Grain']],
	       required => 0,
	       default => sub { [] } );

has wool => ( is => 'ro',
	      isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Wool']],
	      required => 0,
	      default => sub { [] } );

sub BUILD {

  my ( $self ) = @_;

  # initialize the resource cards
  for ( 1 .. 19 ) {

    push( @{$self->brick}, Games::Catan::ResourceCard::Brick->new() );
    push( @{$self->lumber}, Games::Catan::ResourceCard::Lumber->new() );
    push( @{$self->ore}, Games::Catan::ResourceCard::Ore->new() );
    push( @{$self->grain}, Games::Catan::ResourceCard::Grain->new() );
    push( @{$self->wool}, Games::Catan::ResourceCard::Wool->new() );
  }
}

1;

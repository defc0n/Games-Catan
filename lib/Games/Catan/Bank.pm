package Games::Catan::Bank;

use Moo;
use Types::Standard qw( InstanceOf ArrayRef );

has brick => ( is => 'ro',
	       isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Brick']] );

has lumber => ( is => 'ro',
		isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Lumber']] );

has ore => ( is => 'ro',
	     isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Ore']] );

has grain => ( is => 'ro',
	       isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Grain']] );

has wool => ( is => 'ro',
	      isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Wool']] );

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

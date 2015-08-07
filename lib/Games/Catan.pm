package Games::Catan;

use Moo;
use Types::Standard qw( Enum InstanceOf ArrayRef );

has num_players => ( is => 'ro',
		     isa => Enum[qw( 2 3 4 )],
		     required => 0,
		     default => 4 );

has type => ( is => 'ro',
	      isa => Enum[qw( beginner )],
	      required => 0,
	      default => 'beginner' );

has board => ( is => 'ro',
	       isa => InstanceOf['Games::Catan::Board'],
	       required => 0 );

has players => ( is => 'ro',
		 isa => ArrayRef[InstanceOf['Games::Catan::Player']],
		 required => 0 );

has bank => ( is => 'ro',
	      isa => InstanceOf['Games::Catan::Bank'],
	      required => 0 );

sub BUILD {

  my ( $self ) = @_;

  # setup the game board
  my $board = Games::Catan::Board->new();
  $self->board( $board );

  # create the players
  my $colors = [qw( white red blue orange )];

  for ( my $i = 0; $i < $self->num_players; $i++ ) {

    push( @{$self->players }, Games::Catan::Player->new( color => $colors->[$i] ) );
  }

  # initialize the bank
  my $bank = Games::Catan::Bank->new();

  $self->bank( $bank );
}

1;

package Games::Catan;

use Moo;
use Types::Standard qw( Enum InstanceOf ConsumerOf ArrayRef );

use Games::Catan::Board;
use Games::Catan::Player;
use Games::Catan::Bank;
use Games::Catan::SpecialCard::LongestRoad;
use Games::Catan::SpecialCard::LargestArmy;

use Data::Dumper;

has num_players => ( is => 'ro',
		     isa => Enum[qw( 3 4 )],
		     required => 0,
		     default => 4 );

has type => ( is => 'ro',
	      isa => Enum[qw( beginner )],
	      required => 0,
	      default => 'beginner' );

has board => ( is => 'rw',
	       isa => InstanceOf['Games::Catan::Board'],
	       required => 0 );

has players => ( is => 'rw',
		 isa => ArrayRef[InstanceOf['Games::Catan::Player']],
		 required => 0 );

has bank => ( is => 'rw',
	      isa => InstanceOf['Games::Catan::Bank'],
	      required => 0 );

has development_cards => ( is => 'rw',
			   isa => ArrayRef[ConsumerOf['Games::Catan::DevelopmentCard']],
			   required => 0 );

has special_cards => ( is => 'rw',
		       isa => ArrayRef[ConsumerOf['Games::Catan::SpecialCard']],
		       required => 0 );

sub BUILD {

  my ( $self ) = @_;

  $self->setup();
}

sub setup {

  my ( $self ) = @_;
 
  # create the players
  $self->players( [] );

  my $colors = [qw( white red blue orange )];

  for ( my $i = 0; $i < $self->num_players; $i++ ) {

    push( @{$self->players }, Games::Catan::Player->new( game => $self, color => $colors->[$i] ) );
  }

  # initialize the bank
  my $bank = Games::Catan::Bank->new();
  $self->bank( $bank );

  # create the special largest army and longest road cards
  my $longest_road = Games::Catan::SpecialCard::LongestRoad->new( game => $self );
  my $largest_army = Games::Catan::SpecialCard::LargestArmy->new( game => $self );

  $self->special_cards( [$longest_road, $largest_army] );

  # setup the game board
  my $board = Games::Catan::Board->new( game => $self );
  $self->board( $board );
}

1;

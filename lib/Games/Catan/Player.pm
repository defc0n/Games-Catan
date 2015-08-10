package Games::Catan::Player;

use Moo;
use Types::Standard qw( Enum ArrayRef InstanceOf ConsumerOf );

use Games::Catan::Building::Settlement;
use Games::Catan::Building::City;
use Games::Catan::Road;

has game => ( is => 'ro',
	      isa => InstanceOf['Games::Catan'],
	      required => 1 );

has color => ( is => 'ro',
	       isa => Enum[qw( white red blue orange )],
	       required => 1 );

has settlements => ( is => 'ro',
		     isa => ArrayRef[InstanceOf['Games::Catan::Building::Settlement']],
		     required => 0,
		     default => sub { [] } );

has cities => ( is => 'ro',
		isa => ArrayRef[InstanceOf['Games::Catan::Building::City']],
		required => 0,
		default => sub { [] } );

has roads => ( is => 'ro',
	       isa => ArrayRef[InstanceOf['Games::Catan::Road']],
	       required => 0,
	       default => sub { [] } );

has resource_cards => ( is => 'ro',
			isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard']],
			required => 0,
			default => sub { [] } );

has development_cards => ( is => 'ro',
			   isa => ArrayRef[ConsumerOf['Games::Catan::DevelopmentCard']],
			   required => 0,
			   default => sub { [] } );

has special_cards => ( is => 'ro',
		       isa => ArrayRef[ConsumerOf['Games::Catan::SpecialCard']],
		       required => 0,
		       default => sub { [] } );

sub BUILD {

  my ( $self ) = @_;

  # give them all their initial settlements, cities, and road pieces
  for ( 1 .. 5 ) {

    push( @{$self->settlements}, Games::Catan::Building::Settlement->new( player => $self ) );									  
  }

  for ( 1 .. 4 ) {

    push( @{$self->cities}, Games::Catan::Building::City->new( player => $self ) );
  }

  for ( 1 .. 15 ) {

    push( @{$self->roads}, Games::Catan::Road->new( player => $self ) );
  }
}

### public methods ###

sub get_score {

  my ( $self ) = @_;

  my $board = $self->board;
  
  my $score = 0;

  # first, figure out their score for buildings on the board
  $score += $self->_get_building_score();

  # determine score from any victory cards
  $score += $self->_get_victory_card_score();

  # last, determine their score from any played development cards
  $score += $self->_get_development_card_score();

  return $score;
}

### private methods ###

sub _get_building_score {

  my ( $self ) = @_;

  my $score = 0;

  my $player_buildings = $self->board->get_buildings( player => $self );

  foreach my $player_building ( @$player_buildings ) {

    $score += $player_building->num_points;
  }

  return $score;
}

sub _get_victory_card_score {

  my ( $self ) = @_;

  my $score = 0;

  my $victory_cards = $self->board->victory_cards;

  foreach my $victory_card ( @$victory_cards ) {

    # skip it if this victory card doesn't apply to this player
    next if ( !$victory_card->determine_player->color ne $self->color );

    $score += $victory_card->num_points;
  }

  return $score;
}

sub _get_development_card_score {

  my ( $self ) = @_;

  my $score = 0;

  my $development_cards = $self->development_cards;

  foreach my $development_card ( @$development_cards ) {

    # skip it if it hasn't been played yet
    next if ( !$development_card->played );

    $score += $development_card->num_points;
  }

  return $score;
}
		
1;

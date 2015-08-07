package Games::Catan::Player;

use Moo;
use Types::Standard qw( Str );

has board => ( is => 'ro',
	       isa => 'Games::Catan::Board',
	       required => 1 );

has color => ( is => 'ro',
	       isa => Str,
	       required => 1 );

has resource_cards => ( is => 'ro',
			isa => 'Games::Catan::ResourceCard',
			required => 0,
			default => sub { [] } );

has development_cards => ( is => 'ro',
			   isa => 'Games::Catan::DevelopmentCard',
			   required => 0,
			   default => sub { [] } );

has victory_cards => ( is => 'ro',
		       isa => 'Games::Catan::VictoryCard',
		       required => 0,
		       default => sub { [] } );

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

  my $victory_cards = $self->victory_cards;

  foreach my $victory_card ( @$victory_cards ) {

    $score += $victory_card->num_points;
  }

  return $score;
}

sub _get_development_card_score {

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

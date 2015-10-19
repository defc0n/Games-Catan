package Games::Catan::Player;

use Moo::Role;
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

has settlements => ( is => 'rw',
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

#has resource_cards => ( is => 'ro',
#                        isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard']],
#                        required => 0,
#                        default => sub { [] } );

has brick => ( is => 'ro',
	       isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Brick']],
	       required => 0,
	       default => sub { [] } );

has lumber => ( is => 'ro',
	       isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Lumber']],
	       required => 0,
	       default => sub { [] } );

has wool => ( is => 'ro',
	       isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Wool']],
	      required => 0,
	      default => sub { [] } );

has grain => ( is => 'ro',
	       isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Grain']],
	       required => 0,
	       default => sub { [] } );

has ore => ( is => 'ro',
	     isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Ore']],
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

sub place_first_settlement {

    die( "Method must be implemented." );
}

sub place_second_settlement {

    die( "Method must be implemented." );
}

sub take_turn {

    die( "Method must be implemented." );
}

sub activate_robber {

    die( "Method must be implemented." );
}

sub get_score {

    my ( $self ) = @_;

    my $board = $self->game->board;

    my $score = 0;

    # figure out their score from their buildings on the board
    $score += $self->_get_building_score();

    # determine their score from any victory points from development cards
    $score += $self->_get_development_card_score();

    # see if they have any victory points from special cards (longest road/largest army)
    $score += $self->_get_special_card_score();

    return $score;
}

sub can_afford {

    my ( $self, $item ) = @_;

    my $cost = $item->cost;

    return 0 if ( @{$self->brick} < $cost->brick );
    return 0 if ( @{$self->lumber} < $cost->lumber );
    return 0 if ( @{$self->wool} < $cost->wool );
    return 0 if ( @{$self->grain} < $cost->grain );
    return 0 if ( @{$self->ore} < $cost->ore );

    if ( $cost->settlements > 0 ) {
	
	my $settlements = $self->get_played_settlements();
	
	return 0 if ( @$settlements < $cost->settlements );
    }
    
    return 1;
}

sub buy {

    my ( $self, $item, $location, $location2 ) = @_;

    my $cost = $item->cost;

    my @brick = splice( @{$self->brick}, 0, $cost->brick );
    my @lumber = splice( @{$self->lumber}, 0, $cost->lumber );
    my @wool = splice( @{$self->wool}, 0, $cost->wool );
    my @grain = splice( @{$self->grain}, 0, $cost->grain );
    my @ore = splice( @{$self->ore}, 0, $cost->ore );

    push( @{$self->game->bank->brick}, @brick );
    push( @{$self->game->bank->lumber}, @lumber );
    push( @{$self->game->bank->wool}, @wool );
    push( @{$self->game->bank->grain}, @grain );
    push( @{$self->game->bank->ore}, @ore );

    # if we're upgrading a settlement to a city, we need to know which settlement, and we get it back in our pile
    if ( $item->isa( 'Games::Catan::Building::City' ) ) {

	my $settlement = $self->game->board->graph->get_vertex_attribute( $location, 'building' );
	$self->game->board->graph->delete_vertex_attribute( $location, 'building' );

	push( @{$self->settlements}, $settlement );

	my $city = pop( @{$self->cities} );
	$self->game->board->set_vertex_attribute( $location, 'building', $city );
    }

    elsif ( $item->isa( 'Games::Catan::Building::Settlement' ) ) {

	my $settlement = pop( @{$self->settlements} );
	$self->game->board->graph->set_vertex_attribute( $location, 'building', $settlement );
    }

    elsif ( $item->isa( 'Games::Catan::Road' ) ) {

	my $road = pop( @{$self->roads} );
	$self->game->board->graph->set_edge_attribute( $location, $location2, 'road', $road );
    }

    elsif ( $item->isa( 'Games::Catan::DevelopmentCard' ) ) {

	my $development_card = pop( @{$self->game->development_cards} );
	push( @{$self->development_cards}, $development_card );
    }

    $self->game->check_winner();
}

sub get_played_settlements {

    my ( $self ) = @_;
   
    my $graph = $self->game->board->graph;
    my @vertices = $graph->vertices;

    my $settlements = [];

    foreach my $vertex ( @vertices ) {

	next if !$graph->has_vertex_attribute( $vertex, 'building' );

	my $building = $graph->get_vertex_attribute( $vertex, 'building' );

	next if !$building->isa( 'Games::Catan::Building::Settlement' );

	my $player = $building->player;

	next if ( $player->color ne $self->color );

	push( @$settlements, $building );
    }

    return $settlements;
}

sub steal_resource_card {

    my ( $self ) = @_;

    my $resource_cards = $self->get_resource_cards();

    my $i = int( rand( @$resource_cards ) );
    my $card = $resource_cards->[$i];

    if ( $card->isa( 'Games::Catan::ResourceCard::Brick' ) ) {

	return pop( @{$self->brick} );
    }

    elsif ( $card->isa( 'Games::Catan::ResourceCard::Lumber' ) ) {

	return pop( @{$self->lumber} );
    }

    elsif ( $card->isa( 'Games::Catan::ResourceCard::Wool' ) ) {

	return pop( @{$self->wool} );
    }

    elsif ( $card->isa( 'Games::Catan::ResourceCard::Grain' ) ) {

	return pop( @{$self->grain} );
    }

    elsif ( $card->isa( 'Games::Catan::ResourceCard::Ore' ) ) {

	return pop( @{$self->ore} );
    }
    
}

sub get_resource_cards {

    my ( $self ) = @_;

    my @cards = ( @{$self->brick}, @{$self->lumber}, @{$self->wool}, @{$self->grain}, @{$self->ore} );

    return \@cards;
}

### private methods ###

sub _get_building_score {

    my ( $self ) = @_;

    my $score = 0;

    my @vertices = $self->game->board->graph->vertices;
    
    foreach my $vertex ( @vertices ) {

	my $building = $self->game->board->graph->get_vertex_attribute( $vertex, 'building' );

	next if !$building;

	my $player = $building->player;

	# not our building
	next if ( $self->color ne $player->color );

        $score += $building->num_points;
    }

    return $score;
}

sub _get_development_card_score {

    my ( $self ) = @_;

    my $score = 0;

    my $development_cards = $self->development_cards;

    foreach my $development_card ( @$development_cards ) {

        $score += $development_card->num_points;
    }

    return $score;
}

sub _get_special_card_score {

    my ( $self ) = @_;

    my $score = 0;

    my $special_cards = $self->special_cards;

    foreach my $special_card ( @$special_cards ) {

        $score += $special_card->num_points;
    }

    return $score;
}

1;

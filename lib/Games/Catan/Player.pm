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

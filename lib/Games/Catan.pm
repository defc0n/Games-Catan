package Games::Catan;

use Moo;
use Types::Standard qw( Enum InstanceOf ConsumerOf ArrayRef Int );

use Games::Catan::Board;
use Games::Catan::Dice;
use Games::Catan::Bank;
use Games::Catan::Player;
use Games::Catan::Player::Stupid;

use Games::Catan::SpecialCard::LongestRoad;
use Games::Catan::SpecialCard::LargestArmy;

use Games::Catan::DevelopmentCard::Knight;
use Games::Catan::DevelopmentCard::Monopoly;
use Games::Catan::DevelopmentCard::RoadBuilding;
use Games::Catan::DevelopmentCard::YearOfPlenty;
use Games::Catan::DevelopmentCard::Chapel;
use Games::Catan::DevelopmentCard::GreatHall;
use Games::Catan::DevelopmentCard::Library;
use Games::Catan::DevelopmentCard::University;
use Games::Catan::DevelopmentCard::Market;

use List::Util qw( shuffle );

use Data::Dumper;

our $VERSION = '0.0.1';

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

has dice => ( is => 'ro',
              isa => InstanceOf['Games::Catan::Dice'],
              required => 0,
              default => sub { Games::Catan::Dice->new() } );

has players => ( is => 'rw',
                 isa => ArrayRef[ConsumerOf['Games::Catan::Player']],
                 required => 0 );

has turn => ( is => 'rw',
              isa => Int,
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

has winner => ( is => 'rw',
                isa => ConsumerOf['Games::Catan::Player'],
                required => 0 );

### public methods ###

sub play {

    my ( $self ) = @_;

    # set up a new game board etc.
    $self->_setup();

    # randomly determine which player goes first and mark it as their turn
    $self->turn( int( rand( $self->num_players ) ) );

    # get the players first settlements + roads
    $self->_get_first_settlements();

    # player who went last goes first this round
    $self->turn( ( $self->turn - 1 ) % $self->num_players );

    # get the players second settlements + roads
    $self->_get_second_settlements();

    # distribute initial resource cards
    $self->_distribute_resource_cards();

    # person who went first will also roll first
    $self->turn( ( $self->turn + 1 ) % $self->num_players );

    # continue playing until there is a winner
    while ( !$self->winner ) {

        # whose turn is it?
        my $player = $self->players->[$self->turn];

        # tell the player to take their turn
        $player->take_turn();

        # it will be the next player's turn
        $self->turn( ( $self->turn + 1 ) % $self->num_players );
    }

    return $self->winner;
}

sub roll {

    my ( $self, $player ) = @_;

    my $roll = $self->dice->roll();

    # did they activate the robber?
    if ( $roll == 7 ) {

        # any player with more than 7 cards must discard half of them
        foreach my $player ( @{$self->players} ) {

            if ( @{$player->get_resource_cards()} > 7 ) {

                $player->discard_robber_cards();
            }
        }

        # player who rolled a 7 must choose new robber location and rob from someone there
        $player->activate_robber();
    }

    # distribute resources accordingly based upon the roll
    else {

        $self->_distribute_resource_cards( $roll );
    }
}

sub check_winner {

    my ( $self ) = @_;

    my $players = $self->players;

    foreach my $player ( @$players ) {

	if ( $player->get_score() > 10 ) {

	    $self->winner( $player );
	    return;
	}
    }
}

### private methods ###

sub _get_first_settlements {

    my ( $self ) = @_;

    for ( 1 .. $self->num_players ) {

        my $player = $self->players->[$self->turn];
        $player->place_first_settlement();

        # set the turn for the next player
        $self->turn( ( $self->turn + 1 ) % $self->num_players );
    }
}

sub _get_second_settlements {

    my ( $self ) = @_;

    for ( 1 .. $self->num_players ) {

        my $player = $self->players->[$self->turn];
        $player->place_second_settlement();

        # set the turn for the next player (going back in the opposite direction)
        $self->turn( ( $self->turn - 1 ) % $self->num_players );
    }
}

sub _distribute_resource_cards {

    my ( $self, $roll ) = @_;

    my $tiles = $self->board->tiles;

    foreach my $tile ( @$tiles ) {

        my $terrain = $tile->terrain;
        my $vertices = $tile->vertices;
        my $number = $tile->number;

        # no resources for desert tiles
        next if ( $terrain eq 'desert' );

        # didn't roll the number of this tile
        next if ( $roll && $roll != $number );

        foreach my $vertex ( @$vertices ) {

            my $building = $self->board->graph->get_vertex_attribute( $vertex, 'building' );

            # no city/settlement here
            next if !$building;

            my $num_points = $building->num_points;

            my $player = $building->player;

            for ( 1 .. $num_points ) {

                if ( $terrain eq 'hills' ) {

                    my $brick = pop( @{$self->bank->brick} );

                    next if !defined $brick;

                    push( @{$player->brick}, $brick );
                }

                elsif ( $terrain eq 'forest' ) {

                    my $lumber = pop( @{$self->bank->lumber} );

                    next if !defined $lumber;

                    push( @{$player->lumber}, $lumber );
                }

                elsif ( $terrain eq 'mountains' ) {

                    my $ore = pop( @{$self->bank->ore} );

                    next if !defined $ore;

                    push( @{$player->ore}, $ore );
                }

                elsif ( $terrain eq 'fields' ) {

                    my $grain = pop( @{$self->bank->grain} );

                    next if !defined $grain;

                    push( @{$player->grain}, $grain );
                }

                elsif ( $terrain eq 'pasture' ) {

                    my $wool = pop( @{$self->bank->wool} );

                    next if !defined $wool;

                    push( @{$player->wool}, $wool );
                }
            }
        }
    }
}

sub _setup {

    my ( $self ) = @_;

    # create the players
    $self->players( [] );

    my $colors = [qw( white red blue orange )];

    for ( my $i = 0; $i < $self->num_players; $i++ ) {

        # only support stupid AI players for now
        push( @{$self->players}, Games::Catan::Player::Stupid->new( game => $self, color => $colors->[$i] ) );
    }

    # initialize the bank
    my $bank = Games::Catan::Bank->new();
    $self->bank( $bank );

    # create the development cards
    $self->development_cards( [] );

    # 14 knight cards
    for ( 1 .. 14 ) {

        push( @{$self->development_cards}, Games::Catan::DevelopmentCard::Knight->new( game => $self ) );
    }

    # 2 monopoly cards
    for ( 1 .. 2 ) {

        push( @{$self->development_cards}, Games::Catan::DevelopmentCard::Monopoly->new( game => $self ) );
    }

    # 2 road building cards
    for ( 1 .. 2 ) {

        push( @{$self->development_cards}, Games::Catan::DevelopmentCard::RoadBuilding->new( game => $self ) );
    }

    # 2 year of plenty cards
    for ( 1 .. 2 ) {

        push( @{$self->development_cards}, Games::Catan::DevelopmentCard::YearOfPlenty->new( game => $self ) );
    }

    # the 5 different victory point cards
    push( @{$self->development_cards}, Games::Catan::DevelopmentCard::Chapel->new( game => $self ) );
    push( @{$self->development_cards}, Games::Catan::DevelopmentCard::GreatHall->new( game => $self ) );
    push( @{$self->development_cards}, Games::Catan::DevelopmentCard::Library->new( game => $self ) );
    push( @{$self->development_cards}, Games::Catan::DevelopmentCard::University->new( game => $self ) );
    push( @{$self->development_cards}, Games::Catan::DevelopmentCard::Market->new( game => $self ) );

    # shuffle the development card deck
    my @shuffled = shuffle( @{$self->development_cards} );
    $self->development_cards( \@shuffled );

    # create the special largest army and longest road cards
    my $longest_road = Games::Catan::SpecialCard::LongestRoad->new( game => $self );
    my $largest_army = Games::Catan::SpecialCard::LargestArmy->new( game => $self );

    $self->special_cards( [$longest_road, $largest_army] );

    # setup the game board
    my $board = Games::Catan::Board->new( game => $self );
    $self->board( $board );
}

1;

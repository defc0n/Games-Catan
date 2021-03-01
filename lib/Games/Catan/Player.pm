package Games::Catan::Player;

use Moo::Role;
use Types::Standard qw( Enum ArrayRef InstanceOf ConsumerOf Int Maybe );

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

has cities => ( is => 'rw',
                isa => ArrayRef[InstanceOf['Games::Catan::Building::City']],
                required => 0,
                default => sub { [] } );

has roads => ( is => 'rw',
               isa => ArrayRef[InstanceOf['Games::Catan::Road']],
               required => 0,
               default => sub { [] } );

has brick => ( is => 'rw',
               isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Brick']],
               required => 0,
               default => sub { [] } );

has lumber => ( is => 'rw',
                isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Lumber']],
                required => 0,
                default => sub { [] } );

has wool => ( is => 'rw',
              isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Wool']],
              required => 0,
              default => sub { [] } );

has grain => ( is => 'rw',
               isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Grain']],
               required => 0,
               default => sub { [] } );

has ore => ( is => 'rw',
             isa => ArrayRef[InstanceOf['Games::Catan::ResourceCard::Ore']],
             required => 0,
             default => sub { [] } );

has development_cards => ( is => 'rw',
                           isa => ArrayRef[ConsumerOf['Games::Catan::DevelopmentCard']],
                           required => 0,
                           default => sub { [] } );

has largest_army => ( is => 'rw',
                      isa => Maybe[InstanceOf['Games::Catan::SpecialCard::LargestArmy']],
                      required => 0,
                      clearer => 1 );

has longest_road => ( is => 'rw',
                      isa => Maybe[InstanceOf['Games::Catan::SpecialCard::LongestRoad']],
                      required => 0,
                      clearer => 1 );

has army_size => ( is => 'rw',
                   isa => Int,
                   required => 0,
                   default => 0,
                   trigger => 1 );

has brick_ratio => ( is => 'rw',
                     isa => Enum[qw( 2 3 4 )],
                     required => 0,
                     default => 4 );

has lumber_ratio => ( is => 'rw',
                      isa => Enum[qw( 2 3 4 )],
                      required => 0,
                      default => 4 );

has wool_ratio => ( is => 'rw',
                    isa => Enum[qw( 2 3 4 )],
                    required => 0,
                    default => 4 );

has grain_ratio => ( is => 'rw',
                     isa => Enum[qw( 2 3 4 )],
                     required => 0,
                     default => 4 );

has ore_ratio => ( is => 'rw',
                   isa => Enum[qw( 2 3 4 )],
                   required => 0,
                   default => 4 );

has logger => ( is => 'ro',
                isa => InstanceOf['Log::Any::Proxy'],
                required => 0,
                default => sub { Log::Any->get_logger() } );

sub BUILD {

    my ( $self ) = @_;

    # give them all their initial settlements, cities, and road pieces
    for ( 1 .. 5 ) {

        push( @{$self->settlements}, Games::Catan::Building::Settlement->new( game => $self->game, player => $self ) );
    }

    for ( 1 .. 4 ) {

        push( @{$self->cities}, Games::Catan::Building::City->new( game => $self->game, player => $self ) );
    }

    for ( 1 .. 15 ) {

        push( @{$self->roads}, Games::Catan::Road->new( game => $self->game, player => $self ) );
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

sub offer_trade {

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

sub upgrade_settlement {

    my ( $self, $intersection ) = @_;

    $self->logger->info( $self->color . " upgraded a settlement to city." );

    # grab a city we'll upgrade it to
    my $city = shift( @{$self->cities} );

    die( "No more cities" ) if !$city;

    # grab the settlement we're replacing/upgrading
    my $settlement = $self->game->board->graph->get_vertex_attribute( $intersection, 'building' );
    $self->game->board->graph->delete_vertex_attribute( $intersection, 'building' );

    die( "No settlement found" ) if ( !$settlement );

    # give settlement back to the player
    push( @{$self->settlements}, $settlement );

    # place city on the board in place of prior settlement
    $self->game->board->graph->set_vertex_attribute( $intersection, 'building', $city );

    # pay the bank
    $self->_buy( $city );
}

sub build_settlement {

    my ( $self, $intersection ) = @_;

    $self->logger->info( $self->color . " built a settlement." );

    # grab one of our settlements to build on the board
    my $settlement = shift( @{$self->settlements} );

    die( "No more settlements" ) if !$settlement;

    # place it on the board
    $self->game->board->graph->set_vertex_attribute( $intersection, 'building', $settlement );

    # pay the bank
    $self->_buy( $settlement );

    # its possible this could affect who has the longest road
    $self->game->update_longest_road();

    # its possible this could affect the players trade ratios
    $self->game->update_trade_ratios();
}

sub build_road {

    my ( $self, $path ) = @_;

    $self->logger->info( $self->color . " built a road." );

    # grab one of our roads to build on the board
    my $road = shift( @{$self->roads} );

    die( "No more roads" ) if !$road;

    my ( $u, $v ) = @$path;

    # place it on the board
    $self->game->board->graph->set_edge_attribute( $u, $v, 'road', $road );

    # pay the bank
    $self->_buy( $road );

    # its possible this could affect who has the longest road
    $self->game->update_longest_road();
}

sub buy_development_card {

    my ( $self ) = @_;

    $self->logger->info( $self->color . " bought a development card." );

    # grab one of the game dev cards
    my $development_card = shift( @{$self->game->development_cards} );

    die( "No more development cards" ) if !$development_card;

    # give it to the player
    $development_card->player( $self );
    push( @{$self->development_cards}, $development_card );

    # pay the bank
    $self->_buy( $development_card );
}

sub request_player_trade {

    my ( $self, %args ) = @_;

    my $to = $args{'to'};
    my $deal = $args{'deal'};

    # trade requests can only come from the current players turn, or
    # from another player to the current player's turn
    if ( !$self->is_our_turn() ) {

        my $turn = $self->game->turn;
        my $turn_player = $self->game->players->[$turn];

        if ( $to->color ne $turn_player->color ) {

            die( "Player not eligible for trade" );
        }
    }

    # offer the trade to the player and see if they accept
    my $accepted = $to->offer_trade( from => $self,
                                     deal => $deal );

    # deal not accepted, do nothing
    return if !$accepted;

    $self->logger->info( "trade deal accepted from " . $self->color . " to " . $to->color );

    # exchange all of the resources as part of the trade deal
    for ( 1 .. $deal->offer_brick ) {

        my $brick = shift( @{$self->brick} );

        die( "No brick to offer" ) if !$brick;

        push( @{$to->brick}, $brick );
    }

    for ( 1 .. $deal->offer_lumber ) {

        my $lumber = shift( @{$self->lumber} );

        die( "No lumber to offer" ) if !$lumber;

        push( @{$to->lumber}, $lumber );
    }

    for ( 1 .. $deal->offer_wool ) {

        my $wool = shift( @{$self->wool} );

        die( "No wool to offer" ) if !$wool;

        push( @{$to->wool}, $wool );
    }

    for ( 1 .. $deal->offer_grain ) {

        my $grain = shift( @{$self->grain} );

        die( "No grain to offer" ) if !$grain;

        push( @{$to->grain}, $grain );
    }

    for ( 1 .. $deal->offer_ore ) {

        my $ore = shift( @{$self->ore} );

        die( "No ore to offer" ) if !$ore;

        push( @{$to->ore}, $ore );
    }

    for ( 1 .. $deal->request_brick ) {

        my $brick = shift( @{$to->brick} );

        die( "No brick to request" ) if !$brick;

        push( @{$self->brick}, $brick );
    }

    for ( 1 .. $deal->request_lumber ) {

        my $lumber = shift( @{$to->lumber} );

        die( "No lumber to request" ) if !$lumber;

        push( @{$self->lumber}, $lumber );
    }

    for ( 1 .. $deal->request_wool ) {

        my $wool = shift( @{$to->wool} );

        die( "No wool to request" ) if !$wool;

        push( @{$self->wool}, $wool );
    }

    for ( 1 .. $deal->request_grain ) {

        my $grain = shift( @{$to->grain} );

        die( "No grain to request" ) if !$grain;

        push( @{$self->grain}, $grain );
    }

    for ( 1 .. $deal->request_ore ) {

        my $ore = shift( @{$to->ore} );

        die( "No ore to request" ) if !$ore;

        push( @{$self->ore}, $ore );
    }

    return 1;
}

sub request_bank_trade {

    my ( $self, %args ) = @_;

    my $deal = $args{'deal'};

    my @resources = ( 'brick', 'lumber', 'wool', 'grain', 'ore' );

    # for a bank trading transaction, only allow offering 1 resource type for
    # 1 other resource type and not multiple
    my $offer_resource;
    my $offer_num;
    my $request_resource;
    my $request_num;

    foreach my $resource ( @resources ) {

        my $offer = "offer_$resource";
        my $request = "request_$resource";

        my $this_offer_num = $deal->$offer();
        my $this_request_num = $deal->$request();

        # already found a different resource they are offering
        die( "Invalid transaction" ) if ( defined( $offer_resource ) && $this_offer_num );

        # already found a different resource they are requesting
        die( "Invalid transaction" ) if ( defined( $request_resource ) && $this_request_num );

        # this is the resource they are offering
        if ( $this_offer_num ) {

            $offer_resource = $resource;
            $offer_num = $this_offer_num;
        }

        # this is the resource they are requesting
        if ( $this_request_num ) {

            $request_resource = $resource;
            $request_num = $this_request_num;
        }
    }

    # couldn't find any resources they are offering or requesting
    die( "Invalid transaction" ) if !$offer_resource;
    die( "Invalid transaction" ) if !$request_resource;

    # dont allow requesting and offering the same resource since that doesn't make sense
    die( "Invalid transaction" ) if ( $offer_resource eq $request_resource );

    # whats the trade ratio the player has for this resource
    my $ratio_name = $offer_resource . "_ratio";
    my $ratio = $self->$ratio_name();

    # verify what they are offering and requesting has the correct ratio
    die( "Invalid transaction" ) if ( $request_num * $ratio != $offer_num );

    # transaction is sound, exchange resources between player & bank accordingly
    for ( 1 .. $offer_num ) {

        my $resource = shift( @{$self->$offer_resource()} );

        die( "No more $offer_resource to offer" ) if !$resource;

        push( @{$self->game->bank->$offer_resource()}, $resource );
    }

    for ( 1 .. $request_num ) {

        my $resource = shift( @{$self->game->bank->$request_resource()} );

        die( "No more $request_resource to request" ) if !$resource;

        push( @{$self->$request_resource()}, $resource );
    }

    $self->logger->info( $self->color . " exchanged $offer_num $offer_resource for $request_num $request_resource with bank" );
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

sub get_played_roads {

    my ( $self ) = @_;

    my $graph = $self->game->board->graph;
    my @edges = $graph->edges;

    my $roads = [];

    foreach my $edge ( @edges ) {

        my ( $u, $v ) = @$edge;

        next if !$graph->has_edge_attribute( $u, $v, 'road' );

        my $road = $graph->get_edge_attribute( $u, $v, 'road' );
        my $player = $road->player;

        next if ( $player->color ne $self->color );

        push( @$roads, $road );
    }

    return $roads;
}

sub get_possible_road_paths {

    my ( $self ) = @_;

    my $graph = $self->game->board->graph;
    my @paths = $graph->edges;

    my $valid_paths = [];

    foreach my $path ( @paths ) {

        my ( $u, $v ) = @$path;

        # make sure there is not already a road on this path
        next if ( $graph->has_edge_attribute( $u, $v, 'road' ) );

        # make sure we have a road adjacent to this path
        my @adjacent_paths = ( $graph->edges_at( $u ),
                               $graph->edges_at( $v ) );

        my $found_adjacent = 0;

        foreach my $adjacent_path ( @adjacent_paths ) {

            my ( $u2, $v2 ) = @$adjacent_path;

            # this is the same path we're trying to build on
            next if ( ( $u == $u2 && $v == $v2 ) || ( $u == $v2 && $v == $u2 ) );

            # no adjacent road built here
            next if ( !$graph->has_edge_attribute( $u2, $v2, 'road' ) );

            my $adjacent_road = $graph->get_edge_attribute( $u2, $v2,'road' );

            # a different player's road, not ours
            next if ( $adjacent_road->player->color ne $self->color );

            $found_adjacent = 1;
            last;
        }

        push( @$valid_paths, $path ) if $found_adjacent;
    }

    return $valid_paths;
}

sub get_possible_settlement_intersections {

    my ( $self ) = @_;

    # can only place their settlements on intersections their roads are attached to
    my @paths = $self->game->board->graph->edges;

    my $intersections = {};

    foreach my $path ( @paths ) {

        my ( $u, $v ) = @$path;

        # no road built on this path
        next if ( !$self->game->board->graph->has_edge_attribute( $u, $v, 'road' ) );

        my $road = $self->game->board->graph->get_edge_attribute( $u, $v, 'road' );

        # not this player's road
        next if ( $road->player->color ne $self->color );

        # make sure there is not already a building at these vertices
        if ( !$self->game->board->graph->has_vertex_attribute( $u, 'building' ) ) {

            $intersections->{$u} = 1;
        }

        if ( !$self->game->board->graph->has_vertex_attribute( $v, 'building' ) ) {

            $intersections->{$v} = 1;
        }
    }

    # remove those intersections which violate the distance rule (no settlement can be one hop away from another)
    foreach my $intersection ( keys %$intersections ) {

        my @neighbors = $self->game->board->graph->neighbors( $intersection );

        # see if any of its neighbors have a building already
        foreach my $neighbor ( @neighbors ) {

            # this intersection would violate the distance rule
            if ( $self->game->board->graph->has_vertex_attribute( $neighbor, 'building' ) ) {

                delete( $intersections->{$intersection} );
                last;
            }
        }
    }

    my @valid_intersections = keys( %$intersections );

    return \@valid_intersections;
}

sub steal_resource_card {

    my ( $self ) = @_;

    my $resource_cards = $self->get_resource_cards();

    my $i = int( rand( @$resource_cards ) );
    my $card = $resource_cards->[$i];

    $self->logger->info( ref( $card ) . " stolen from " . $self->color );

    if ( $card->isa( 'Games::Catan::ResourceCard::Brick' ) ) {

        return shift( @{$self->brick} );
    }

    elsif ( $card->isa( 'Games::Catan::ResourceCard::Lumber' ) ) {

        return shift( @{$self->lumber} );
    }

    elsif ( $card->isa( 'Games::Catan::ResourceCard::Wool' ) ) {

        return shift( @{$self->wool} );
    }

    elsif ( $card->isa( 'Games::Catan::ResourceCard::Grain' ) ) {

        return shift( @{$self->grain} );
    }

    elsif ( $card->isa( 'Games::Catan::ResourceCard::Ore' ) ) {

        return shift( @{$self->ore} );
    }
}

sub get_resource_cards {

    my ( $self ) = @_;

    my @cards = ( @{$self->brick}, @{$self->lumber}, @{$self->wool}, @{$self->grain}, @{$self->ore} );

    return \@cards;
}

sub is_our_turn {

    my ( $self ) = @_;

    # whos turn is it
    my $current_turn = $self->game->turn;
    my $player = $self->game->players->[$current_turn];

    # is that us?
    return $self->color eq $player->color;
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

    if ( $self->longest_road ) {

        $score += $self->longest_road->num_points;
    }

    if ( $self->largest_army ) {

        $score += $self->largest_army->num_points;
    }

    return $score;
}

sub _buy {

    my ( $self, $item ) = @_;

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
}

sub _trigger_army_size {

    my ( $self ) = @_;

    $self->logger->info( $self->color . " army size grows to " . $self->army_size );

    $self->game->update_largest_army();
}

1;

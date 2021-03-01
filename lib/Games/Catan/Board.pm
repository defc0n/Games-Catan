package Games::Catan::Board;

use Moo;
use Types::Standard qw( Enum ArrayRef InstanceOf );

use Graph::Undirected;

use Games::Catan::Harbor;
use Games::Catan::Robber;
use Games::Catan::Board::Tile;

use Storable qw( dclone );

no autovivification;

has game => ( is => 'ro',
              isa => InstanceOf['Games::Catan'],
              required => 1 );

has type => ( is => 'ro',
              isa => Enum[qw( beginner )],
              required => 0,
              default => 'beginner' );

has graph => ( is => 'rw',
               isa => InstanceOf['Graph::Undirected'],
               required => 0 );

has tiles => ( is => 'rw',
               isa => ArrayRef[InstanceOf['Games::Catan::Board::Tile']],
               required => 0 );

has robber => ( is => 'rw',
                isa => InstanceOf['Games::Catan::Robber'],
                required => 0 );

sub BUILD {

    my ( $self ) = @_;

    $self->graph( Graph::Undirected->new() );
    $self->tiles( [] );

    # create the edges/adjacencies between the vertices
    $self->graph->add_edge( 3, 0 );
    $self->graph->add_edge( 0, 4 );
    $self->graph->add_edge( 4, 1 );
    $self->graph->add_edge( 1, 5 );
    $self->graph->add_edge( 5, 2 );
    $self->graph->add_edge( 2, 6 );

    $self->graph->add_edge( 3, 7 );
    $self->graph->add_edge( 4, 8 );
    $self->graph->add_edge( 5, 9 );
    $self->graph->add_edge( 6, 10 );

    $self->graph->add_edge( 7, 12 );
    $self->graph->add_edge( 12, 8 );
    $self->graph->add_edge( 8, 13 );
    $self->graph->add_edge( 13, 9 );
    $self->graph->add_edge( 9, 14 );
    $self->graph->add_edge( 14, 10 );

    $self->graph->add_edge( 7, 11 );
    $self->graph->add_edge( 10, 15 );

    $self->graph->add_edge( 11, 16 );
    $self->graph->add_edge( 16, 22 );
    $self->graph->add_edge( 22, 17 );
    $self->graph->add_edge( 17, 23 );
    $self->graph->add_edge( 23, 18 );
    $self->graph->add_edge( 18, 24 );
    $self->graph->add_edge( 24, 19 );
    $self->graph->add_edge( 19, 25 );
    $self->graph->add_edge( 25, 20 );
    $self->graph->add_edge( 15, 20 );

    $self->graph->add_edge( 12, 17 );
    $self->graph->add_edge( 13, 18 );
    $self->graph->add_edge( 14, 19 );

    $self->graph->add_edge( 16, 21 );
    $self->graph->add_edge( 21, 27 );
    $self->graph->add_edge( 27, 33 );
    $self->graph->add_edge( 33, 28 );
    $self->graph->add_edge( 28, 34 );
    $self->graph->add_edge( 34, 29 );
    $self->graph->add_edge( 29, 35 );
    $self->graph->add_edge( 35, 30 );
    $self->graph->add_edge( 30, 36 );
    $self->graph->add_edge( 36, 31 );
    $self->graph->add_edge( 31, 37 );
    $self->graph->add_edge( 37, 32 );
    $self->graph->add_edge( 26, 32 );
    $self->graph->add_edge( 20, 26 );

    $self->graph->add_edge( 22, 28 );
    $self->graph->add_edge( 23, 29 );
    $self->graph->add_edge( 24, 30 );
    $self->graph->add_edge( 25, 31 );

    $self->graph->add_edge( 33, 38 );
    $self->graph->add_edge( 38, 43 );
    $self->graph->add_edge( 43, 39 );
    $self->graph->add_edge( 39, 44 );
    $self->graph->add_edge( 44, 40 );
    $self->graph->add_edge( 40, 45 );
    $self->graph->add_edge( 45, 41 );
    $self->graph->add_edge( 41, 46 );
    $self->graph->add_edge( 46, 42 );
    $self->graph->add_edge( 37, 42 );

    $self->graph->add_edge( 34, 39 );
    $self->graph->add_edge( 35, 40 );
    $self->graph->add_edge( 36, 41 );

    $self->graph->add_edge( 43, 47 );
    $self->graph->add_edge( 47, 51 );
    $self->graph->add_edge( 51, 48 );
    $self->graph->add_edge( 48, 52 );
    $self->graph->add_edge( 52, 49 );
    $self->graph->add_edge( 49, 53 );
    $self->graph->add_edge( 53, 50 );
    $self->graph->add_edge( 46, 50 );

    # create the 19 tiles, associated with their vertices
    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'mountains',
                                                           number => 10,
                                                           vertices => [0, 3, 4, 7, 8, 12] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'pasture',
                                                           number => 2,
                                                           vertices => [1, 4, 5, 8, 9, 13] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'forest',
                                                           number => 9,
                                                           vertices => [2, 5, 6, 9, 10, 14] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'fields',
                                                           number => 12,
                                                           vertices => [7, 11, 12, 16, 17, 22] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'hills',
                                                           number => 6,
                                                           vertices => [8, 12, 13, 17, 18, 23] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'pasture',
                                                           number => 4,
                                                           vertices => [9, 13, 14, 18, 19, 24] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'hills',
                                                           number => 10,
                                                           vertices => [10, 14, 15, 19, 20, 25] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'fields',
                                                           number => 9,
                                                           vertices => [16, 21, 22, 27, 28, 33] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'forest',
                                                           number => 11,
                                                           vertices => [17, 22, 23, 28, 29, 34] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'desert',
                                                           number => 7,
                                                           vertices => [18, 23, 24, 29, 30, 35] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'forest',
                                                           number => 3,
                                                           vertices => [19, 24, 25, 30, 31, 36] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'mountains',
                                                           number => 8,
                                                           vertices => [20, 25, 26, 31, 32, 37] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'forest',
                                                           number => 8,
                                                           vertices => [28, 33, 34, 38, 39, 43] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'mountains',
                                                           number => 3,
                                                           vertices => [29, 34, 35, 39, 40, 44] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'fields',
                                                           number => 4,
                                                           vertices => [30, 35, 36, 40, 41, 45] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'pasture',
                                                           number => 5,
                                                           vertices => [31, 36, 37, 41, 42, 46] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'hills',
                                                           number => 5,
                                                           vertices => [39, 43, 44, 47, 48, 51] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'fields',
                                                           number => 6,
                                                           vertices => [40, 44, 45, 48, 49, 52] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'pasture',
                                                           number => 11,
                                                           vertices => [41, 45, 46, 49, 50, 53] ) );

    # create the robber initially on the desert tile
    my $robber = Games::Catan::Robber->new( game => $self->game );

    $self->robber( $robber );

    $self->tiles->[9]->robber( $self->robber );

    # setup the harbors
    my $brick_harbor = Games::Catan::Harbor->new( brick_ratio => 2 );
    my $lumber_harbor = Games::Catan::Harbor->new( lumber_ratio => 2);
    my $wool_harbor = Games::Catan::Harbor->new( wool_ratio => 2 );
    my $grain_harbor = Games::Catan::Harbor->new( grain_ratio => 2 );
    my $ore_harbor = Games::Catan::Harbor->new( ore_ratio => 2 );

    my $generic_harbor = Games::Catan::Harbor->new( brick_ratio => 3,
                                                    lumber_ratio => 3,
                                                    wool_ratio => 3,
                                                    grain_ratio => 3,
                                                    ore_ratio => 3 );

    $self->graph->set_vertex_attribute( 33, 'harbor', $brick_harbor );
    $self->graph->set_vertex_attribute( 38, 'harbor', $brick_harbor );

    $self->graph->set_vertex_attribute( 11, 'harbor', $lumber_harbor );
    $self->graph->set_vertex_attribute( 16, 'harbor', $lumber_harbor );

    $self->graph->set_vertex_attribute( 46, 'harbor', $wool_harbor );
    $self->graph->set_vertex_attribute( 42, 'harbor', $wool_harbor );

    $self->graph->set_vertex_attribute( 1, 'harbor', $grain_harbor );
    $self->graph->set_vertex_attribute( 5, 'harbor', $grain_harbor );

    $self->graph->set_vertex_attribute( 10, 'harbor', $ore_harbor );
    $self->graph->set_vertex_attribute( 15, 'harbor', $ore_harbor );

    $self->graph->set_vertex_attribute( 3, 'harbor', $generic_harbor );
    $self->graph->set_vertex_attribute( 0, 'harbor', $generic_harbor );

    $self->graph->set_vertex_attribute( 26, 'harbor', $generic_harbor );
    $self->graph->set_vertex_attribute( 32, 'harbor', $generic_harbor );

    $self->graph->set_vertex_attribute( 47, 'harbor', $generic_harbor );
    $self->graph->set_vertex_attribute( 51, 'harbor', $generic_harbor );

    $self->graph->set_vertex_attribute( 52, 'harbor', $generic_harbor );
    $self->graph->set_vertex_attribute( 49, 'harbor', $generic_harbor );
}

sub move_robber {

    my ( $self, $tile ) = @_;

    # remove the robber from whatever title they currently are on
    foreach my $tile ( @{$self->tiles} ) {

        $tile->clear_robber();
    }

    # place the robber on the new tile
    $tile->robber( $self->robber );
}

sub place_settlement {

    my ( $self, %args ) = @_;

    my $settlement = $args{'settlement'};
    my $intersection = $args{'intersection'};

    # already a building here?
    if ( $self->graph->has_vertex_attribute( $intersection, 'building' ) ) {

        die( "Already a building at intersection $intersection." );
    }

    # place it on the board
    $self->graph->set_vertex_attribute( $intersection, 'building', $settlement );

    # set its intersection location
    $settlement->intersection( $intersection );
}

sub upgrade_settlement {

    my ( $self, $intersection ) = @_;

    # grab existing settlement at this location
    my $settlement = $self->graph->get_vertex_attribute( $intersection, 'building' );

    if ( !defined $settlement ) {

        die( "No building found at intersection $intersection." );
    }

    if ( !$settlement->isa( 'Games::Catan::Building::Settlement' ) ) {

        die( "Intersection $intersection does not have a settlement." );
    }

    # remove it from the board
    $self->graph->delete_vertex_attribute( $intersection, 'building' );

    # clear its intersection location
    $settlement->clear_intersection();

    # give the settlement back to the player
    push( @{$settlement->player->settlements}, $settlement );

    # grab one of their cities
    my $city = pop( @{$settlement->player->cities} );

    # set its intersection location
    $city->intersection( $intersection );

    # place it on the board
    $self->graph->set_vertex_attribute( $intersection, 'building', $city );
}

sub get_valid_settlement_intersections {

    my ( $self, $player ) = @_;

    # can only place their settlements on intersections their roads are attached to
    my @paths = $self->graph->edges;

    my $intersections = {};

    foreach my $path ( @paths ) {

        my ( $u, $v ) = @$path;

        # no road built on this path
        next if ( !$self->graph->has_edge_attribute( $u, $v, 'road' ) );

        my $road = $self->graph->get_edge_attribute( $u, $v, 'road' );

        # not this player's road
        next if ( $road->player->color ne $player->color );

        # both intersections of this road are potential settlement locations
        $intersections->{$u} = 1;
        $intersections->{$v} = 1;
    }

    # remove those intersections which violate the distance rule (no settlement can be one hop away from another)
    foreach my $intersection ( keys %$intersections ) {

        my @neighbors = $self->graph->neighbors( $intersection );

        foreach my $neighbor ( @neighbors ) {

            next if ( !$self->graph->has_vertex_attribute( $neighbor, 'building' ) );

            # this intersection would violate the distance rule
            delete( $intersections->{$intersection} );

            last;
        }
    }

    my @valid_intersections = keys( %$intersections );

    return \@valid_intersections;
}

sub get_longest_road {

    my ( $self, $player ) = @_;

    my @paths = $self->graph->edges;
    my @current_longest_road = ();

    # mark all road paths we traverse for this player
    my $found_paths = [];

    foreach my $path ( @paths ) {

        my ( $u, $v ) = @$path;

        # only bother starting from intersections that have a road built by this player
        next if ( !$self->graph->has_edge_attribute( $u, $v, 'road' ) );

        my $road = $self->graph->get_edge_attribute( $u, $v, 'road' );

        next if ( $road->player->color ne $player->color );

        # recurse and track all possible road paths starting from both intersections
        $self->_traverse_roads( found_paths => $found_paths,
                                player => $player,
                                prior_path => [$u],
                                visited => {},
                                current_path => [$u, $v] );

        $self->_traverse_roads( found_paths => $found_paths,
                                player => $player,
                                prior_path => [$v],
                                visited => {},
                                current_path => [$v, $u] );
    }

    my $count = @$found_paths;

    # find the longest full path traversed
    my $longest = [];

    foreach my $found_path ( @$found_paths ) {

        my $length = @$found_path;

        next if ( $length < @$longest );

        $longest = $found_path;
    }

    return $longest;
}

sub _traverse_roads {

    my ( $self, %args ) = @_;

    my $found_paths = $args{'found_paths'};
    my $player = $args{'player'};
    my $prior_path = $args{'prior_path'};
    my $visited = $args{'visited'};
    my $current_path = $args{'current_path'};

    my ( $u, $v ) = @$current_path;

    # we've already visited this road before
    return if ( $visited->{"$u-$v"} || $visited->{"$v-$u"} );

    # mark it as now having been visited
    $visited->{"$u-$v"} = 1;
    $visited->{"$v-$u"} = 1;

    # construct the full path we've traversed thus far
    push( @$prior_path, $v );

    # mark it as having been visited
    push( @$found_paths, $prior_path );

    # find the next connecting path to traverse
    my @adjacent_paths = $self->graph->edges_at( $v );

    foreach my $adjacent ( @adjacent_paths ) {

        my ( $u2, $v2 ) = @$adjacent;

        # don't bother traversing a path we already took
        next if ( $visited->{"$u2-$v2"} || $visited->{"$v2-$u2"} );

        # only bother traversing paths that have a road built by this player
        next if ( !$self->graph->has_edge_attribute( $u2, $v2, 'road' ) );

        my $adjacent_road = $self->graph->get_edge_attribute( $u2, $v2, 'road' );

        next if ( $adjacent_road->player->color ne $player->color );

        # which intersection is connecting this next path (which direction are we going to)?
        my $intersection = $self->_get_connecting_intersection( $current_path, $adjacent );

        # is a different player's building blocking the way?
        if ( $self->graph->has_vertex_attribute( $intersection, 'building' ) ) {

            my $building = $self->graph->get_vertex_attribute( $intersection, 'building' );

            # we're blocked, cant traverse this adjacent path
            next if ( $building->player->color ne $player->color );
        }

        # make new copies of the references before we do recursion
        my $visited_copy = dclone( $visited );
        my $prior_path_copy = dclone( $prior_path );

        # make sure we mark the correct order of the intersection we're traversing
        if ( $adjacent->[0] != $intersection ) {

            $adjacent = [ $adjacent->[1], $adjacent->[0] ];
        }

        # traverse this path too
        $self->_traverse_roads( found_paths => $found_paths,
                                player => $player,
                                prior_path => $prior_path_copy,
                                visited => $visited_copy,
                                current_path => $adjacent );
    }
}

sub _get_connecting_intersection {

    my ( $self, $path1, $path2 ) = @_;

    my ( $u1, $v1 ) = @$path1;
    my ( $u2, $v2 ) = @$path2;

    return $u1 if ( $u1 == $u2 || $u1 == $v2 );
    return $v1;
}

1;

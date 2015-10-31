package Games::Catan::Board;

use Moo;
use Types::Standard qw( Enum ArrayRef InstanceOf );
use Graph::Undirected;
use Data::Dumper;

use Games::Catan::Robber;
use Games::Catan::Board::Tile;

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
    $self->graph->add_edge( 0, 1 );
    $self->graph->add_edge( 1, 2 );
    $self->graph->add_edge( 2, 3 );
    $self->graph->add_edge( 3, 4 );
    $self->graph->add_edge( 4, 5 );
    $self->graph->add_edge( 5, 6 );

    $self->graph->add_edge( 0, 7 );
    $self->graph->add_edge( 2, 9 );
    $self->graph->add_edge( 4, 11 );
    $self->graph->add_edge( 6, 13 );

    $self->graph->add_edge( 7, 8 );
    $self->graph->add_edge( 8, 9 );
    $self->graph->add_edge( 9, 10 );
    $self->graph->add_edge( 10, 11 );
    $self->graph->add_edge( 11, 12 );
    $self->graph->add_edge( 12, 13 );

    $self->graph->add_edge( 7, 14 );
    $self->graph->add_edge( 13, 15 );

    $self->graph->add_edge( 14, 16 );
    $self->graph->add_edge( 16, 17 );
    $self->graph->add_edge( 17, 18 );
    $self->graph->add_edge( 18, 19 );
    $self->graph->add_edge( 19, 20 );
    $self->graph->add_edge( 20, 21 );
    $self->graph->add_edge( 21, 22 );
    $self->graph->add_edge( 22, 23 );
    $self->graph->add_edge( 23, 24 );
    $self->graph->add_edge( 15, 24 );

    $self->graph->add_edge( 8, 18 );
    $self->graph->add_edge( 10, 20 );
    $self->graph->add_edge( 12, 22 );

    $self->graph->add_edge( 16, 25 );
    $self->graph->add_edge( 25, 27 );
    $self->graph->add_edge( 27, 28 );
    $self->graph->add_edge( 28, 29 );
    $self->graph->add_edge( 29, 30 );
    $self->graph->add_edge( 30, 31 );
    $self->graph->add_edge( 31, 32 );
    $self->graph->add_edge( 32, 33 );
    $self->graph->add_edge( 33, 34 );
    $self->graph->add_edge( 34, 35 );
    $self->graph->add_edge( 35, 36 );
    $self->graph->add_edge( 36, 37 );
    $self->graph->add_edge( 26, 37 );
    $self->graph->add_edge( 24, 26 );

    $self->graph->add_edge( 17, 29 );
    $self->graph->add_edge( 19, 31 );
    $self->graph->add_edge( 21, 33 );
    $self->graph->add_edge( 23, 35 );

    $self->graph->add_edge( 28, 38 );
    $self->graph->add_edge( 38, 39 );
    $self->graph->add_edge( 39, 40 );
    $self->graph->add_edge( 40, 41 );
    $self->graph->add_edge( 41, 42 );
    $self->graph->add_edge( 42, 43 );
    $self->graph->add_edge( 43, 44 );
    $self->graph->add_edge( 44, 45 );
    $self->graph->add_edge( 45, 46 );
    $self->graph->add_edge( 36, 46 );

    $self->graph->add_edge( 30, 40 );
    $self->graph->add_edge( 32, 42 );
    $self->graph->add_edge( 34, 44 );

    $self->graph->add_edge( 39, 47 );
    $self->graph->add_edge( 47, 48 );
    $self->graph->add_edge( 48, 49 );
    $self->graph->add_edge( 49, 50 );
    $self->graph->add_edge( 50, 51 );
    $self->graph->add_edge( 51, 52 );
    $self->graph->add_edge( 52, 53 );
    $self->graph->add_edge( 45, 53 );

    # create the 19 tiles, associated with their vertices
    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'mountains',
                                                           number => 10,
                                                           vertices => [0, 1, 2, 7, 8, 9] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'pasture',
                                                           number => 2,
                                                           vertices => [2, 3, 4, 9, 10, 11] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'forest',
                                                           number => 9,
                                                           vertices => [4, 5, 6, 11, 12, 13] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'fields',
                                                           number => 12,
                                                           vertices => [14, 7, 8, 16, 17, 18] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'hills',
                                                           number => 6,
                                                           vertices => [8, 9, 10, 18, 19, 20] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'pasture',
                                                           number => 4,
                                                           vertices => [10, 11, 12, 20, 21, 22] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'hills',
                                                           number => 10,
                                                           vertices => [12, 13, 15, 22, 23, 24] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'fields',
                                                           number => 9,
                                                           vertices => [25, 16, 17, 27, 28, 29] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'forest',
                                                           number => 11,
                                                           vertices => [17, 18, 19, 29, 30, 31] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'desert',
                                                           number => 7,
                                                           vertices => [19, 20, 21, 31, 32, 33] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'forest',
                                                           number => 3,
                                                           vertices => [21, 22, 23, 33, 34, 35] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'mountains',
                                                           number => 8,
                                                           vertices => [23, 24, 26, 35, 36, 37] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'forest',
                                                           number => 8,
                                                           vertices => [28, 29, 30, 38, 39, 40] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'mountains',
                                                           number => 3,
                                                           vertices => [30, 31, 32, 40, 41, 42] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'fields',
                                                           number => 4,
                                                           vertices => [32, 33, 34, 42, 43, 44] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'pasture',
                                                           number => 5,
                                                           vertices => [34, 35, 36, 44, 45, 46] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'hills',
                                                           number => 5,
                                                           vertices => [39, 40, 41, 47, 48, 49] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'fields',
                                                           number => 6,
                                                           vertices => [41, 42, 43, 49, 50, 51] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'pasture',
                                                           number => 11,
                                                           vertices => [43, 44, 45, 51, 52, 53] ) );

    # create the robber initially on the desert tile
    my $robber = Games::Catan::Robber->new( game => $self->game );

    $self->robber( $robber );

    $self->tiles->[9]->robber( $self->robber );
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

    my $current_longest_road = [];

    foreach my $path ( @paths ) {

	my $new_longest_road = $self->_get_longest_road( next_path => $path,
							 player => $player,
							 visited_paths => {},
							 full_path => [] );

	$current_longest_road = $new_longest_road if ( @$new_longest_road > @$current_longest_road );
    }

    return $current_longest_road;
}

sub _get_longest_road {

    my ( $self, %args ) = @_;

    my $next_path = $args{'next_path'};
    my $player = $args{'player'};
    my $visited_paths = $args{'visited_paths'};
    my $full_path = $args{'full_path'};

    my ( $u, $v ) = @$next_path;

    # we already visited this adjacent path before
    return $full_path if ( $visited_paths->{"$u-$v"} );

    # no road built on this path
    return $full_path if ( !$self->graph->has_edge_attribute( $u, $v, 'road' ) );

    # mark this path now as having been visited
    $visited_paths->{"$u-$v"} = 1;

    my $next_road = $self->graph->get_edge_attribute( $u, $v, 'road' );

    # not our road
    return $full_path if ( $next_road->player->color ne $player->color );

    # find the next connecting path to traverse
    my @adjacent_paths = ( $self->graph->edges_at( $u ),
			   $self->graph->edges_at( $v ) );

    my $adjacent_longest_roads = [];

    foreach my $adjacent_path ( @adjacent_paths ) {
	
	my ( $u2, $v2 ) = @$adjacent_path;
	
	next if ( $visited_paths->{"$u2-$v2"} );

	# which intersection is connecting this next path?
	my $intersection = $self->_get_connecting_intersection( $next_path, $adjacent_path );

	# is a different player's building blocking the way?
	if ( $self->graph->has_vertex_attribute( $intersection, 'building' ) ) {

	    my $building = $self->graph->get_vertex_attribute( $intersection, 'building' );

	    next if ( $building->player->color ne $player->color );
	}

	warn "adding " . Dumper( $next_path ) . " to full path " . Dumper( $full_path ) . " for adjacent " . Dumper( $adjacent_path );

	my @full_path = @$full_path;
	push( @full_path, $next_path );

	my %visited_paths = %$visited_paths;

	my $next_longest_road = $self->_get_longest_road( next_path => $adjacent_path,
							  player => $player,
							  visited_paths => \%visited_paths,
							  full_path => \@full_path );

	push( @$adjacent_longest_roads, $next_longest_road );
    }

    # there were no more adjacent roads to traverse
    return $full_path if ( @$adjacent_longest_roads == 0 );

    my $longest;

    foreach my $adjacent ( @$adjacent_longest_roads ) {

	my $len = @$adjacent;

	$longest = $adjacent if ( !defined $longest || $len > @$longest );
    }

    return $longest;
}

sub _get_connecting_intersection {

    my ( $self, $path1, $path2 ) = @_;

    my ( $u1, $v1 ) = @$path1;
    my ( $u2, $v2 ) = @$path2;

    return $u1 if ( $u1 == $u2 || $u1 == $v2 );
    return $v1;
}

1;

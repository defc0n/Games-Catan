package Games::Catan::Player::Stupid;

use Moo;

with( 'Games::Catan::Player' );

use Data::Dumper;

sub place_first_settlement {
    
    my ( $self ) = @_;
    
    $self->_place_starting_settlement();
}

sub place_second_settlement {

    my ( $self ) = @_;

    $self->_place_starting_settlement();
}

sub _place_starting_settlement {

    my ( $self ) = @_;

    my $graph = $self->game->board->graph;

    # keep trying until we find a valid location
    FIND_INTERSECTION:
    
    my $intersection = $graph->random_vertex;

    # this intersection is already occupied!
    goto FIND_INTERSECTION if $graph->has_vertex_attribute( $intersection, "building" );
    
    # make sure we don't violate the distance rule
    my @neighbors = $graph->neighbors( $intersection );
    
    foreach my $neighbor ( @neighbors ) {
	
	goto FIND_INTERSECTION if $graph->has_vertex_attribute( $neighbor, "building" );
    }
    
    # place settlement on intersection
    my $settlement = pop( @{$self->settlements} );       
    $graph->set_vertex_attribute( $intersection, "building", $settlement );

    my @paths = $graph->edges_at( $intersection );

    foreach my $path ( @paths ) {

	my ( $int1, $int2 ) = @$path;

	next if $graph->has_edge_attribute( $int1, $int2, "road" );

	my $road = pop( @{$self->roads} );
	$graph->set_edge_attribute( $int1, $int2, "road", $road );
    }
}

1;

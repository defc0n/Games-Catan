package Games::Catan::Player::Stupid;

use Moo;

with( 'Games::Catan::Player' );

use Data::Dumper;

### public methods ###

sub take_turn {

    my ( $self ) = @_;

    # keep track whether we've already played a development card
    my $played_dev_card = 0;

    # before we bother rolling, see if we've won the game
    my $score = $self->get_score();

    # we won the game!
    if ( $score >= 10 ) {

	$self->game->winner( $self );
	return;
    }

    # see if we have any unplayed development cards
    my $development_cards = $self->development_cards;
    my @unplayed_development_cards;

    foreach my $development_card ( @$development_cards ) {

	# not a playable card
	next if !$development_card->playable;

	# already played this card
	next if $development_card->played;

	push( @unplayed_development_cards, $development_card );
    }

    # at least one unplayed dev card
    if ( @unplayed_development_cards > 0 ) {

	# randomly decide if we want to play one or not before we roll
	if ( int( rand( 1 ) ) ) {

	    $self->_play_random_development_card( @unplayed_development_cards );
	    $played_dev_card = 1;

	    # its possible we've won the game now
	    return if $self->game->winner;
	}
    }

    # player must now roll
    $self->game->roll( $self );

    # normally, trading would be done here
    
    # decide again if we want to play a development card (if we haven't already)
    if ( !$played_dev_card && @unplayed_development_cards > 0 ) {
	
	if ( int( rand( 1 ) ) ) {

	    $self->_play_random_development_card( @unplayed_development_cards );
	    $played_dev_card = 1;

	    # its possible we've won the game now
	    return if $self->game->winner;
	}
    }

    # do any buying or building here
}

sub place_first_settlement {
    
    my ( $self ) = @_;
    
    $self->_place_starting_settlement();
}

sub place_second_settlement {

    my ( $self ) = @_;

    $self->_place_starting_settlement();
}

sub activate_robber {

    my ( $self ) = @_;

    my $graph = $self->game->board->graph;
    my $tiles = $self->game->board->tiles;

    # randomly pick a new tile to move the robber to
    my $num_tiles = @$tiles;
    my $i = int( rand( $num_tiles ) );
    my $tile = $tiles->[$i];

    # move robber to the new tile
    $self->game->board->move_robber( $tile );

    # are there other players with settlements at this tile to steal from?
    my $vertices = $tile->vertices;

    my @players_to_rob;

    foreach my $vertex ( @$vertices ) {

	next if !$graph->has_vertex_attribute( $vertex, 'building' );
	
	my $building = $graph->get_vertex_attribute( $vertex, 'building' );
	my $player = $building->player;

	# dont rob from ourself
	next if ( $player->color eq $self->color );

	# dont rob from them if they have no cards to steal
	next if ( @{$player->resource_cards} == 0 );

	push( @players_to_rob, $player );
    }

    # was there at least one player to rob from?
    if ( @players_to_rob > 0 ) {

	# randomly pick one of the players to rob from
	my $num_players = @players_to_rob;
	my $i = int( rand( $num_players ) );
	my $player = $players_to_rob[$i];

	# randomly pick one of their cards
	my $num_cards = @{$player->resource_cards};
	$i = int( rand( $num_cards ) );
	my $card = splice( @{$player->resource_cards}, $i, 1 );

	# its our card now!
	push( @{$self->resource_cards}, $card );
    }
}

sub discard_robber_cards {

    my ( $self ) = @_;

    my $resource_cards = $self->resource_cards;

    # how many cards do we need to remove? (must be half, rounded down)
    my $num = int( @$resource_cards / 2 );

    my $cards = [];
    
    for ( my $i = 0; $i < $num; $i++ ) {
	
        # randomly pick one of our cards to remove
        my $num_cards = @$resource_cards;
        my $j = int( rand( $num_cards ) );
	my $card = splice( @$resource_cards, $j, 1 );

	push( @$cards, $card );	
    }

    $self->game->bank->give_resource_cards( $cards );
}

### helper methods ###

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

sub _play_random_development_card {

    my ( $self, @cards ) = @_;

    # grab a random development card to play
    my $i = int( rand( @cards ) );
    my $dev_card = $cards[$i];

    warn "playing " . Dumper $dev_card;
    
    $dev_card->play();
}

1;

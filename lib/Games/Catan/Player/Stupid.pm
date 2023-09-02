package Games::Catan::Player::Stupid;

use Moo;
with 'Games::Catan::Player';

use Future::AsyncAwait;
use Games::Catan::Trade;
use IO::Async::Loop;
use IO::Async::Timer::Countdown;
use Types::Standard qw( Num );

has turn_delay => (
    is      => 'rw',
    isa     => Num,
    default => 0,
);

async sub take_turn {
    my ( $self ) = @_;

    # Keep track whether we've already played a development card.
    my $played_dev_card = 0;

    # See if we have any unplayed development cards.
    my $development_cards = $self->development_cards;
    my @unplayed_development_cards;

    for my $development_card ( @$development_cards ) {
        # Not a playable card.
        next unless $development_card->playable;

        # Already played this card.
        next if $development_card->played;

        push @unplayed_development_cards, $development_card;
    }

    # At least one unplayed dev card.
    if ( @unplayed_development_cards > 0 ) {

        # Randomly decide if we want to play one or not before we roll.
        if ( int( rand( 2 ) ) ) {

            my $f = $self->game->loop->new_future;

            my $timer = IO::Async::Timer::Countdown->new(
                delay     => $self->turn_delay,
                on_expire => sub { $f->done(1) },
            );

            $timer->start;
            $self->game->loop->add( $timer );
            $f->await;

            $self->_play_random_development_card(
                @unplayed_development_cards
            );
            $played_dev_card = 1;

            # It is possible we've won the game now.
            return if $self->game->winner;
        }
    }

    my $f = $self->game->loop->new_future;

    my $timer = IO::Async::Timer::Countdown->new(
        delay     => $self->turn_delay,
        on_expire => sub { $f->done(1) },
    );

    $timer->start;
    $self->game->loop->add( $timer );
    $f->await;

    # Player must now roll.
    await $self->game->roll( $self );

    # Potentially trade with the bank.
    if ( int( rand( 2 ) ) ) {
        $self->_trade_bank;
    }

    # Potentially trade with another player.
    if ( int( rand( 2 ) ) ) {
        await $self->_trade_player;
    }

    # Decide if we want to play a development card (if we haven't
    # already).
    if ( !$played_dev_card && @unplayed_development_cards > 0 ) {
        if ( int( rand( 2 ) ) ) {
            $self->_play_random_development_card(
                @unplayed_development_cards
            );
            $played_dev_card = 1;

            # It is possible we've won the game now.
            return if $self->game->winner;
        }
    }

    # Potentially build/buy stuff.
    while ( 1 ) {
        my @buyable = ();

        my $settlement_intersections;
        my $road_paths;

        if ( @{ $self->roads } > 0 &&
                 $self->can_afford( $self->roads->[0] ) ) {
            # Also make sure there is somewhere on the board we can
            # build one.
            $road_paths = $self->get_possible_road_paths;

            push @buyable, $self->roads->[0] if @$road_paths > 0;
        }

        if ( @{ $self->settlements } > 0 &&
                 $self->can_afford( $self->settlements->[0] ) ) {

            # Also make sure there is somewhere on the board we can
            # build one.
            $settlement_intersections =
                $self->get_possible_settlement_intersections;

            push @buyable, $self->settlements->[0]
                if @$settlement_intersections > 0;
        }

        push @buyable, $self->cities->[0]
            if @{ $self->cities } > 0 &&
            $self->can_afford( $self->cities->[0] );

        push @buyable, $self->game->development_cards->[0]
            if @{ $self->game->development_cards } > 0 &&
            $self->can_afford( $self->game->development_cards->[0] );

        # We cant afford anything!
        last unless @buyable;

        # Randomly decide if we want to build anything or not.
        my $rand = int( rand( 2 ) );
        last if $rand;

        # Randomly choose something we're able to buy/build.
        my $num_items = @buyable;
        my $i         = int( rand( $num_items ) );
        my $item      = $buyable[$i];
        my $location;

        # Are we upgrading a settlement to a city?
        if ( $item->isa('Games::Catan::Building::City') ) {
            # Randomly pick one of our played settlements to upgrade.
            my $graph = $self->game->board->graph;
            my @vertices = $graph->vertices;
            my @options;

            for my $vertex ( @vertices ) {
                next unless $graph->has_vertex_attribute(
                    $vertex,
                    'building',
                );

                my $building = $graph->get_vertex_attribute(
                    $vertex,
                    'building'
                );

                next unless $building->isa(
                    'Games::Catan::Building::Settlement'
                );

                my $player = $building->player;

                next if $player->color ne $self->color;

                push @options, $vertex;
            }

            my $num      = @options;
            my $i        = int( rand( $num ) );
            my $location = $options[$i];

            $self->upgrade_settlement( $location );
        }

        # Are we building a new settlement?
        elsif ( $item->isa('Games::Catan::Building::Settlement') ) {

            # Randomly choose which intersection to build it at.
            my $num          = @$settlement_intersections;
            my $i            = int( rand( $num ) );
            my $intersection = $settlement_intersections->[$i];

            $self->build_settlement( $intersection );
        }

        # Are we building a new road?
        elsif ( $item->isa('Games::Catan::Road') ) {

            # Randomly choose which path to build it at.
            my $num  = @$road_paths;
            my $i    = int( rand( $num ) );
            my $path = $road_paths->[$i];

            $self->build_road( $path );
        }

        # Must be buying a development card.
        else {
            $self->buy_development_card;
        }
    }

    return 1;
}

async sub place_first_settlement {
    my ( $self ) = @_;

    await $self->_place_starting_settlement();
    return 1;
}

async sub place_second_settlement {
    my ( $self ) = @_;

    await $self->_place_starting_settlement();
    return 1;
}

async sub activate_robber {
    my ( $self ) = @_;

    my $f = $self->game->loop->new_future;

    my $timer = IO::Async::Timer::Countdown->new(
        delay     => $self->turn_delay,
        on_expire => sub {
            my $graph = $self->game->board->graph;
            my $tiles = $self->game->board->tiles;

            my $resource_cards = $self->get_resource_cards;

            # Randomly pick a new tile to move the robber to.
            my @eligible_tiles = grep { ! $_->robber } @$tiles;

            my $num_tiles = @$tiles;
            my $i         = int( rand( @eligible_tiles ) );
            my $tile      = $eligible_tiles[ $i ];

            # Move robber to the new tile.
            $self->game->board->move_robber( $tile );

            $self->logger->info( $self->color . " moved the robber" );

            # Are there other players with settlements at this tile to steal
            # from?
            my $vertices = $tile->vertices;

            my @players_to_rob;

            for my $vertex ( @$vertices ) {
                next unless $graph->has_vertex_attribute( $vertex, 'building' );

                my $building = $graph->get_vertex_attribute(
                    $vertex,
                    'building',
                );
                my $player   = $building->player;

                # Don't rob from ourself.
                next if $player->color eq $self->color;

                # Don't rob from them if they have no cards to steal.
                next if @{ $player->get_resource_cards } == 0;

                push @players_to_rob, $player;
            }

            # Was there at least one player to rob from?
            if ( @players_to_rob > 0 ) {

                # Randomly pick one of the players to rob from.
                my $num_players = @players_to_rob;
                my $i           = int( rand( $num_players ) );
                my $player      = $players_to_rob[$i];

                # Randomly pick one of their cards
                my $card = $player->steal_resource_card;

                # It is our card now!
                if ( $card->isa('Games::Catan::ResourceCard::Brick') ) {
                    push @{ $self->brick }, $card;
                }

                elsif ( $card->isa('Games::Catan::ResourceCard::Lumber') ) {
                    push @{ $self->lumber }, $card;
                }

                elsif ( $card->isa('Games::Catan::ResourceCard::Wool') ) {
                    push @{ $self->wool }, $card;
                }

                elsif ( $card->isa('Games::Catan::ResourceCard::Grain') ) {
                    push @{ $self->grain }, $card;
                }

                elsif ( $card->isa('Games::Catan::ResourceCard::Ore') ) {
                    push @{ $self->ore }, $card;
                }

                $self->logger->info(
                    $self->color . " robbed a card from " . $player->color
                );
            }

            $f->done(1);
        },
    );

    $timer->start;
    $self->game->loop->add( $timer );
    $f->await;
    return 1;
}

async sub offer_trade {
    my ( $self, %args ) = @_;
    my $from = $args{from};
    my $deal = $args{deal};

    # We're stupid and don't care who its from, even if they are about to win.
    # One could imagine a smarter AI who won't make deals depending upon who the
    # trade offer is from.

    my $f = $self->game->loop->new_future;

    my $timer = IO::Async::Timer::Countdown->new(
        delay     => $self->turn_delay,
        on_expire => sub {
            my @resources = qw( brick lumber wool grain ore );

            # Verify we have every resource they are requesting.
            for my $resource ( @resources ) {
                my $request = "request_$resource";

                # They aren't requesting any of this resource.
                next unless $deal->$request;

                # Reject the trade deal if we don't have any of this resource
                # they want.
                if ( @{ $self->$resource } == 0 ) {
                    $f->done(0);
                    return;
                }
            }

            # Verify we want the resource they are offering.
            for my $resource ( @resources ) {
                my $offer = "offer_$resource";

                # They aren't offering any of this resource.
                next unless $deal->$offer;

                # Reject the trade deal if we already have some of what they are
                # offering.
                if ( @{ $self->$resource } > 0 ) {
                    $f->done(0);
                    return;
                }
            }

            # Randomly decide whether or not to accept this trade offer.
            my $ret = int( rand( 2 ) );
            $f->done($ret);
        },
    );

    $timer->start;
    $self->game->loop->add( $timer );

    return $f->await->get;
}

async sub discard_robber_cards {
    my ( $self ) = @_;

    my $f = $self->game->loop->new_future;

    my $timer = IO::Async::Timer::Countdown->new(
        delay     => $self->turn_delay,
        on_expire => sub {
            my $resource_cards = $self->get_resource_cards;

            # How many cards do we need to remove? (must be half, rounded down)
            my $num = int( @$resource_cards / 2 );

            my $cards = [];

            # Randomly pick one of our cards to remove.
            for ( 1 .. $num ) {
                my $num_cards = @$resource_cards;
                my $j         = int( rand( $num_cards ) );
                my $card      = splice @$resource_cards, $j, 1;

                push @$cards, $card;
            }

            my @removed;

            for my $card ( @$cards ) {
                if ( $card->isa('Games::Catan::ResourceCard::Brick') ) {
                    push @removed, shift @{ $self->brick };
                }
                elsif ( $card->isa('Games::Catan::ResourceCard::Lumber') ) {
                    push @removed, shift @{ $self->lumber };
                }
                elsif ( $card->isa('Games::Catan::ResourceCard::Wool') ) {
                    push @removed, shift @{ $self->wool };
                }
                elsif ( $card->isa('Games::Catan::ResourceCard::Grain') ) {
                    push @removed, shift @{ $self->grain };
                }
                elsif ( $card->isa('Games::Catan::ResourceCard::Ore') ) {
                    push @removed, shift @{ $self->ore };
                }
            }

            $self->game->bank->give_resource_cards( \@removed );

            $f->done(1);
        },
    );

    $timer->start;
    $self->game->loop->add( $timer );
    $f->await;

    return 1;
}

async sub _place_starting_settlement {
    my ( $self ) = @_;

    my $f = $self->game->loop->new_future;

    my $timer = IO::Async::Timer::Countdown->new(
        delay     => $self->turn_delay,
        on_expire => sub {
            my $graph = $self->game->board->graph;

            # Keep trying until we find a valid location.
          FIND_INTERSECTION:

            my $intersection = $graph->random_vertex;

            # This intersection is already occupied!
            goto FIND_INTERSECTION
                if $graph->has_vertex_attribute( $intersection, "building" );

            # Make sure we don't violate the distance rule.
            my @neighbors = $graph->neighbors( $intersection );

            for my $neighbor ( @neighbors ) {
                # This would violate distance rule--find a different
                # intersection.
                goto FIND_INTERSECTION
                    if $graph->has_vertex_attribute( $neighbor, "building" );
            }

            # Place settlement on intersection.
            my $settlement = shift @{ $self->settlements };
            $graph->set_vertex_attribute(
                $intersection,
                "building",
                $settlement,
            );
            $self->logger->info(
                $self->color . " placed a starting settlement"
            );

            my @paths = $graph->edges_at( $intersection );

            for my $path ( @paths ) {
                my ( $int1, $int2 ) = @$path;

                # Already a road built on this path.
                next if $graph->has_edge_attribute( $int1, $int2, "road" );

                # Take one of our roads and place it on the board.
                my $road = shift @{ $self->roads };
                $graph->set_edge_attribute( $int1, $int2, "road", $road );
                $self->logger->info( $self->color . " placed a starting road" );

                # Only get to build one road with our settlement.
                last;
            }

            $f->done(1);
        },
    );

    $timer->start;
    $self->game->loop->add( $timer );
    $f->await;

    return 1;
}

sub _play_random_development_card {
    my ( $self, @cards ) = @_;

    my @resources = qw( brick grain lumber ore wool );
    my $num_resources = @resources;

    # Grab a random development card to play.
    my $i        = int( rand( @cards ) );
    my $dev_card = $cards[$i];

    if ( $dev_card->isa('Games::Catan::DevelopmentCard::Monopoly') ) {
        # Pick a random resource to steal from the other players.
        my $i        = int( rand( $num_resources ) );
        my $resource = $resources[$i];

        $dev_card->play( $resource );
    }
    elsif ( $dev_card->isa('Games::Catan::DevelopmentCard::YearOfPlenty') ) {
        # pick two resources (could be the same type) to take from the bank.
        my $i = int( rand( $num_resources ) );
        my $j = int( rand( $num_resources ) );

        my $resource1 = $resources[$i];
        my $resource2 = $resources[$j];

        $dev_card->play([ $resource1, $resource2 ]);
    }
    elsif ( $dev_card->isa('Games::Catan::DevelopmentCard::RoadBuilding') ) {
        # Make sure we have 2 available roads to build.
        my $num_roads = @{ $self->roads };
        return if $num_roads < 2;

        # All choices we have for placing both roads.
        my $pair_choices = [];

        # Determine the current paths we can build on for our first road.
        my $road_paths = $self->get_possible_road_paths;
        my $num_paths  = @$road_paths;

        # Can't play it if there are no possible paths to build on.
        return if $num_paths == 0;

        for my $first_path ( @$road_paths ) {
            my ( $u, $v ) = @$first_path;

            # Simulate us placing the path there to find any future available
            # paths.
            $self->game->board->graph->set_edge_attribute(
                $u,
                $v,
                'road',
                $self->roads->[0]
            );

            # Find what paths we would have if we were to build the first road.
            my $new_road_paths = $self->get_possible_road_paths;
            $num_paths = @$new_road_paths;

            # Remove our simulated road placement.
            $self->game->board->graph->delete_edge_attribute( $u, $v, 'road' );

            # Add each to our list of possible pair choices.
            for my $second_path ( @$new_road_paths ) {
                push @$pair_choices, [$first_path, $second_path];
            }
        }

        # Randomly choose which pair of roads to build.
        my $num_choices = @$pair_choices;
        my $i           = int( rand( $num_choices ) );
        my $choices     = $pair_choices->[$i];

        $dev_card->play( $choices );
    }
    else {
        $dev_card->play;
    }
}

sub _trade_bank {
    my ( $self ) = @_;

    my @resources = qw( brick lumber wool grain ore );

    my $requestable = [];
    my $offerable   = [];

    # Check which resources we can offer and those we want.
    for my $resource ( @resources ) {
        my $ratio_name   = $resource . "_ratio";
        my $ratio        = $self->$ratio_name;
        my $num_resource = @{ $self->$resource };

        # We have enough of this resource to trade w/ the bank.
        if ( $num_resource >= $ratio ) {
            push @$offerable, $resource;
        }

        # We don't have any of this resource, and the bank has one, so we can
        # request it.
        elsif ( $num_resource == 0 && @{ $self->game->bank->$resource } ) {
            push @$requestable, $resource;
        }
    }

    my $num_requestable = @$requestable;
    my $num_offerable   = @$offerable;

    # Either we can't offer anything or dont need anything.
    return if $num_requestable == 0 || $num_offerable == 0;

    # Randomly pick which resource to request.
    my $i       = int( rand( $num_requestable ) );
    my $request = $requestable->[$i];

    # Randomly pick which resource to offer.
    my $j     = int( rand( $num_offerable ) );
    my $offer = $offerable->[$j];

    # Create the trade offer
    my $trade = Games::Catan::Trade->new( player => $self );

    # Only try trading the minimum amount. A smarter AI might try more.
    my $ratio_name   = $offer . "_ratio";
    my $offer_name   = "offer_$offer";
    my $request_name = "request_$request";
    my $ratio        = $self->$ratio_name;

    $trade->$request_name( 1 );
    $trade->$offer_name( $ratio );

    return $self->request_bank_trade( deal => $trade );
}

async sub _trade_player {
    my ( $self ) = @_;

    my $requestable = [];
    my $offerable   = [];

    my @resources = qw( brick lumber wool grain ore );

    # Check which resources we have and dont have.
    for my $resource ( @resources ) {
        # We have this resource.
        if ( @{ $self->$resource } > 0 ) {
            push @$offerable, "offer_$resource";
        }
        # We need this resource.
        else {
            push @$requestable, "request_$resource";
        }
    }

    my $num_requestable = @$requestable;
    my $num_offerable   = @$offerable;

    # Either we dont have anything or dont need anything.
    return if $num_requestable == 0 || $num_offerable == 0;

    # Randomly pick which resource to request.
    my $i       = int( rand( $num_requestable ) );
    my $request = $requestable->[$i];

    # Randomly pick which resource to offer.
    my $j     = int( rand( $num_offerable ) );
    my $offer = $offerable->[$j];

    # Create the trade offer.
    my $trade = Games::Catan::Trade->new( player => $self );

    # Only trade 1 and offer 1, cause we're too stupid to try something else.
    $trade->$request( 1 );
    $trade->$offer( 1 );

    # Ask every other player to trade until one accepts.
    my $players = $self->game->players;

    # await doesn't work the way we want inside a for loop.
    my $n = 0;
    while ( $n < @$players ) {
        my $player = $players->[$n++];

        # Don't trade with ourself!
        if ( $self->color eq $player->color ) {
            next;
        }

        my $accepted = await $self->request_player_trade(
            to   => $player,
            deal => $trade,
        );

        # Found a player to accept our trade, all done.
        last if $accepted;
    }

    return 1;
}

1;

use strict;
use warnings;

use Test::More tests => 4;

use Games::Catan;
use Try::Tiny;

# create 3 player game
my $game = Games::Catan->new( num_players => 3 );
                              
ok( $game, "created 3 player game" );
is( $game->num_players, 3, "3 players" );

# create 4 player game
$game = Games::Catan->new( num_players => 4 );

ok( $game, "created 4 player game" );
is( $game->num_players, 4, "4 players" );

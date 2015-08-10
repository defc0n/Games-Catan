use strict;
use warnings;

use Test::More tests => 5;
use Data::Dumper;

use Games::Catan;
use Try::Tiny;

my $game = Games::Catan->new( num_players => 3 );
                              
ok( $game, "created 3 player game" );
is( @{$game->players}, 3, "3 players" );

$game = Games::Catan->new( num_players => 4 );

ok( $game, "created 4 player game" );
is( @{$game->players}, 4, "4 players" );

$game = undef;

try {

  $game = Games::Catan->new( num_players => 2 );
}

catch {

  ok( !$game, "only support 3 or 4 players" );
};

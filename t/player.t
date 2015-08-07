use strict;
use warnings;

use Test::More tests => 4;
use Data::Dumper;

use Games::Catan::Player;

my $player = Games::Catan::Player->new( color => 'red' );

is( $player->color, 'red', 'red color' );
is( @{$player->settlements}, 5, '5 settlements' );
is( @{$player->cities}, 4, '4 cities' );
is( @{$player->roads}, 15, '15 roads' );
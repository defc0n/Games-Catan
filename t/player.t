use strict;
use warnings;

use Test::More tests => 7;
use Data::Dumper;

use Games::Catan;
use Games::Catan::Player;

my $catan = Games::Catan->new();
my $player = Games::Catan::Player->new( game => $catan, color => 'red' );

is( $player->color, 'red', 'red color' );
is( @{$player->settlements}, 5, '5 settlements' );
is( @{$player->cities}, 4, '4 cities' );
is( @{$player->roads}, 15, '15 roads' );
is( @{$player->resource_cards}, 0, '0 resource cards' );
is( @{$player->development_cards}, 0, '0 development cards' );
is( @{$player->resource_cards}, 0, '0 special cards' );
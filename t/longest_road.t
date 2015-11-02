use strict;
use warnings;

use Test::More tests => 1;
use Data::Dumper;

use Games::Catan;
use Games::Catan::Board;

use Games::Catan::ResourceCard::Brick;
use Games::Catan::ResourceCard::Lumber;

my $catan = Games::Catan->new();
my $board = $catan->board;

my $player = $catan->players->[0];

# give him a bunch of brick and lumber so he can build roads :)
for ( 1 .. 100 ) {

    push( @{$player->brick}, Games::Catan::ResourceCard::Brick->new() );
    push( @{$player->lumber}, Games::Catan::ResourceCard::Lumber->new() );
}

# build a "figure 8" out of roads and make sure it has a longest road of length 11
$player->build_road( [31, 32] );
$player->build_road( [32, 33] );
$player->build_road( [33, 21] );
$player->build_road( [21, 20] );
$player->build_road( [20, 19] );
$player->build_road( [19, 31] );

$player->build_road( [20, 10] );
$player->build_road( [10, 11] );
$player->build_road( [11, 12] );
$player->build_road( [12, 22] );
$player->build_road( [22, 21] );

my $longest_road = $board->get_longest_road( $player );
my $length = @$longest_road - 1;

is( $length, 11, "longest road with length 11" );
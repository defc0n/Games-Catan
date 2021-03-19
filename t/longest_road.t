use strict;
use warnings;

use Test::More tests => 3;

use Games::Catan;
use Games::Catan::Board;

use Games::Catan::ResourceCard::Brick;
use Games::Catan::ResourceCard::Lumber;

my $catan = Games::Catan->new();
my $board = $catan->board;

my $player = $catan->players->[0];
my $player2 = $catan->players->[1];

# give him a bunch of brick and lumber so he can build roads :)
for ( 1 .. 100 ) {

    push( @{$player->brick}, Games::Catan::ResourceCard::Brick->new() );
    push( @{$player->lumber}, Games::Catan::ResourceCard::Lumber->new() );
}

# build a "figure 8" out of roads and make sure it has a longest road of length 11
$player->build_road( [29, 35] );
$player->build_road( [35, 30] );
$player->build_road( [30, 24] );
$player->build_road( [24, 18] );
$player->build_road( [18, 23] );
$player->build_road( [23, 29] );

$player->build_road( [18, 13] );
$player->build_road( [13, 9] );
$player->build_road( [9, 14] );
$player->build_road( [14, 19] );
$player->build_road( [19, 24] );

my $longest_road = $board->get_longest_road( $player );
my $length = @$longest_road - 1;

is( $length, 11, "longest road with length 11" );

# have player 2 interrupt their road with a settlement
for ( 1 .. 100 ) {

    push( @{$player2->brick}, Games::Catan::ResourceCard::Brick->new() );
    push( @{$player2->lumber}, Games::Catan::ResourceCard::Lumber->new() );
    push( @{$player2->wool}, Games::Catan::ResourceCard::Wool->new() );
    push( @{$player2->grain}, Games::Catan::ResourceCard::Grain->new() );
}

$player2->build_settlement( 18 );

$longest_road = $board->get_longest_road( $player );
$length = @$longest_road - 1;

is( $length, 10, "longest road with length 10" );

# block it with yet another settlement
$player2->build_settlement( 24 );

$longest_road = $board->get_longest_road( $player );
$length = @$longest_road - 1;

is( $length, 5, "longest road with length 5" );
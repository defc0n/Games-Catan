use strict;
use warnings;

use Test::More tests => 8;

use Games::Catan;
use Games::Catan::Player::Stupid;

my $catan = Games::Catan->new();
my $player = Games::Catan::Player::Stupid->new( game => $catan, color => 'red' );

# make sure they start out with all proper game components
is( $player->color, 'red', 'red color' );
is( @{$player->settlements}, 5, '5 settlements' );
is( @{$player->cities}, 4, '4 cities' );
is( @{$player->roads}, 15, '15 roads' );
is( @{$player->get_resource_cards()}, 0, '0 resource cards' );
is( @{$player->development_cards}, 0, '0 development cards' );
is( $player->largest_army, undef, 'no largest army' );
is( $player->longest_road, undef, 'no longest road' );
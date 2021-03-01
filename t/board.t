use strict;
use warnings;

use Test::More tests => 6;

use Games::Catan;
use Games::Catan::Board;

my $catan = Games::Catan->new();
my $board = Games::Catan::Board->new( game => $catan );

is( $board->type, 'beginner', 'beginner board' );
is( @{$board->tiles}, 19, '19 total tiles' );
is( $board->graph->vertices, 54, '54 total vertices' );
is( $board->graph->edges, 70, '70 total edges' );
ok( $board->graph->is_connected, 'connected graph' );
ok( $board->graph->is_edge_connected, 'no bridges' );

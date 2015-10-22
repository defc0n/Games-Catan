use strict;
use warnings;

use Test::More tests => 1;
use Data::Dumper;

use Games::Catan;

my $catan = Games::Catan->new( num_players => 3 );

my $winner = $catan->play();
ok( $winner, 'play()ed game and found a winner' );

diag( $winner->color . " won the game!" );

use strict;
use warnings;

use Test::More tests => 1;
use Data::Dumper;

use Games::Catan;

my $catan = Games::Catan->new( num_players => 4 );
my $game = $catan->play();
ok( $game, 'play()ed game!' );

diag( $game->winner->color . " won the game!" );

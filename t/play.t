use strict;
use warnings;

use Test::More tests => 1;
use Data::Dumper;

use Games::Catan;

my $catan = Games::Catan->new();

ok( $catan->play(), "played game" );
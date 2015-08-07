use strict;
use warnings;

use Test::More tests => 5;
use Data::Dumper;

use Games::Catan::Bank;

my $bank = Games::Catan::Bank->new();

is( @{$bank->brick}, 19, '19 brick' );
is( @{$bank->lumber}, 19, '19 lumber' );
is( @{$bank->ore}, 19, '19 ore' );
is( @{$bank->grain}, 19, '19 grain' );
is( @{$bank->wool}, 19, '19 wool' );
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile( NAME => 'Games::Catan',
               VERSION_FROM => 'lib/Games/Catan.pm',
               ABSTRACT_FROM => 'lib/Games/Catan.pod',
               AUTHOR => ['Mitch McCracken <mrmccrac@gmail.com>'],
               PREREQ_PM => {'Moo' => 0,
			     'Types::Standard' => 0,
			     'Log::Any' => 0,
			     'List::Util' => 0,
			     'Graph' => 0,
			     'Data::Dumper' => 0,
			     'Storable' => 0,
			     'autovivification' => 0},			     
               BUILD_REQUIRES => {'Test::More' => 0},
               MIN_PERL_VERSION => '5.8.8',
               LICENSE => 'artistic_2' );

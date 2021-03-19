use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Games::Catan',
    VERSION_FROM     => 'lib/Games/Catan.pm',
    ABSTRACT_FROM    => 'lib/Games/Catan.pm',
    AUTHOR           => ['Mitch McCracken <mrmccrac@gmail.com>'],
    BUILD_REQUIRES   => {'Test::More' => 0},
    MIN_PERL_VERSION => '5.8.8',
    LICENSE          => 'artistic_2',
    PREREQ_PM        => {
        'autovivification'  => 0,
        'strict'            => 0,
        'warnings'          => 0,
        'Graph::Undirected' => 0,
        'List::Util'        => 0,
        'Log::Any'          => 0,
        'Log::Any::Adapter' => 0,
        'Moo'               => 0,
        'Moo::Role'         => 0,
        'Storable'          => 0,
        'Types::Standard'   => 0,
    },
    TEST_REQUIRES => {
        'Test::More' => 0,
        'Try::Tiny'  => 0,
    },
    BUILD_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
);

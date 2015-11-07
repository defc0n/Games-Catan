package Games::Catan::Harbor;

use Moo;
use Types::Standard qw( Enum );

has brick_ratio => ( is => 'ro',
                     isa => Enum[qw( 2 3 4 )],
                     required => 0,
                     default => 4 );

has lumber_ratio => ( is => 'ro',
                      isa => Enum[qw( 2 3 4 )],
                      required => 0,
                      default => 4 );

has wool_ratio => ( is => 'ro',
                    isa => Enum[qw( 2 3 4 )],
                    required => 0,
                    default => 4 );

has grain_ratio => ( is => 'ro',
                     isa => Enum[qw( 2 3 4 )],
                     required => 0,
                     default => 4 );

has ore_ratio => ( is => 'ro',
                   isa => Enum[qw( 2 3 4 )],
                   required => 0,
                   default => 4 );

1;

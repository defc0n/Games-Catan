package Games::Catan::DevelopmentCard::University;

use Moo;

with( 'Games::Catan::DevelopmentCard' );

use Types::Standard qw( Int Bool );

has playable => ( is => 'ro',
                  isa => Bool,
                  required => 0,
                  default => 0 );

has num_points => ( is => 'ro',
                    isa => Int,
                    required => 0,
                    default => 1 );

1;

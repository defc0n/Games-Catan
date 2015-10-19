package Games::Catan::Cost;

use Moo;
use Types::Standard qw( Int );

has brick => ( is => 'ro',
               isa => Int,
               required => 0,
               default => 0 );

has lumber => ( is => 'ro',
                isa => Int,
                required => 0,
                default => 0 );

has wool => ( is => 'ro',
              isa => Int,
              required => 0,
              default => 0 );

has grain => ( is => 'ro',
               isa => Int,
               required => 0,
               default => 0 );

has ore => ( is => 'ro',
             isa => Int,
             required => 0,
             default => 0 );

has settlements => ( is => 'ro',
                     isa => Int,
                     required => 0,
                     default => 0 );

1;

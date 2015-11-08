package Games::Catan::Trade;

use Moo;
use Types::Standard qw( Maybe Int);

has offer_brick => ( is => 'rw',
                     isa => Maybe[Int],
                     required => 0,
                     default => 0 );

has offer_lumber => ( is => 'rw',
                      isa => Maybe[Int],
                      required => 0,
                      default => 0 );

has offer_wool => ( is => 'rw',
                    isa => Maybe[Int],
                    required => 0,
                    default => 0 );

has offer_grain => ( is => 'rw',
                     isa => Maybe[Int],
                     required => 0,
                     default => 0 );

has offer_ore => ( is => 'rw',
                   isa => Maybe[Int],
                   required => 0,
                   default => 0 );

has request_brick => ( is => 'rw',
                       isa => Maybe[Int],
                       required => 0,
                       default => 0 );

has request_lumber => ( is => 'rw',
                        isa => Maybe[Int],
                        required => 0,
                        default => 0 );

has request_wool => ( is => 'rw',
                      isa => Maybe[Int],
                      required => 0,
                      default => 0 );

has request_grain => ( is => 'rw',
                       isa => Maybe[Int],
                       required => 0,
                       default => 0 );

has request_ore => ( is => 'rw',
                     isa => Maybe[Int],
                     required => 0,
                     default => 0 );

1;

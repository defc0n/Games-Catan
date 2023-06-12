package Games::Catan::Player::Human;

use Moo;
with 'Games::Catan::Player';

use Types::Standard qw( InstanceOf );

has stream => (
    is  => 'ro',
    isa => InstanceOf['IO::Async::Stream']
);

use Games::Catan::Trade;

sub take_turn {}

sub place_first_settlement {}

sub place_second_settlement {}

sub activate_robber {}

sub offer_trade {}

sub discard_robber_cards {}

1;

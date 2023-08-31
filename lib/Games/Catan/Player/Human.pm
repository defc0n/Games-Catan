package Games::Catan::Player::Human;

use Moo;
#with 'Games::Catan::Player';
extends 'Games::Catan::Player::Stupid';

use Future::AsyncAwait;
use Types::Standard qw( InstanceOf );

use Log::Any::Adapter;

has stream => (
    is  => 'ro',
    isa => InstanceOf['IO::Async::Stream']
);

use Games::Catan::Trade;

sub BUILD {
    my ( $self ) = @_;

    return $self;
}

#sub take_turn {}

#async sub place_first_settlement {}

#sub place_second_settlement {}

#sub activate_robber {}

#sub offer_trade {}

#sub discard_robber_cards {}

1;

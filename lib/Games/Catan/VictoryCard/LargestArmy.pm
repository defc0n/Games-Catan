package Games::Catan::VictoryCard::LargestArmy;

use Moo;

with( 'Games::Catan::VictoryCard' );

sub determine_player {

  my ( $self ) = @_;

  my $players = $self->board->players;

  foreach my $player ( @$players ) {

    my $development_cards = $player->development_cards;

    foreach my $development_card ( @$development_cards ) {

      # only care if its a Knight
      next if ( !$development_card->isa( 'Games::Catan::DevelopmentCard::Knight' ) );

      # only counts if its been played
      next if ( !$development_card->played );
    }
  }
}

1;

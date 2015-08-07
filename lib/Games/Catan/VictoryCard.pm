package Games::Catan::VictoryCard;

use Moo::Role;
use Types:Standard qw( Int );

has num_points => ( is => 'ro',
		    isa => Int,
		    required => 1 );

has board => ( is => 'ro',
	       isa => 'Games::Catan::Board',
	       required => 1 );

sub determine_player {

  die( "This method must be implemented by a sub-class." );
}

1;

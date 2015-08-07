package Games::Catan;

use Moo;
use Types::Standard qw( Int Str );

has num_players => ( is => 'ro',
		     isa => Int,
		     default => 4 );

has type => ( is => 'ro',
	      isa => 'Str',
	      default => 'random' );

sub play {

}

1;

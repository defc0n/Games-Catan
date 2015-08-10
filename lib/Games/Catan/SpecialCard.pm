package Games::Catan::SpecialCard;

use Moo::Role;
use Types::Standard qw( Int InstanceOf );

has game => ( is => 'ro',
	      isa => InstanceOf['Games::Catan'],
	      required => 1 );

1;

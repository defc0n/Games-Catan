package Games::Catan::DevelopmentCard;

use Moo::Role;
use Types::Standard qw( Bool InstanceOf );

has game => ( is => 'ro',
	      isa => InstanceOf['Games::Catan'],
	      required => 1 );

has played => ( is => 'rw',
		isa => Bool,
		required => 0,
		default => 0,
		trigger => sub { my ( $self ) = @_; $self->game->check_winner(); } );

has cost => ( is => 'ro',
	      isa => InstanceOf['Games::Catan::Cost'],
	      required => 0,
              default => sub { Games::Catan::Cost->new( ore => 1,
						        wool => 1,
							grain => 1 ) } );

1;

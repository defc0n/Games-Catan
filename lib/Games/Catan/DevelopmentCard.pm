package Games::Catan::DevelopmentCard;

use Moo::Role;
use Types::Standard qw( Bool InstanceOf ConsumerOf Maybe );

has game => ( is => 'ro',
	      isa => InstanceOf['Games::Catan'],
	      required => 1 );

has player => ( is => 'rw',
		isa => Maybe[ConsumerOf['Games::Catan::Player']],
		required => 0 );		

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

has logger => ( is => 'ro',
                isa => InstanceOf['Log::Any::Proxy'],
                required => 0,
		default => sub { Log::Any->get_logger() } );

1;

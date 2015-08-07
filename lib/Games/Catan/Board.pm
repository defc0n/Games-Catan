package Games::Catan::Board;

use Moo;
use Types::Standard qw( Str ArrayRef InstanceOf );
use Graph;

use Games::Catan::Board::Vertex;

has graph => ( is => 'ro',
	       isa => InstanceOf['Graph'],
	       required => 0,
	       default => sub { Graph->new( undirected => 1 ) } );

has type => ( is => 'ro',
	      isa => Str,
	      required => 0,
	      default => 'basic' );

#has tiles => ( is => 'ro',
#	       isa => ArrayRef[InstanceOf['Games::Catan::Board::Tile']],
#	       required => 0,
#	       default => sub { [] } );

has vertices => ( is => 'ro',
		  isa => ArrayRef[InstanceOf['Games::Catan::Board::Vertex']],
		  required => 0,
		  default => sub { [] } );

#has victory_cards => ( is => 'ro',
#		       isa => ArrayRef[InstanceOf['Games::Catan::VictoryCard']],
#		       required => 0,
#		       default => sub { [] } );

sub BUILD {

  my ( $self ) = @_;

  # a basic 3-4 player catan board has 54 total vertices
  for ( 1 .. 54 ) {

    my $vertex = Games::Catan::Board::Vertex->new();

    push( @{$self->vertices}, $vertex );
  }

  # create the edges/adjacencies between the vertices
  $self->graph->add_edge( 0, 1 );
  $self->graph->add_edge( 1, 2 );
  $self->graph->add_edge( 2, 3 );
  $self->graph->add_edge( 3, 4 );
  $self->graph->add_edge( 4, 5 );
  $self->graph->add_edge( 5, 6 );

  $self->graph->add_edge( 0, 7 );
  $self->graph->add_edge( 2, 9 );
  $self->graph->add_edge( 4, 11 );
  $self->graph->add_edge( 6, 13 );

  $self->graph->add_edge( 7, 8 );
  $self->graph->add_edge( 8, 9 );
  $self->graph->add_edge( 9, 10 );
  $self->graph->add_edge( 10, 11 );
  $self->graph->add_edge( 11, 12 );
  $self->graph->add_edge( 12, 13 );

  $self->graph->add_edge( 7, 14 );
  $self->graph->add_edge( 13, 15 );

  $self->graph->add_edge( 14, 16 );
  $self->graph->add_edge( 16, 17 );
  $self->graph->add_edge( 17, 18 );
  $self->graph->add_edge( 18, 19 );
  $self->graph->add_edge( 19, 20 );
  $self->graph->add_edge( 20, 21 );
  $self->graph->add_edge( 21, 22 );
  $self->graph->add_edge( 22, 23 );
  $self->graph->add_edge( 23, 24 );
  $self->graph->add_edge( 15, 24 );

  $self->graph->add_edge( 8, 18 );
  $self->graph->add_edge( 10, 20 );
  $self->graph->add_edge( 12, 22 );

  $self->graph->add_edge( 16, 25 );
  $self->graph->add_edge( 25, 27 );
  $self->graph->add_edge( 27, 28 );
  $self->graph->add_edge( 28, 29 );
  $self->graph->add_edge( 29, 30 );
  $self->graph->add_edge( 30, 31 );
  $self->graph->add_edge( 31, 32 );
  $self->graph->add_edge( 32, 33 );
  $self->graph->add_edge( 33, 34 );
  $self->graph->add_edge( 34, 35 );
  $self->graph->add_edge( 35, 36 );
  $self->graph->add_edge( 36, 37 );
  $self->graph->add_edge( 26, 37 );
  $self->graph->add_edge( 24, 26 );

  $self->graph->add_edge( 17, 29 );
  $self->graph->add_edge( 19, 31 );
  $self->graph->add_edge( 21, 33 );
  $self->graph->add_edge( 23, 35 );

  $self->graph->add_edge( 28, 38 );
  $self->graph->add_edge( 38, 39 );
  $self->graph->add_edge( 39, 40 );
  $self->graph->add_edge( 40, 41 );
  $self->graph->add_edge( 41, 42 );
  $self->graph->add_edge( 42, 43 );
  $self->graph->add_edge( 43, 44 );
  $self->graph->add_edge( 44, 45 );
  $self->graph->add_edge( 45, 46 );
  $self->graph->add_edge( 36, 46 );

  $self->graph->add_edge( 30, 40 );
  $self->graph->add_edge( 32, 42 );
  $self->graph->add_edge( 34, 44 );

  $self->graph->add_edge( 39, 47 );
  $self->graph->add_edge( 47, 48 );
  $self->graph->add_edge( 48, 49 );
  $self->graph->add_edge( 49, 50 );
  $self->graph->add_edge( 50, 51 );
  $self->graph->add_edge( 51, 52 );
  $self->graph->add_edge( 52, 53 );
  $self->graph->add_edge( 45, 53 );  
}

sub get_buildings {

  my ( $self, %args ) = @_;

  my $player = $args{'player'};
  my $vertices = $self->vertices;

  my $buildings = [];

  foreach my $vertex ( @$vertices ) {

    my $building = $vertex->building;

    # no building at this vertex
    next if !$building;

    # did they specify the buildings of a player?
    if ( $player ) {

      # this isn't this player's building
      next if ( $player->color ne $building->player->color );
    }

    push( @$buildings, $building );
  }

  return $buildings;
}

1;

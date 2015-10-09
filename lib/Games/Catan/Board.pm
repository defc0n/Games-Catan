package Games::Catan::Board;

use Moo;
use Types::Standard qw( Enum ArrayRef InstanceOf );
use Graph::Undirected;

use Games::Catan::Robber;
use Games::Catan::Board::Tile;

has game => ( is => 'ro',
              isa => InstanceOf['Games::Catan'],
              required => 1 );

has type => ( is => 'ro',
              isa => Enum[qw( beginner )],
              required => 0,
              default => 'beginner' );

has graph => ( is => 'rw',
               isa => InstanceOf['Graph::Undirected'],
               required => 0 );

has tiles => ( is => 'rw',
               isa => ArrayRef[InstanceOf['Games::Catan::Board::Tile']],
               required => 0 );

has robber => ( is => 'rw',
                isa => InstanceOf['Games::Catan::Robber'],
                required => 0 );

sub BUILD {

    my ( $self ) = @_;

    $self->graph( Graph::Undirected->new() );
    $self->tiles( [] );

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

    # create the 19 tiles, associated with their vertices
    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'mountains',
                                                           number => 10,
                                                           vertices => [0, 1, 2, 7, 8, 9] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'pasture',
                                                           number => 2,
                                                           vertices => [2, 3, 4, 9, 10, 11] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'forest',
                                                           number => 9,
                                                           vertices => [4, 5, 6, 11, 12, 13] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'fields',
                                                           number => 12,
                                                           vertices => [14, 7, 8, 16, 17, 18] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'hills',
                                                           number => 6,
                                                           vertices => [8, 9, 10, 18, 19, 20] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'pasture',
                                                           number => 4,
                                                           vertices => [10, 11, 12, 20, 21, 22] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'hills',
                                                           number => 10,
                                                           vertices => [12, 13, 15, 22, 23, 24] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'fields',
                                                           number => 9,
                                                           vertices => [25, 16, 17, 27, 28, 29] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'forest',
                                                           number => 11,
                                                           vertices => [17, 18, 19, 29, 30, 31] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'desert',
                                                           number => 7,
                                                           vertices => [19, 20, 21, 31, 32, 33] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'forest',
                                                           number => 3,
                                                           vertices => [21, 22, 23, 33, 34, 35] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'mountains',
                                                           number => 8,
                                                           vertices => [23, 24, 26, 35, 36, 37] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'forest',
                                                           number => 8,
                                                           vertices => [28, 29, 30, 38, 39, 40] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'mountains',
                                                           number => 3,
                                                           vertices => [30, 31, 32, 40, 41, 42] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'fields',
                                                           number => 4,
                                                           vertices => [32, 33, 34, 42, 43, 44] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'pasture',
                                                           number => 5,
                                                           vertices => [34, 35, 36, 44, 45, 46] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'hills',
                                                           number => 5,
                                                           vertices => [39, 40, 41, 47, 48, 49] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'fields',
                                                           number => 6,
                                                           vertices => [41, 42, 43, 49, 50, 51] ) );

    push( @{$self->tiles}, Games::Catan::Board::Tile->new( terrain => 'pasture',
                                                           number => 11,
                                                           vertices => [43, 44, 45, 51, 52, 53] ) );

    # create the robber initially on the desert tile
    my $robber = Games::Catan::Robber->new( game => $self->game );

    $self->tiles->[9]->robber( $robber );
}

1;

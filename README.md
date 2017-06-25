# Games::Catan

Games::Catan is a suite of Perl libraries that simulate the popular board game [Settlers of Catan](http://www.catan.com).  A game can be constructed and played by very primitive AI players by doing:

```perl
use Games::Catan;

my $catan = Games::Catan->new( num_players => 4 );
$catan->play();
```

## Game Board

The game board is constructed by utilizing a undirected graph data structure, which consists of vertices (intersections) and
edges (paths) between them.  The [Graph](https://metacpan.org/pod/distribution/Graph/lib/Graph.pod) Perl module is used
internally.  This graph can be visualized as follows:

![catan undirected graph](img/catan_undirected_graph.png)

Only a standard 3-4 player game board is currently supported.  This consists of 54 total intersections, with 70 total edges
between them, yielding 19 total tiles.  The tiles are indexed as follows:

![catan tiles](img/catan_tiles.png)

Tiles themselves are not an additional data structure, but simply a collection of intersections and edges.

## Copyright

Settlers of Catan is © Catan GmbH 2015 (http://www.catan.com)

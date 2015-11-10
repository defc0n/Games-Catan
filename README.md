# Games::Catan

Games::Catan is a suite of Perl libraries that simulate the popular board game [Settlers of Catan](http://www.catan.com).

## Game Board

The game board is constructed by utilizing a undirected graph data structure, which consists of vertices (intersections) and
edges (paths) between them.  The [Graph](https://metacpan.org/pod/distribution/Graph/lib/Graph.pod) Perl module is used
internally.  This graph can be visualized as follows:

![catan undirected graph](/img/catan undirected graph.png)

Only a standard 3-4 player game board is currently supported.  This consists of 54 total intersections, with 70 total edges
between them, yielding 19 total tiles.  The tiles are indexed as follows:

![catan tiles](/img/catan tiles.png)

Tiles themselves are not an additional data structure, but simply a collection of intersections and edges.

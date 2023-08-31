package Games::Catan::Server;

use Moo;

use Future::AsyncAwait;
use Games::Catan;
use Games::Catan::Player::Human;
use Games::Catan::Player::Stupid;
use IO::Async::Loop;
use IO::Async::Listener;
use IO::Async::Stream;
use JSON::XS;
use String::Random qw( random_regex );

my %games;
my %players;

async sub start {
    my ( $self ) = @_;

    my $loop = IO::Async::Loop->new;

    my $listener = IO::Async::Listener->new(
        on_stream => sub {
            my ( $self, $stream ) = @_;

            warn "*** ON STREAM";

            $stream->configure(
                autoflush => 1,
                on_read => sub {
                    my ( $stream, $buffref, $eof ) = @_;
                    my $data = $$buffref;
                    chomp $data;
                    warn "*** READ DATA < $data > FROM STREAM < $stream >";
                    $$buffref = ""; # Clear the buffer
                    if ( $data eq "NEW 3" || $data eq "NEW 4" ) {
                        my $id = generate_game_id();
                        my ( $num_players ) = $data =~ /(\d)$/;

                        my $game = Games::Catan->new(
                            num_players => $num_players,
                            loop        => $loop,
                        );
                        $games{$id} = $game;

                        $game->players([
                            Games::Catan::Player::Human->new(
                                game   => $game,
                                color  => 'white',
                                stream => $stream,
                            )
                        ]);

                        push( @{ $game->players },
                              Games::Catan::Player::Stupid->new(
                                  game       => $game,
                                  color      => 'red',
                                  turn_delay => 3,
                              )
                        );

                        push( @{ $game->players },
                              Games::Catan::Player::Stupid->new(
                                  game       => $game,
                                  color      => 'orange',
                                  turn_delay => 3,
                              )
                        );

                        push( @{ $game->players },
                              Games::Catan::Player::Stupid->new(
                                  game       => $game,
                                  color      => 'blue',
                                  turn_delay => 3,
                              )
                        ) if $num_players == 4;

                        my $data = JSON::XS::decode_json( $game->serialize );
                        $data->{player}  = 'white';
                        $data->{game_id} = $id;
                        $stream->write( JSON::XS::encode_json( $data ) . "\n" );
                        warn "*** WHITE CREATED NEW $num_players GAME!";

                        $game->play;
                    }
                    elsif ( $data =~ /^JOIN (.{8})$/ ) {
                        my $id   = $1;
                        my $game = $games{$id};

                        unless ( $game ) {
                            $stream->write("ERROR\n");
                            return;
                        }

                        my $players     = $game->players;
                        my $num_players = $game->num_players;

                        # Game is already full.
                        if ( @$players >= $num_players ) {
                            $stream->write("ERROR\n");
                            return;
                        }

                        my $color;

                        if ( @$players == 1 ) {
                            $color = 'red';
                            $stream->write("RED\n");
                        }
                        elsif ( @$players == 2 ) {
                            $color = 'blue';
                            $stream->write("BLUE\n");
                        }
                        elsif ( @$players == 3 ) {
                            $color = 'orange';
                            $stream->write("ORANGE\n");
                        }

                        push @$players,
#                            Games::Catan::Player::Human->new(
                            Games::Catan::Player::Stupid->new(
                                game   => $game,
                                color  => $color,
                                #stream => $stream,
                            );

                        warn "*** $color JOINED EXISTING $num_players GAME!";
                        $game->play() if @$players == $num_players;
                    }

                    return 0;
                },
                on_closed => sub {
                    my ( $stream ) = @_;
                    # ...
                    return 0;
                },
            );

            $loop->add( $stream );
        },
    );

    $loop->add( $listener );

    unlink '/tmp/catan-server.sock';

    $listener->listen(
        addr => {
            family   => 'unix',
            socktype => 'stream',
            path     => '/tmp/catan-server.sock',
        },
        on_resolve_error => sub {
            my ( $listener, $message, $errno ) = @_;
            # ...
            warn "*** RESOLVE ERROR";
        },
        on_listen_error => sub {
            my ($listener, $message, $errno) = @_;
            # ...
            warn "*** LISTEN ERROR";
        },
    );

    # Run the event loop
    $loop->run;
}

sub generate_game_id { random_regex('[A-Z0-9]{8}') }

1;

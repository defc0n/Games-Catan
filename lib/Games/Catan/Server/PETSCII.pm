package Games::Catan::Server::PETSCII;

use Moo;
extends 'Net::Server::PreFork';

use Future::AsyncAwait;
use IO::Async::Loop;
use IO::Async::Handle;
use IO::Async::Stream;
use IO::Socket::UNIX;

use constant WIDTH  => 40;
use constant HEIGHT => 25;

use constant CLEAR_SCREEN => chr( 147 );
use constant HOME         => chr( 19 );

use constant INVERT_TEXT => chr(  18 );
use constant REVERT_TEXT => chr( 146 );

use constant MODE_TEXT     => chr(  14 );
use constant MODE_GRAPHICS => chr( 142 );

use constant TEXT_BLACK       => chr( 144 );
use constant TEXT_WHITE       => chr(   5 );
use constant TEXT_RED         => chr(  28 );
use constant TEXT_CYAN        => chr( 159 );
use constant TEXT_PURPLE      => chr( 156 );
use constant TEXT_GREEN       => chr(  30 );
use constant TEXT_BLUE        => chr(  31 );
use constant TEXT_YELLOW      => chr( 158 );
use constant TEXT_ORANGE      => chr( 129 );
use constant TEXT_BROWN       => chr( 149 );
use constant TEXT_LIGHT_RED   => chr( 150 );
use constant TEXT_DARK_GREY   => chr( 151 );
use constant TEXT_GREY        => chr( 152 );
use constant TEXT_LIGHT_GREEN => chr( 153 );
use constant TEXT_LIGHT_BLUE  => chr( 154 );
use constant TEXT_LIGHT_GREY  => chr( 155 );

my $selected_game_type = "3";
my $gamecode_buf       = "";
my $player_color       = "";

my $sock;

my @board = (
    32, 32, 32, 32, 32, [ 5, 18, 51 ], [ 88, 146 ], 32, [ 149, 109 ], 32, 32, 32, 32, 32, 32, 32, 110, 32, [ 5, 18, 50 ], [ 146, 158, 120 ], 13,
    32, 32, 32, 32, 32, 32, 32, 32, [ 151, 110 ], 32, 109, 32, 32, 32, 110, 32, 109, 32, [ 149, 98 ], 32, [ 151, 110 ], 13,
    32, 32, 32, 32, 32, 32, [ 149, 109 ], [ 151, 110 ], 32, [ 31, 113 ], 32, [ 151, 109 ], 32, 110, 32, [ 5, 126 ], 32, [ 151, 109 ], [ 149, 98 ], [ 151, 110 ], 32, [ 30, 97 ], 32, [ 151, 109 ], 13,
    32, 32, 32, 32, 32, 32, 98, 32, [ 5, 18, 49 ], 48, [ 146, 31, 113 ], 32, [ 151, 98 ], 32, [ 5, 126 ], [ 18, 50 ], [ 146, 126 ], 32, [ 151, 98 ], 32, [ 30, 97, ], [ 5, 18, 57 ], [ 146, 30, 97 ], 32, [ 151, 98 ], 13,
    32, 32, 32, 32, 32, 32, 98, 32, 32, [ 31, 113 ], 32, 32, [ 151, 98 ], 32, 32, [ 5, 126 ], 32, 32, [ 151, 98 ], 32, 32, [ 30, 97 ], 32, 32, [ 151, 98 ], [ 149, 110 ], 32, [ 5, 18, 50 ], [ 146, 31, 113 ], 13,
    32, 32, 32, 32, 32, [ 151, 110 ], 32, 109, 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, 32, 109, 13,
    [ 5, 18, 50 ], [ 146, 30, 97 ], 32, [ 149, 109 ], [ 151, 110 ], 32, [ 158, 120 ], 32, [ 151, 109 ], 32, 110, 32, [ 28, 166 ], 32, [ 151, 109 ], 32, 110, 32, [ 5, 126 ], 32, [ 151, 109, ], 32, 110, 32, [ 28, 166 ], 32, [ 151, 109, ], 32, [ 149, 110 ], 13,
    32, 32, 32, [ 151, 98 ], 32, [ 5, 18, 49 ], 50, [ 146, 158, 120 ], 32, [ 151, 98 ], 32, [ 28, 166 ], 54, 166, 32, [ 151, 98 ], 32, [ 5, 126 ], [ 18, 52, ], [ 146, 126 ], 32, [ 151, 98 ], 32, [ 5, 18, 49 ], 48, [ 146, 28, 166 ], 32, [ 151, 98 ], 13,
    32, 32, [ 149, 109 ], [ 151, 98 ], 32, 32, [ 158, 120 ], 32, 32, [ 151, 98 ], 32, 32, [ 28, 166 ], 32, 32, [ 151, 98 ], 32, 32, [ 5, 126 ], 32, 32, [ 151, 98 ], 32, 32, [ 28, 166 ], 32, 32, [ 151, 98 ], 13,
    32, 32, 110, 32, 109, 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, 32, 109, 13,
    32, 110, 32, [ 158, 120 ], 32, [ 151, 109 ], 32, 110, 32, [ 30, 97 ], 32, [ 151, 109 ], 32, 110, 32, 32, 32, 109, 32, 110, 32, [ 30, 97 ], 32, [ 151, 109 ], 32, 110, 32, [ 31, 113 ], 32, [ 151, 109 ], 32, [ 149, 110 ], 13,
    [ 151, 98 ], 32, [ 158, 120 ], [ 5, 18, 57 ], [ 146, 158, 120 ], 32, [ 151, 98 ], 32, [ 5, 18, 49, ], 49, [ 146, 30, 97 ], 32, [ 151, 98 ], 32, 32, [ 18, 155, 92 ], [ 146, 32 ], 32, [ 146, 151, 98 ], 32, [ 30, 97 ], [ 5, 18, 51 ], [ 146, 30, 97 ], 32, [ 151, 98 ], 32, [ 31, 113 ], [ 28, 56 ], [ 31, 113 ], 32, [ 151, 98 ], 32, [ 5, 18, 51 ], 88, 13,
    [ 146, 151, 98 ], 32, 32, [ 158, 120 ], 32, 32, [ 151, 98 ], 32, 32, [ 30, 97 ], 32, 32, [ 151, 98 ], 32, 32, 32, 32, 32, 98, 32, 32, [ 30, 97 ], 32, 32, [ 151, 98 ], 32, 32, [ 31, 113 ], 32, 32, [ 151, 98 ], [ 149, 110 ], 13,
    32, [ 151, 109 ], 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, 13,
    32, 32, 109, 32, 110, 32, [ 30, 97 ], 32, [ 151, 109 ], 32, 110, 32, [ 31, 113 ], 32, [ 151, 109 ], 32, 110, 32, [ 158, 120 ], 32, [ 151, 109 ], 32, 110, 32, [ 5, 126 ], 32, [ 151, 109 ], 32, 110, 13,
    32, 32, [ 149, 110 ], [ 151, 98 ], 32, [ 30, 97 ], [ 28, 56 ], [ 30, 97 ], 32, [ 151, 98 ], 32, [ 31, 113 ], [ 5, 18, 51 ], [ 146, 31, 113 ], 32, [ 151, 98 ], 32, [ 158, 120 ], [ 5, 18, 52 ], [ 146, 158, 120 ], 32, [ 151, 98 ], 32, [ 5, 126 ], [ 18, 53 ], [ 146, 126 ], 32, [ 151, 98 ], 13,
    32, 32, 32, 98, 32, 32, [ 30, 97 ], 32, 32, [ 151, 98 ], 32, 32, [ 31, 113 ], 32, 32, [ 151, 98 ], 32, 32, [ 158, 120 ], 32, 32, [ 151, 98 ], 32, 32, [ 5, 126 ], 32, 32, [ 151, 98 ], 13,
    [ 5, 18, 50 ], [ 146, 28, 166 ], 32, [ 149, 110 ], [ 151, 109 ], 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, [ 149, 109 ], 13,
    32, 32, 32, 32, 32, [ 151, 109 ], 32, 110, 32, [ 28, 166 ], 32, [ 151, 109 ], 32, 110, 32, [ 158, 120 ], 32, [ 151, 109 ], 32, 110, 32, [ 5, 126 ], 32, [ 151, 109 ], 32, 110, 13,
    32, 32, 32, 32, 32, 32, 98, 32, [ 28, 166 ], [ 5, 18, 53 ], [ 146, 28, 166 ], 32, [ 151, 98 ], 32, [ 158, 120 ], [ 28, 54 ], [ 158, 120 ], 32, [ 151, 98 ], 32, [ 5, 18, 49 ], 49, [ 146, 126 ], 32, [ 151, 98 ], [ 149, 109 ], 32, [ 5, 18, 50 ], [ 146, 126 ], 13,
    32, 32, 32, 32, 32, 32, [ 151, 98 ], 32, 32, [ 28, 166 ], 32, 32, [ 151, 98 ], 32, 32, [ 158, 120 ], 32, 32, [ 151, 98 ], 32, 32, [ 5, 126 ], 32, 32, [ 151, 98 ], 13,
    32, 32, 32, 32, 32, 32, [ 149, 110 ], [ 151, 109 ], 32, 32, 32, 110, 32, 109, 32, 32, 32, 110, [ 149, 98 ], [ 151, 109 ], 32, 32, 32, 110, 13,
    32, 32, 32, 32, 32, 32, 32, 32, 109, 32, 110, 32, 32, 32, 109, 32, 110, 32, [ 149, 98 ], 32, [ 151, 109 ], 32, 110, 13,
    32, 32, 32, 32, 32, [ 5, 18, 51 ], 88, [ 146, 32 ], [ 149, 110 ], 32, 32, 32, 32, 32, 32, 32, 109, [ 5, 18, 51 ], 88, 13,
);

sub process_request {
    my ( $self ) = @_;

    warn "*** in process_request";

    print CLEAR_SCREEN;
    print MODE_GRAPHICS;
    print HOME;

    $self->intro_loop();
    $self->game_loop();
}

sub intro_loop {
    my ( $self ) = @_;

    warn "*** in intro_loop";

    $sock = IO::Socket::UNIX->new(
        Type => SOCK_STREAM,
        Peer => '/tmp/catan-server.sock',
    );

    unless ( $sock ) {
        warn "*** womp no unix socket: $!";
        print "GAME SERVER UNAVAILABLE\r";
        exit;
    }

    print TEXT_YELLOW;

    $self->send( $self->center("THE COLONISTS OF NATAC") );
    print "\r\r\r\r";

    print TEXT_LIGHT_RED;

    print "       \x6f\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\x70\r";
    print "       \xa5";

    print TEXT_YELLOW;
    $self->send( "CHOOSE NUMBER OF PLAYERS:" );

    print TEXT_LIGHT_RED;
    print "\xa7";
    print "\r";

    print "       \xa5                         \xa7\r";
    print "       \xa5            ";

    if ( $selected_game_type eq "3" ) {
        print TEXT_WHITE;
        print INVERT_TEXT;
        print "3";
        print REVERT_TEXT;
    }
    else {
        print TEXT_LIGHT_GREY;
        print "3";
    }

    print TEXT_LIGHT_RED;
    print "            \xa7\r";

    print "       \xa5            ";

    if ( $selected_game_type eq "4" ) {
        print TEXT_WHITE;
        print INVERT_TEXT;
        print "4";
        print REVERT_TEXT;
    }
    else {
        print TEXT_LIGHT_GREY;
        print "4";
    }

    print TEXT_LIGHT_RED;
    print "            \xa7\r";

    print "       \x6c\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xba\r";

    print "\r\r\r";

    print "       \x6f\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\xb7\x70\r";
    print "       \xa5";

    print TEXT_YELLOW;
    $self->send( "ENTER GAME CODE:" );

    print TEXT_LIGHT_RED;
    print "         \xa7\r";

    print "       \xa5                         \xa7\r";
    print "       \xa5";

    print TEXT_LIGHT_GREY;
    print "\xa4\xa4\xa4\xa4\xa4\xa4\xa4\xa4                 ";

    print TEXT_LIGHT_RED;
    print "\xa7\r";

    print "       \x6c\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xaf\xba\r";

    # Initially highlight the cursor over the selected 3.
    print TEXT_LIGHT_GREY;
    print "\x91" x 11;
    print "\x1d" x 20;

    my $loop   = IO::Async::Loop->new;
    my $handle = IO::Async::Handle->new(
        read_handle   => \*STDIN,
        on_read_ready => sub {
            my $char = <STDIN>;

            unless ( defined $char ) {
                $loop->stop;
                return;
            }

            warn ord( $char );

            # Cursor down
            if ( ord( $char ) == 0x11 ) {
                if ( $selected_game_type eq "3" ) {
                    print TEXT_LIGHT_GREY;
                    print "3";
                    print "\x9d";
                    print "\x11";
                    print TEXT_WHITE;
                    print INVERT_TEXT;
                    print "4";
                    print REVERT_TEXT;
                    print "\x9d";
                    $selected_game_type = "4";
                }
                elsif ( $selected_game_type eq "4" ) {
                    print TEXT_LIGHT_GREY;
                    print "4";
                    print "\x9d";
                    print "\x11" x 8;
                    print "\x9d" x 12;
                    $selected_game_type = "gamecode";
                }
            }
            # Cursor up
            elsif ( ord( $char ) == 0x91 ) {
                if ( $selected_game_type eq "4" ) {
                    print TEXT_LIGHT_GREY;
                    print "4";
                    print "\x9d";
                    print "\x91";
                    print TEXT_WHITE;
                    print INVERT_TEXT;
                    print "3";
                    print REVERT_TEXT;
                    print "\x9d";
                    $selected_game_type = "3";
                }
                elsif ( $selected_game_type eq "gamecode" ) {
                    # Erase game code on screen.
                    print "\x9d" x length( $gamecode_buf );
                    print "\xa4" x length( $gamecode_buf );
                    # Go back to top left of screen and scroll back down to 4.
                    print "\x13";
                    print "\x11" x 9;
                    print "\x1d" x 20;
                    print TEXT_WHITE;
                    print INVERT_TEXT;
                    print "4";
                    print REVERT_TEXT;
                    print "\x9d";
                    $gamecode_buf = "";
                    $selected_game_type = "4";
                }
            }
            # Alphanumeric
            elsif ( ord( $char ) >= 0x30 && ord( $char ) <= 0x5a ) {
                if ( $selected_game_type eq "gamecode" ) {
                    if ( length( $gamecode_buf ) < 8 ) {
                        print TEXT_WHITE;
                        print $char;
                        print TEXT_LIGHT_GREY;
                        $gamecode_buf .= $char;
                        warn $gamecode_buf;
                    }
                }
            }
            # Delete/Backspace
            elsif ( ord( $char ) == 0x14 ) {
                if ( $selected_game_type eq "gamecode" ) {
                    if ( length( $gamecode_buf ) > 0 ) {
                        print "\x9d";
                        print "\xa4";
                        print "\x9d";
                        chop $gamecode_buf;
                        warn $gamecode_buf if $gamecode_buf;
                    }
                }
            }
            # Return
            elsif ( ord( $char ) == 0x0d ) {
                # Join existing game.
                if ( $selected_game_type eq "gamecode" ) {
                    if ( length( $gamecode_buf ) == 8 ) {
                        print $sock "JOIN $gamecode_buf\n";
                        $player_color = <$sock>;
                        chomp $player_color;
                        if ( $player_color eq 'ERROR' ) {
                            print "\x14" x 8;
                            print "\xa4" x 8;
                            print "\x94" x 8;
                            print "\r\r\r";
                            print "       UNABLE TO JOIN GAME $gamecode_buf\r";
                            print "\x91" x 4;
                            print "\x1d" x 8;
                            $gamecode_buf = "";
                        }
                        else {
                            warn "*** JOINED GAME $gamecode_buf AS COLOR $player_color";
                            $loop->stop;
                            return;
                        }
                    }
                }
                # Create new game.
                else {
                    warn "*** SENDING NEW GAME COMMAND";
                    print $sock "NEW $selected_game_type\n";
                    warn "*** READING RESPONSE";
                    my $res = <$sock>;
                    chomp $res;
                    ( $gamecode_buf, $player_color ) = $res =~ /^(.{8}) (.+)$/;
                    warn "*** CREATED NEW GAME $gamecode_buf AND IM $player_color";
                    $loop->stop;
                    return;
                }
            }
        },
    );

    $loop->add( $handle );
    $loop->run;
}

sub game_loop {
    my ( $self ) = @_;

    warn "*** in game_loop";
    $self->render_board();
    $self->render_player();
    $self->render_waiting();
    warn "*** done calling render()";

    my $loop = IO::Async::Loop->new;

    my $stream = IO::Async::Stream->new(
        read_handle  => $sock,
        write_handle => $sock,
        on_read      => sub {
            my ( $self, $buffref, $eof ) = @_;
            warn $$buffref;
            return 0;
        },
    );

    $loop->add( $stream );
    $loop->run;
    warn "*** how did i get here";
}

sub render_waiting {
    my ( $self ) = @_;

    print HOME;
    print chr(17) x 24;
    print TEXT_LIGHT_GREY;
    print "WAITING FOR OTHER PLAYERS...";
}

sub render_player {
    my ( $self ) = @_;

    print HOME;

    print chr(29) x 32;
    print TEXT_LIGHT_GREY;
    print "PLAYER:";

    print INVERT_TEXT;

    if ( $player_color eq 'WHITE' ) {
        print TEXT_WHITE;
    }
    elsif ( $player_color eq 'ORANGE' ) {
        print TEXT_ORANGE;
    }
    elsif ( $player_color eq 'BLUE' ) {
        print TEXT_BLUE;
    }
    else {
        print TEXT_RED;
    }

    print " ";
    print REVERT_TEXT;
}

sub render_board {
    my ( $self ) = @_;

    print CLEAR_SCREEN;
    print HOME;

    for my $chr ( @board ) {
        $chr = [ $chr ] unless ref $chr;
        print chr( $_ ) for @$chr;
    }

    #print "\xa5 \xa7\r";
    #print "\x6d\xaf\x6e\r";

    #for ( 1 .. 24 ) {
    #    print "." x 40;
    #}
}

sub send {
    my ( $self, $ascii ) = @_;

    my @ascii_chars = split //, $ascii;
    my @petscii_vals;

    for my $ascii_char ( @ascii_chars ) {
        my $ascii_val = ord( $ascii_char );
        my $petscii_val;

        # Upper case letters
        if ( $ascii_val >= 65 && $ascii_val <= 90 ) {
            #$petscii_val = $ascii_val + 128;
            $petscii_val = $ascii_val;
        }
        # Lower case letters
        elsif ( $ascii_val >= 97 && $ascii_val <= 122 ) {
            $petscii_val = $ascii_val - 32;
        }
        # Newline
        elsif ( $ascii_val == 10 ) {
            $petscii_val = 13;
        }
        # Everything else...
        else {
            $petscii_val = $ascii_val;
        }

        push @petscii_vals, chr( $petscii_val );
    }

    print for @petscii_vals;
}

sub center {
    my ( $self, $str ) = @_;

    my $len     = length $str;
    my $padding = ( WIDTH - $len ) / 2;

    return $str if $padding < 1;

    my $spaces = " " x $padding;
    return "$spaces$str$spaces";
}

1;

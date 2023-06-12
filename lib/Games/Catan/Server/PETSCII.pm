package Games::Catan::Server::PETSCII;

use Moo;
extends 'Net::Server::PreFork';

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

sub process_request {
    my ( $self ) = @_;

    print CLEAR_SCREEN;
    print MODE_GRAPHICS;

    $self->intro_loop();
    $self->game_loop();
}

sub intro_loop {
    my ( $self ) = @_;

    print HOME;

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
                if ( $selected_game_type eq "gamecode" ) {
                    if ( length( $gamecode_buf ) == 8 ) {
                        $loop->stop;
                        return;
                    }
                }
                else {
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

    my $sock = IO::Socket::UNIX->new(
        Type => SOCK_STREAM,
        Peer => '/tmp/catan-server.sock',
    );

    unless ( $sock ) {
        print "GAME SERVER UNAVAILABLE\r";
        exit;
    }

    # Join existing game.
    if ( $selected_game_type eq "gamecode" ) {
        print $sock "JOIN $gamecode_buf\n";
        $player_color = <$sock>;
        chomp $player_color;
        if ( $player_color eq 'ERROR' ) {
            print "UNABLE TO JOIN GAME $gamecode_buf\r";
            close $sock;
            $self->intro_loop();
        }
    }
    # Create new game.
    else {
        print $sock "NEW $selected_game_type\n";
        my $res = <$sock>;
        chomp $res;
        ( $gamecode_buf, $player_color ) = $res =~ /^(.{8}) (.+)$/;

        warn "*** CREATED NEW GAME $gamecode_buf AND IM $player_color";
    }

    my $stream = IO::Async::Stream->new(
        read_handle  => $sock,
        write_handle => $sock,
        on_read      => sub {
            my ( $self, $buffref, $eof ) = @_;
            warn $$buffref;
            return 0;
        },
    );

    my $loop = IO::Async::Loop->new;

    $loop->add( $stream );
    $loop->run;
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

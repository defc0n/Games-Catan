package Games::Catan::Server::PETSCII;

use Moo;
extends 'Net::Server::PreFork';

use Data::Compare;
use Future::AsyncAwait;
use IO::Async::Loop;
use IO::Async::Handle;
use IO::Async::Stream;
use IO::Handle;
use IO::Socket::UNIX;
use JSON::XS;
use Storable qw( dclone );

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

my %COLOR_MAP = (
    white  => TEXT_WHITE,
    red    => TEXT_RED,
    orange => TEXT_ORANGE,
    blue   => TEXT_BLUE,
);

my $selected_game_type = "3";
my $gamecode_buf       = "";
my $player_color       = "";

my $game_state;
my $sock;

my @board_map = (
    [qw( E       E       E       E       E       H0-3N   H0-3T   E       H0D\    I0      E       E       E       E       E       I1      H1D/    E       H1-5N   H1-5T   E       I2                                                                                                  )],
    [qw( E       E       E       E       E       E       E       E       P0-3/   E       P0-4\   E       E       E       P1-4/   E       P1-5\   E       H5D|    E       P2-5/   E       P2-6\                                                                                       )],
    [qw( E       E       E       E       E       H3D\    I3      P0-3/   E       T0R     E       P0-4\   I4      P1-4/   E       T1R     E       P1-5\   I5      P2-5/   E       T2R     E       P2-6\   I6                                                                          )],
    [qw( E       E       E       E       E       E       P3-7|   E       T0N     T0N     T0R     E       P4-8|   E       T1N     T1N     T1R     E       P5-9|   E       T2N     T2N     T2R     E       P6-10|                                                                      )],
    [qw( E       E       E       E       E       E       P3-7|   E       E       T0R     E       E       P4-8|   E       E       T1R     E       E       P5-9|   E       E       T2R     E       E       P6-10|  H10D/   E       H10-15N H10-15T                                     )],
    [qw( E       E       E       E       E       P7-11/  I7      P7-12\  E       E       E       P8-12/  I8      P8-13\  E       E       E       P9-13/  I9      P9-14\  E       E       E       P10-14/ I10     P10-15\                                                             )],
    [qw( H11-16N H11-16T H11D\   I11     P7-11/  E       T3R     E       P7-12\  I12     P8-12/  E       T4R     E       P8-13\  I13     P9-13/  E       T5R     E       P9-14\  I14     P10-14/ E       T6R     E       P10-15\ I15     H15D/                                       )],
    [qw( E       E       E       P11-16| E       T3N     T3N     T3R     E       P12-17| E       T4N     T4N     T4R     E       P13-18| E       T5N     T5N     T5R     E       P14-19| E       T6N     T6N     T6R     E       P15-20|                                             )],
    [qw( E       E       H16D\   P11-16| E       E       T3R     E       E       P12-17| E       E       T4R     E       E       P13-18| E       E       T5R     E       E       P14-19| E       E       T6R     E       E       P15-20|                                             )],
    [qw( E       E       P16-21/ I16     P16-22\ E       E       E       P17-22/ I17     P17-23\ E       E       E       P18-23/ I18     P18-24\ E       E       E       P19-24/ I19     P19-25\ E       E       E       P20-25/ I20     P20-26\                                     )],
    [qw( I21     P16-21/ E       T7R     E       P16-22\ I22     P17-22/ E       T8R     E       P17-23\ I23     P18-23/ E       T9R     E       P18-24\ I24     P19-24/ E       T10R    E       P19-25\ I25     P20-25/ E       T11R    E       P20-26\ I26     H26D/               )],
    [qw( P21-27| E       T7N     T7N     T7R     E       P22-28| E       T8N     T8N     T8R     E       P23-29| E       T9N     T9N     T9R     E       P24-30| E       T10N    T10N    T10R    E       P25-31| E       T11N    T11N    T11R    E       P26-32| E   H26-32N H26-32T )],
    [qw( P21-27| E       E       T7R     E       E       P22-28| E       E       T8R     E       E       P23-29| E       E       T9R     E       E       P24-30| E       E       T10R    E       E       P25-31| E       E       T11R    E       E       P26-32| H32D/               )],
    [qw( I27     P27-33\ E       E       E       P28-33/ I28     P28-34\ E       E       E       P29-34/ I29     P29-35\ E       E       E       P30-35/ I30     P30-36\ E       E       E       P31-36/ I31     P31-37\ E       E       E       P32-37/ I32                         )],
    [qw( E       E       P27-33\ I33     P28-33/ E       T12R    E       P28-34\ I34     P29-34/ E       T13R    E       P29-35\ I35     P30-35/ E       T14R    E       P30-36\ I36     P31-36/ E       T15R    E       P31-37\ I37     P32-37/                                     )],
    [qw( E       E       H33D/   P33-38| E       T12N    T12N    T12R    E       P34-39| E       T13N    T13N    T13R    E       P35-40| E       T14N    T14N    T14R    E       P36-41| E       T15N    T15N    T15R    E       P37-42|                                             )],
    [qw( E       E       E       P33-38| E       E       T12R    E       E       P34-39| E       E       T13R    E       E       P35-40| E       E       T14R    E       E       P36-41| E       E       T15R    E       E       P37-42|                                             )],
    [qw( H33-38N H33-38T H38D/   I38     P38-43\ E       E       E       P39-43/ I39     P39-44\ E       E       E       P40-44/ I40     P40-45\ E       E       E       P41-45/ I41     P41-46\ E       E       E       P42-46/ I42     H42D\                                       )],
    [qw( E       E       E       E       E       P38-43\ I43     P39-43/ E       T16R    E       P39-44\ I44     P40-44/ E       T17R    E       P40-45\ I45     P41-45/ E       T18R    E       P41-46\ I46     P42-46/                                                             )],
    [qw( E       E       E       E       E       E       P43-47| E       T16N    T16N    T16R    E       P44-48| E       T17N    T17N    T17R    E       P45-49| E       T18N    T18N    T18R    E       P46-50| H46D\   E       H42-46N H42-46T                                     )],
    [qw( E       E       E       E       E       E       P43-47| E       E       T16R    E       E       P44-48| E       E       T17R    E       E       P45-49| E       E       T18R    E       E       P46-50|                                                                     )],
    [qw( E       E       E       E       E       H47D/   I47     P47-51\ E       E       E       P48-51/ I48     P48-52\ E       E       E       P49-52/ I49     P49-53\ E       E       E       P50-53/ I50                                                                         )],
    [qw( E       E       E       E       E       E       E       E       P47-51\ I51     P48-51/ E       E       E       P48-52\ I52     P49-52/ E       H49D|   E       P49-53\ I53     P50-53/                                                                                     )],
    [qw( E       E       E       E       E       H47-51N H47-51T E       H51D/   E       E       E       E       E       E       E       H52D\   H49-52N H49-52T                                                                                                                     )],
);

# Keep track of what their previous & new screen to draw is.
my @screen;
my @new_screen;

for ( my $i = 0; $i < 24; $i++ ) {
    $screen[ $i ]      = [];
    $new_screen[ $i ] = [];
    for ( my $j = 0; $j < 40; $j++ ) {
        $screen[ $i ]->[ $j ]      = [ TEXT_WHITE, REVERT_TEXT, ' ' ]; # color, inverted, character
        $new_screen[ $i ]->[ $j ] = [ @{ $screen[ $i ]->[ $j ] } ];
    }
}

sub render_board {
    my ( $self ) = @_;

    my $board = $game_state->{board};

    for ( my $i = 0; $i < @board_map; $i++ ) {
        for ( my $j = 0; $j < @{ $board_map[ $i ] }; $j++ ) {
            my $mapping = $board_map[ $i ]->[ $j ];

            if ( $mapping eq 'E' ) {
                $new_screen[ $i ]->[ $j ] = [ TEXT_WHITE, REVERT_TEXT, ' ' ];
            }
            elsif ( $mapping =~ /^P(\d+)-(\d+)(.)$/ ) {
                my ( $v1, $v2, $line ) = ( $1, $2, $3 );
                my $road = $board->{roads}->{ $v1 }->{ $v2 };
                my $chr  =
                    $line eq "/"  ? chr(110) :
                    $line eq "\\" ? chr(109) :
                                    chr(98);

                $new_screen[ $i ]->[ $j ] = [
                    $road ? $COLOR_MAP{ $road } : TEXT_DARK_GREY,
                    REVERT_TEXT,
                    $chr,
                ];
            }
            elsif ( $mapping =~ /^I(\d+)$/ ) {
                my $intersection = $1;
                my $building = $board->{buildings}->{ $intersection };

                if ( $building ) {
                    $new_screen[ $i ]->[ $j ] = [
                        $COLOR_MAP{ $building->{player} },
                        REVERT_TEXT,
                        $building->{type} eq 'settlement' ? chr(122) : chr(35),
                    ];
                }
            }
            elsif ( $mapping =~ /^T(\d+)R$/ ) {
                my $tile_index = $1;
                my $tile       = $board->{tiles}->[ $tile_index ];
                my $terrain    = $tile->{terrain};

                $new_screen[ $i ]->[ $j ] = [
                    $terrain eq 'fields'    ? TEXT_YELLOW :
                    $terrain eq 'pasture'   ? TEXT_WHITE  :
                    $terrain eq 'forest'    ? TEXT_GREEN  :
                    $terrain eq 'hills'     ? TEXT_RED    :
                    $terrain eq 'mountains' ? TEXT_BLUE   :
                                              TEXT_WHITE,

                    REVERT_TEXT,

                    $terrain eq 'fields'    ? chr(120) :
                    $terrain eq 'pasture'   ? chr(126) :
                    $terrain eq 'forest'    ? chr(97)  :
                    $terrain eq 'hills'     ? chr(166) :
                    $terrain eq 'mountains' ? chr(113) :
                                              ' ',
                ];
            }
            elsif ( $mapping =~ /^T(\d+)N$/ ) {
                my $tile_index = $1;
                my $tile       = $board->{tiles}->[ $tile_index ];
                my $roll       = $tile->{roll};
                my $robber     = $tile->{robber};

                my $mapping_to_the_right = $board_map[ $i ]->[ $j + 1 ];

                if ( $robber ) {
                    if ( $mapping_to_the_right eq 'T' . $tile_index . 'N' ) {
                        $new_screen[ $i ]->[ $j ] = [ @{ $new_screen[ $i - 1 ]->[ $j + 1 ] } ];
                    }
                    else {
                        $new_screen[ $i ]->[ $j ] = [
                            TEXT_GREY,
                            INVERT_TEXT,
                            chr(92),
                        ];
                    }
                }
                else {
                    if ( $roll >= 10 && $mapping_to_the_right eq 'T' . $tile_index . 'N' ) {
                        $new_screen[ $i ]->[ $j ] = [
                            TEXT_WHITE,
                            INVERT_TEXT,
                            '1',
                        ];
                    }
                    elsif ( $roll >= 10 ) {
                        my $remainder = $roll % 10;
                        $new_screen[ $i ]->[ $j ] = [
                            TEXT_WHITE,
                            INVERT_TEXT,
                            $remainder,
                        ];
                    }
                    elsif ( $mapping_to_the_right eq 'T' . $tile_index . 'N' ) {
                        $new_screen[ $i ]->[ $j ] = [ @{ $new_screen[ $i - 1 ]->[ $j + 1 ] } ];
                    }
                    else {
                        $new_screen[ $i ]->[ $j ] = [
                            TEXT_WHITE,
                            INVERT_TEXT,
                            "$roll",
                        ];
                    }
                }
            }
            elsif ( $mapping =~ /^H(\d+)D(.)$/ ) {
                my ( $intersection, $line ) = ( $1, $2 );
                my $harbor = $board->{harbors}->{ $intersection };

                if ( $harbor ) {
                    $new_screen[ $i ]->[ $j ] = [
                        TEXT_BROWN,
                        REVERT_TEXT,
                        $line eq "/"  ? chr(110) :
                        $line eq "\\" ? chr(109) :
                                        chr(98),
                    ];
                }
                else {
                    $new_screen[ $i ]->[ $j ] = [
                        TEXT_WHITE,
                        REVERT_TEXT,
                        ' ',
                    ];
                }
            }
            elsif ( $mapping =~ /^H(\d+)-(\d+)N$/ ) {
                my ( $v1, $v2 ) = ( $1, $2 );
                my $harbor = $board->{harbors}->{ $v1 };

                if ( $harbor ) {
                    $new_screen[ $i ]->[ $j ] = [
                        TEXT_WHITE,
                        INVERT_TEXT,
                        $harbor eq 'generic' ? '3' : '2',
                    ];
                }
                else {
                    $new_screen[ $i ]->[ $j ] = [
                        TEXT_WHITE,
                        REVERT_TEXT,
                        ' ',
                    ];
                }
            }
            elsif ( $mapping =~ /^H(\d+)-(\d+)T$/ ) {
                my ( $v1, $v2 ) = ( $1, $2 );
                my $harbor = $board->{harbors}->{ $v1 };

                if ( $harbor ) {
                    $new_screen[ $i ]->[ $j ] = [
                        $harbor eq 'generic' ? TEXT_WHITE :
                        $harbor eq 'grain'   ? TEXT_YELLOW :
                        $harbor eq 'wool'    ? TEXT_WHITE :
                        $harbor eq 'lumber'  ? TEXT_GREEN :
                        $harbor eq 'brick'   ? TEXT_RED :
                                               TEXT_BLUE,

                        $harbor eq 'generic' ? INVERT_TEXT : REVERT_TEXT,

                        $harbor eq 'generic' ? 'X' :
                        $harbor eq 'grain'   ? chr(120) :
                        $harbor eq 'wool'    ? chr(126) :
                        $harbor eq 'lumber'  ? chr(97) :
                        $harbor eq 'brick'   ? chr(166) :
                                               chr(113),
                    ];
                }
                else {
                    $new_screen[ $i ]->[ $j ] = [
                        TEXT_WHITE,
                        REVERT_TEXT,
                        ' ',
                    ];
                }
            }
        }
    }
}

sub refresh_screen {
    my ( $self ) = @_;

    print HOME;

    my $current_inverted = '';
    my $current_color    = '';

    my %differences;
    for ( my $i = 0; $i < @screen; $i++ ) {
        my @row_diff;
        for ( my $j = 0; $j < @{ $screen[ $i ] }; $j++ ) {
            push( @row_diff, $j )
                unless Data::Compare::Compare(
                    $screen[ $i ]->[ $j ],
                    $new_screen[ $i ]->[ $j ],
                );
        }
        $differences{ $i } = \@row_diff if @row_diff;
    }

    my $current_row = 0;
    my $current_col = 0;

    for my $difference_row ( sort { $a <=> $b } keys %differences ) {
        #last if $current_row > 0;
        # Advance to the next row that has some differences.
        my $distance = $difference_row - $current_row;
        for ( my $j = 0; $j < $distance; $j++ ) {
            # cursor down
            print chr(17);
        }

        my $col_diffs = $differences{ $difference_row };
        for my $col_diff ( @$col_diffs ) {
            $distance = $col_diff - $current_col;
            # cursor right
            my $j;
            for ( $j = 0; $j < $distance; $j++ ) {
                print chr(29);
            }
            $current_col = $col_diff;

            my ( $color, $inverted, $char ) = @{ $new_screen[ $difference_row ]->[ $col_diff ] };
            print $inverted unless ord($current_inverted) == ord($inverted);
            $current_inverted = $inverted;

            print $color unless ord($current_color) == ord($color);
            $current_color = $color;

            print $char;

            $current_col++;
        }

        # Handle line wrap.
        if ( $current_col == 40 ) {
            $current_row++;
        }
        else {
            $current_row = $difference_row + 1;
            print chr(13);
        }

        $current_col = 0;
    }

    my $distance = 24 - $current_row;
    for ( my $i = $current_row; $i < 24; $i++ ) {
        print chr(17);
    }

    print ' '      for 1 .. 39;
    print chr(157) for 1 .. 39;

    my $white = TEXT_WHITE();
    my $red = TEXT_RED();
    my $orange = TEXT_ORANGE();
    my $blue = TEXT_BLUE();
    my $grey = TEXT_GREY();

    my $invert = INVERT_TEXT();
    my $revert = REVERT_TEXT();

    if ( $game_state->{message} ) {
        warn $game_state->{message};
        my $message = uc( $game_state->{message} );
        $message =~ s/WHITE/${white}WHITE${grey}/g;
        $message =~ s/RED/${red}RED${grey}/g;
        $message =~ s/ORANGE/${orange}ORANGE${grey}/g;
        $message =~ s/BLUE/${blue}BLUE${grey}/g;
        $message =~ s/ROLLED (\d+)/ROLLED ${invert}${white}$1${revert}${grey}/;
        print $grey, $message;
    }

    @screen = @{ dclone( \@new_screen ) };
}

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
            my $char = STDIN->getc;

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
                    $game_state = JSON::XS::decode_json( <$sock> );
                    warn "*** CREATED NEW GAME $game_state->{game_id} AND IM $game_state->{player}";
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

    print CLEAR_SCREEN;
    $self->render_board();

    for ( my $i = 0; $i < @new_screen; $i++ ) {
        for ( my $j = 0; $j < scalar( @{ $new_screen[$i] } ); $j++ ) {
            #warn ord( $new_screen[$i]->[$j]->[0] );
            #warn ord( $new_screen[$i]->[$j]->[1] );
            #warn ord( $new_screen[$i]->[$j]->[2] );
        }
    }
    #$self->render_player();
    #$self->render_waiting();
    $self->refresh_screen();

    my $loop = IO::Async::Loop->new;

    my $stream = IO::Async::Stream->new(
        read_handle  => $sock,
        write_handle => $sock,
        #autoflush    => 1,
        on_read      => sub {
            my ( $s, $buffref, $eof ) = @_;
            my $buf;
            while( $$buffref =~ s/^(.*\n)// ) {
                $buf .= $1;
            }

            if ( $eof ) {
                $buf .= $$buffref;
            }

            if ( $buf =~ /^UPDATE (.+)/ ) {
                $game_state = JSON::XS::decode_json($1);
                $self->render_board;
                $self->refresh_screen;
            }
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

    if ( $game_state->{player} eq 'white' ) {
        print TEXT_WHITE;
    }
    elsif ( $game_state->{player} eq 'orange' ) {
        print TEXT_ORANGE;
    }
    elsif ( $game_state->{player} eq 'blue' ) {
        print TEXT_BLUE;
    }
    else {
        print TEXT_RED;
    }

    print " ";
    print REVERT_TEXT;
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

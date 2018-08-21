use Irssi;
use strict;
use vars qw ($VERSION %IRSSI);

%IRSSI = (
        authors            => "arab",
        contact            => "irc://irc.arabs.ps/arab",
        name               => "SandNETsup",
        description        => "Client-side SandNET regular expression filter and multi-line nick name support script",
        license            => "Arabic Fuck You Licence (AFYL)",
);
$VERSION = "14.88";

my (@servers) = (());
sub printformat_own_msg {
        my ($server, $args, $nick, $event) = @_;
        my ($target, $msg) = (split (/ /, $args, 2));
        $msg =~ s/^:// if (substr ($msg, 0, 1) eq ":");

        if (($event eq "event privmsg")
        &&  ($msg =~ m/^\x01ACTION .*\x01$/)) {
                $msg =~ s/^\x01ACTION //; $msg =~ s/\x01$//;
                $server->printformat ($target,
                        MSGLEVEL_PUBLIC | MSGLEVEL_NOHILIGHT | MSGLEVEL_NO_ACT,
                        "own_action", $nick, $msg);
        } elsif ($event eq "event privmsg") {
                my ($channel, $channel_nick, $nick_mode) = (undef, undef, " ");
                if (defined ($channel = Irssi::channel_find ($target))
                &&  defined ($channel_nick = $channel->nick_find ($server->{"nick"}))) {
                        if ($channel_nick->{"op"}) {
                                $nick_mode = "@";
                        } elsif ($channel_nick->{"halfop"}) {
                                $nick_mode = "%";
                        } elsif ($channel_nick->{"voice"}) {
                                $nick_mode = "+";
                        };
                };
                $server->printformat ($target,
                        MSGLEVEL_PUBLIC | MSGLEVEL_NOHILIGHT | MSGLEVEL_NO_ACT,
                        "own_msg", $nick, $msg, $nick_mode);
        } elsif ($event eq "event notice") {
                $server->printformat ($target,
                        MSGLEVEL_PUBLIC | MSGLEVEL_NOHILIGHT | MSGLEVEL_NO_ACT,
                        "own_notice", $nick, $msg);
        };
        Irssi::signal_stop;
};


sub reload {
        @servers = split (/,/, Irssi::settings_get_str ("SandNETsup_servers"));
};

Irssi::settings_add_str ("SandNETsup", "SandNETsup_servers", "qurtuba.arabs.ps");
Irssi::signal_add_last ("event 001", sub {
        my ($server) = @_;
        Irssi::print ("Setting UMODE +e.");
        $server->command ("MODE ". $server->{"nick"} ." +e")
                if ((grep {$_ eq $server->{"real_address"}} @servers));
        Irssi::signal_continue @_;
});
Irssi::signal_add_first ("event notice", sub {
        my ($server, $args, $sender_nick, $sender_address) = @_;
        if ((grep {$_ eq $server->{"real_address"}} @servers)
        &&  ((length ($sender_address))
        &&   (lc ($sender_address) eq lc ($server->{"userhost"})))) {
                printformat_own_msg ($server, $args, $sender_nick, "event notice");
        } else {
                Irssi::signal_continue @_;
        };
});
Irssi::signal_add_first ("event privmsg", sub {
        my ($server, $args, $sender_nick, $sender_address) = @_;
        if ((grep {$_ eq $server->{"real_address"}} @servers)
        &&  ((length ($sender_address))
        &&   (lc ($sender_address) eq lc ($server->{"userhost"})))) {
                printformat_own_msg ($server, $args, $sender_nick, "event privmsg");
        } else {
                Irssi::signal_continue @_;
        };
});
Irssi::signal_add_first ("message irc own_notice", sub {
        my ($server, undef, undef) = @_;
        if ((grep {$_ eq $server->{"real_address"}} @servers)) {
                Irssi::signal_stop ();
        } else {
                Irssi::signal_continue @_;
        };
});
Irssi::signal_add_first ("message irc own_action", sub {
        my ($server, undef, undef) = @_;
        if ((grep {$_ eq $server->{"real_address"}} @servers)) {
                Irssi::signal_stop ();
        } else {
                Irssi::signal_continue @_;
        };
});
Irssi::signal_add_first ("message own_public", sub {
        my ($server, undef, undef) = @_;
        if ((grep {$_ eq $server->{"real_address"}} @servers)) {
                Irssi::signal_stop ();
        } else {
                Irssi::signal_continue @_;
        };
});
Irssi::signal_add ("setup changed", \&reload);
Irssi::theme_register([
        "own_action",        "{ownaction \$0}\$1",
        "own_msg",        "{ownmsgnick \$2 {ownnick \$0}} \$1",
        "own_notice",        "{ownnotice notice \$0}\$1",
]);

Irssi::print ("Loaded SandNETsup");
reload ();

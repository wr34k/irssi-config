# massmode.pl
# use to add a mode to all people in the channel

# Usage: /massmode <mode>
# Mode can be +o, +v, +vo, -o, etc

use strict;
use Irssi;
use Irssi::Irc;

sub massmode {
    my ($data, $server, $channel) = @_;
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, "Massmode", "Not connected to server."),        return if (!$server or !$server->{connected});
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, "Massmode", "No active channel in window."),    return if (!$channel or ($channel->{type} ne "CHANNEL"));

    my @nicks = map {$_->{nick}} (grep { $server->{nick} ne $_->{nick} } $channel->nicks());
    my @modes = split(//, (substr $data, 1));
    my $modetype = substr $data, 0, 1;
    my $modestr = "MODE $modetype";

    for (my $i=0; $i < @modes; $i++) {
        $modestr .= $modes[$i] x @nicks
    }

    $modestr .= " ";

    for (my $i=0; $i < @modes; $i++) {
        $modestr .= join(" ", @nicks) . " ";
    }
    $channel->command("$modestr");
}

Irssi::command_bind('massmode', 'massmode');
